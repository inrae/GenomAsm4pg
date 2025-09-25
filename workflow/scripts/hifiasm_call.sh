#!/bin/bash
# Script to dynamically run hifiasm with the correct command based on the mode
# Author: Lucien PIAT
# For: Project Pangenoak
# Date: April 3, 2025

set -e  # Exit script immediately on any error

MODE=$1
PURGE_FORCE=$2
THREADS=$3
INPUT=$4
RUN_1=$5
RUN_2=$6
PREFIX=$7
OUT1=$8
OUT2=$9
INPUT_FQ=${10}
INPUT_LONG=${12}

echo "🔹 Asm4pg -> Starting assembly: $date"

echo "Asm4pg -> Given hifiasm parameters:"
echo "  MODE: $MODE"
echo "  PURGE_FORCE: $PURGE_FORCE"
echo "  THREADS: $THREADS"
echo "  INPUT FASTA: $INPUT"
echo "  INPUT FASTQ: $INPUT_FQ"
echo "  RUN_1: $RUN_1"
echo "  RUN_2: $RUN_2"
echo "  PREFIX: $PREFIX"

available_mem=$(free -h | awk '/Mem:/ {print $7}')
echo "🔹 Asm4pg -> Available memory: $available_mem"

cleanup_files() {
    echo "🔹 Asm4pg -> Cleaning up intermediate files..."
    rm -f ${PREFIX}*.{agp,bin,amb,ann,fai,bwt,pac,sa,fasta,lowQ.bed,gfa,yak}
}

run_fastp() {
    echo "🔹 Asm4pg -> Running fastp for Hi-C read preprocessing..."
    fastp -i "$RUN_1" -I "$RUN_2" -o "${PREFIX}_clean_HiC_R1.fq.gz" -O "${PREFIX}_clean_HiC_R2.fq.gz" \
        -q 20 -l 50 -h "${PREFIX}_fastp_report.html" -j "${PREFIX}_fastp_report.json" --thread "$THREADS"
    
    echo "🔹 Asm4pg -> Hi-C reads cleaned. Proceeding to Hifiasm assembly..."
    RUN_1="${PREFIX}_clean_HiC_R1.fq.gz"
    RUN_2="${PREFIX}_clean_HiC_R2.fq.gz"
}

convert_gfa_to_fasta() {
    echo "🔹 Asm4pg -> Converting GFA to FASTA..."
    for hap in hap1 hap2; do
        awk '$1 == "S" {print ">" $2 "\n" $3}' "${PREFIX}.${hap}.p_ctg.gfa" > "${PREFIX}.${hap}.p_ctg.fasta"
        samtools faidx "${PREFIX}.${hap}.p_ctg.fasta"
    done
}

align_hic_reads() {
    echo "🔹 Asm4pg -> Indexing FASTA file with BWA..."
    bwa index "${PREFIX}.hap1.p_ctg.fasta"
    bwa index "${PREFIX}.hap2.p_ctg.fasta"

    echo "🔹 Asm4pg -> Aligning Hi-C reads to contigs..."
    for hap in hap1 hap2; do
        bwa mem -5SP -t "$THREADS" "${PREFIX}.${hap}.p_ctg.fasta" "$RUN_1" "$RUN_2" | \
            samtools view -Sb - | samtools sort -@ "$THREADS" -m 4G -o "${PREFIX}_${hap}_hic_aligned.bam"
        samtools index "${PREFIX}_${hap}_hic_aligned.bam"
    done
}

run_yahs_scaffolding() {
    echo "🔹 Asm4pg -> Running YAHS for scaffolding..."
    for hap in hap1 hap2; do
        yahs "${PREFIX}.${hap}.p_ctg.fasta" "${PREFIX}_${hap}_hic_aligned.bam" -o "${PREFIX}_${hap}"
        rm "${PREFIX}_${hap}_hic_aligned.bam"
    done
    echo "✅ Asm4pg -> YAHS scaffolding completed."
}

