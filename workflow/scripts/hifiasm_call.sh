#!/bin/bash
# Script to dynamically run hifiasm with the correct command based on the mode
# Author: Lucien PIAT
# For: Project Pangenoak
# Date: January 6, 2025

# Usage: ./hifiasm_call.sh mode purge_force threads input [run_1] [run_2]

MODE=$1
PURGE_FORCE=$2
THREADS=$3
INPUT=$4
RUN_1=$5
RUN_2=$6
PREFIX=$7
OUT1=$8
OUT2=$9

echo "Asm4pg -> Given hifiasm parameters:"
echo "  MODE: $MODE"
echo "  PURGE_FORCE: $PURGE_FORCE"
echo "  THREADS: $THREADS"
echo "  INPUT: $INPUT"
echo "  RUN_1: $RUN_1"
echo "  RUN_2: $RUN_2"
echo "  PREFIX: $PREFIX"

# Check if input files are FASTQ.GZ (for Hi-C mode preprocessing)
if [[ "$MODE" == "hi-c" && "$RUN_1" == *.fastq.gz && "$RUN_2" == *.fastq.gz ]]; then
    echo "Asm4pg -> Running fastp for Hi-C read preprocessing..."
    
    fastp -i ${RUN_1} -I ${RUN_2} -o ${PREFIX}_clean_HiC_R1.fq.gz -O ${PREFIX}_clean_HiC_R2.fq.gz -q 20 -l 50 -h ${PREFIX}_fastp_report.html -j ${PREFIX}_fastp_report.json --thread ${THREADS}
    
    echo "Asm4pg -> Hi-C reads cleaned. Proceeding to Hifiasm assembly..."
    RUN_1="${PREFIX}_clean_HiC_R1.fq.gz"
    RUN_2="${PREFIX}_clean_HiC_R2.fq.gz"
else
    echo "Asm4pg -> Skipping fastp (input files are not FASTQ.gz)"
fi

echo "Asm4pg -> Constructing hifiasm command"
# Step 2: Run Hifiasm assembly
case "$MODE" in
    default)
        echo "Asm4pg -> Running hifiasm in default mode..."
        hifiasm -l${PURGE_FORCE} -o ${PREFIX} -t ${THREADS} ${INPUT}
        echo "Asm4pg -> Hifiasm assembly done"
        echo "Asm4pg -> Cleaning assembly output files"
        mv ${PREFIX}.bp.hap1.p_ctg.gfa ${OUT1}
        mv ${PREFIX}.bp.hap2.p_ctg.gfa ${OUT2}
        rm ${PREFIX}*
        ;;
    hi-c)
        echo "Asm4pg -> Running hifiasm in hi-c mode..."
        hifiasm -l${PURGE_FORCE} -o ${PREFIX} -t ${THREADS} --h1 ${RUN_1} --h2 ${RUN_2} ${INPUT}
        
        echo "Asm4pg -> Renaming hifiasm output files"
        mv ${PREFIX}.hic.hap1.p_ctg.gfa ${PREFIX}.hap1.p_ctg.gfa 
        mv ${PREFIX}.hic.hap2.p_ctg.gfa ${PREFIX}.hap2.p_ctg.gfa

        echo "Asm4pg -> Converting GFA to FASTA for scaffolding"
        awk '$1 == "S" {print ">" $2 "\n" $3}' ${PREFIX}.hap1.p_ctg.gfa > ${PREFIX}.hap1.p_ctg.fasta
        awk '$1 == "S" {print ">" $2 "\n" $3}' ${PREFIX}.hap2.p_ctg.gfa > ${PREFIX}.hap2.p_ctg.fasta
        
        echo "Asm4pg -> Indexing FASTA files with samtools"
        samtools faidx ${PREFIX}.hap1.p_ctg.fasta
        samtools faidx ${PREFIX}.hap2.p_ctg.fasta
        
        # Step 3: Align Hi-C reads to contigs
        echo "Asm4pg -> Indexing FASTA file with bwa"
        bwa index ${PREFIX}.hap1.p_ctg.fasta
        bwa index ${PREFIX}.hap2.p_ctg.fasta

        echo "Asm4pg -> Aligning Hi-C reads to contigs"
        bwa mem -5SP -t ${THREADS} ${PREFIX}.hap1.p_ctg.fasta ${RUN_1} ${RUN_2} | samtools view -Sb - | samtools sort -@ ${THREADS} -o ${PREFIX}_hap1_hic_aligned.bam
        bwa mem -5SP -t ${THREADS} ${PREFIX}.hap2.p_ctg.fasta ${RUN_1} ${RUN_2} | samtools view -Sb - | samtools sort -@ ${THREADS} -o ${PREFIX}_hap2_hic_aligned.bam

        echo "Asm4pg -> Indexing BAM files with samtools"
        samtools index ${PREFIX}_hap1_hic_aligned.bam
        samtools index ${PREFIX}_hap2_hic_aligned.bam

        # Step 4: Run YAHS for scaffolding
        echo "Asm4pg -> Running YAHS for scaffolding"
        yahs ${PREFIX}.hap1.p_ctg.fasta ${PREFIX}_hap1_hic_aligned.bam -o ${PREFIX}_hap1
        yahs ${PREFIX}.hap2.p_ctg.fasta ${PREFIX}_hap2_hic_aligned.bam -o ${PREFIX}_hap2
        echo "Asm4pg -> YAHS scaffolding completed."

        echo "Asm4pg -> Cleaning assembly output files"
        mv ${PREFIX}.hap1.p_ctg.gfa ${OUT1}
        mv ${PREFIX}.hap2.p_ctg.gfa ${OUT2}
        rm ${PREFIX}*.agp
        rm ${PREFIX}*.bin
        rm ${PREFIX}*.amb
        rm ${PREFIX}*.ann
        rm ${PREFIX}*.fai
        rm ${PREFIX}*.bwt
        rm ${PREFIX}*.pac
        rm ${PREFIX}*.sa
        rm ${PREFIX}*.fasta
        rm ${PREFIX}*.lowQ.bed
        rm ${PREFIX}*.gfa
        ;;
    trio)
        echo "Asm4pg -> Hifiasm called in trio mode..."
        echo "Asm4pg -> Generating yak file for parent 1 ($RUN_1)"
        yak count -k31 -b37 -t16 -o ${PREFIX}_parent1.yak ${RUN_1}
        echo "Asm4pg -> Generating yak file for parent 2 ($RUN_2)"
        yak count -k31 -b37 -t16 -o ${PREFIX}_parent2.yak ${RUN_2}
        echo "Asm4pg -> Running hifiasm in trio mode..."
        hifiasm -o ${PREFIX} -t ${THREADS} -1 ${PREFIX}_parent1.yak -2 ${PREFIX}_parent2.yak ${INPUT}
        echo "Asm4pg -> Renaming hifiasm output files"
        mv ${PREFIX}.dip.hap1.p_ctg.gfa ${PREFIX}.bp.hap1.p_ctg.gfa 
        mv ${PREFIX}.dip.hap2.p_ctg.gfa ${PREFIX}.bp.hap2.p_ctg.gfa
        echo "Asm4pg -> Hifiasm assembly done"
        echo "Asm4pg -> Cleaning assembly output files"
        mv ${PREFIX}.bp.hap1.p_ctg.gfa ${OUT1}
        mv ${PREFIX}.bp.hap2.p_ctg.gfa ${OUT2}
        rm ${PREFIX}*
        ;;
    *)
        echo "Asm4pg -> Unknown hifiasm mode: $MODE"
        ;;
esac