run_hifiasm() {
    echo "🔹 Asm4pg -> Running hifiasm..."
    case "$MODE" in
        default)
            hifiasm -l"$PURGE_FORCE" -o "$PREFIX" -t "$THREADS" "$INPUT"
            mv "${PREFIX}.bp.hap1.p_ctg.gfa" "$OUT1"
            mv "${PREFIX}.bp.hap2.p_ctg.gfa" "$OUT2"
            cleanup_files
            ;;
        ont)
            # 1. Lancer Hifiasm
            hifiasm -l"$PURGE_FORCE" -o "$PREFIX" -t "$THREADS" --ont "$INPUT_FQ" --ul "$INPUT_LONG"

            # 2. Vérifier  les fichiers de sortie produits
            # Cas n°1 : Hifiasm a produit une sortie haploïde standard (.p_ctg.gfa)
            if [ -f "${PREFIX}.p_ctg.gfa" ]; then
                echo "✅ Asm4pg -> Sortie haploïde standard détectée."
                mv "${PREFIX}.p_ctg.gfa" "$OUT1"
                cp "$OUT1" "$OUT2" # Crée un fichier hap2 vide pour Snakemake

            # Cas n°2 : Hifiasm a produit une sortie diploïde standard (.bp.hap1.p_ctg.gfa)
            elif [ -f "${PREFIX}.bp.hap1.p_ctg.gfa" ]; then
                echo "✅ Asm4pg -> Sortie diploïde standard détectée."
                mv "${PREFIX}.bp.hap1.p_ctg.gfa" "$OUT1"
                cp "$OUT1" "$OUT2" # Crée un fichier hap2 vide pour Snakemake
            
            # Cas n°3 : Hifiasm a produit une sortie haploïde mais avec le préfixe 'bp.' 
            elif [ -f "${PREFIX}.bp.p_ctg.gfa" ]; then
                echo "✅ Asm4pg -> Sortie haploïde avec préfixe 'bp.' détectée."
                mv "${PREFIX}.bp.p_ctg.gfa" "$OUT1"
                cp "$OUT1" "$OUT2" # Crée un fichier hap2 vide pour Snakemake

            else
                echo "ERREUR FATALE: Hifiasm n'a produit aucun des fichiers d'assemblage attendus !"
                echo "Vérifiez les logs de hifiasm et la qualité/quantité de vos données."
                exit 1
            fi
            
            cleanup_files
            ;;
        hi-c)
            [[ "$RUN_1" == *.fastq.gz && "$RUN_2" == *.fastq.gz ]] && run_fastp
            hifiasm -l"$PURGE_FORCE" -o "$PREFIX" -t "$THREADS" --h1 "$RUN_1" --h2 "$RUN_2" "$INPUT"
            mv "${PREFIX}.hic.hap1.p_ctg.gfa" "${PREFIX}.hap1.p_ctg.gfa"
            mv "${PREFIX}.hic.hap2.p_ctg.gfa" "${PREFIX}.hap2.p_ctg.gfa"
            convert_gfa_to_fasta
            align_hic_reads
            run_yahs_scaffolding
            mv "${PREFIX}.hap1.p_ctg.gfa" "$OUT1"
            mv "${PREFIX}.hap2.p_ctg.gfa" "$OUT2"
            cleanup_files
            ;;
        
        trio)
            echo "🔹 Asm4pg -> Generating yak files for parental reads..."
            yak count -k31 -b37 -t16 -o "${PREFIX}_parent1.yak" "$RUN_1"
            yak count -k31 -b37 -t16 -o "${PREFIX}_parent2.yak" "$RUN_2"

            echo "🔹 Asm4pg -> Running hifiasm in trio mode..."
            hifiasm -o "$PREFIX" -t "$THREADS" -1 "${PREFIX}_parent1.yak" -2 "${PREFIX}_parent2.yak" "$INPUT"

            mv "${PREFIX}.dip.hap1.p_ctg.gfa" "${PREFIX}.bp.hap1.p_ctg.gfa"
            mv "${PREFIX}.dip.hap2.p_ctg.gfa" "${PREFIX}.bp.hap2.p_ctg.gfa"
            mv "${PREFIX}.bp.hap1.p_ctg.gfa" "$OUT1"
            mv "${PREFIX}.bp.hap2.p_ctg.gfa" "$OUT2"
            cleanup_files
            ;;
        
        *)
            echo "❌ Asm4pg -> ERROR: Unknown hifiasm mode: $MODE"
            exit 1
            ;;
    esac
}

# Main Execution
run_hifiasm
echo "✅ Asm4pg -> Hifiasm assembly Done."
echo "$date"