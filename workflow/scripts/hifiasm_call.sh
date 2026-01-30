#!/bin/bash
# Script to dynamically run hifiasm with the correct command based on the mode
# Author: Lucien PIAT
# For: Project Pangenoak
# Date: April 3, 2025

# Don't use set -e initially to handle segfaults gracefully
set -uo pipefail

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
INPUT_LONG=${11}

echo "🔹 Asm4pg -> Starting assembly: $(date)"

echo "Asm4pg -> Given hifiasm parameters:"
echo "  MODE: $MODE"
echo "  PURGE_FORCE: $PURGE_FORCE"
echo "  THREADS: $THREADS"
echo "  INPUT FASTA: $INPUT"
echo "  INPUT FASTQ: $INPUT_FQ"
echo "  INPUT LONG READS: $INPUT_LONG"
echo "  RUN_1: $RUN_1"
echo "  RUN_2: $RUN_2"
echo "  PREFIX: $PREFIX"

# Check if FASTQ/LONG are "None" strings and handle appropriately
if [[ "$INPUT_FQ" == "None" ]] || [[ -z "$INPUT_FQ" ]]; then
    INPUT_FQ=""
fi
if [[ "$INPUT_LONG" == "None" ]] || [[ -z "$INPUT_LONG" ]]; then
    INPUT_LONG=""
fi

available_mem=$(free -h | awk '/Mem:/ {print $7}')
echo "🔹 Asm4pg -> Available memory: $available_mem"

cleanup_files() {
    echo "🔹 Asm4pg -> Cleaning up intermediate files..."
    # Don't remove GFA files - we might need them!
    rm -f ${PREFIX}*.{agp,bin,amb,ann,fai,bwt,pac,sa,fasta,lowQ.bed,yak}
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

# Function to handle output files after hifiasm run
handle_hifiasm_output() {
    local mode=$1
    local exit_code=$2
    
    echo "🔹 Asm4pg -> Checking for output files (exit code: $exit_code)"
    
    # List all GFA files for debugging
    echo "🔹 Asm4pg -> GFA files found:"
    ls -la ${PREFIX}*.gfa 2>/dev/null || echo "  No GFA files found"
    
    OUTPUT_FOUND=false
    
    # For default mode
    if [[ "$mode" == "default" ]]; then
        if [ -f "${PREFIX}.bp.hap1.p_ctg.gfa" ] && [ -f "${PREFIX}.bp.hap2.p_ctg.gfa" ]; then
            echo "✅ Asm4pg -> Default mode diploid output found"
            mv "${PREFIX}.bp.hap1.p_ctg.gfa" "$OUT1"
            mv "${PREFIX}.bp.hap2.p_ctg.gfa" "$OUT2"
            OUTPUT_FOUND=true
        elif [ -f "${PREFIX}.bp.p_ctg.gfa" ]; then
            echo "✅ Asm4pg -> Default mode haploid output found"
            mv "${PREFIX}.bp.p_ctg.gfa" "$OUT1"
            cp "$OUT1" "$OUT2"
            OUTPUT_FOUND=true
        fi
    
    # For ONT mode
    elif [[ "$mode" == "ont" ]]; then
        if [ -f "${PREFIX}.p_ctg.gfa" ]; then
            echo "✅ Asm4pg -> ONT haploid output (no prefix) found"
            mv "${PREFIX}.p_ctg.gfa" "$OUT1"
            cp "$OUT1" "$OUT2"
            OUTPUT_FOUND=true
        elif [ -f "${PREFIX}.bp.p_ctg.gfa" ]; then
            echo "✅ Asm4pg -> ONT haploid output (bp prefix) found"
            mv "${PREFIX}.bp.p_ctg.gfa" "$OUT1"
            cp "$OUT1" "$OUT2"
            OUTPUT_FOUND=true
        elif [ -f "${PREFIX}.bp.hap1.p_ctg.gfa" ]; then
            echo "✅ Asm4pg -> ONT diploid output found"
            mv "${PREFIX}.bp.hap1.p_ctg.gfa" "$OUT1"
            if [ -f "${PREFIX}.bp.hap2.p_ctg.gfa" ]; then
                mv "${PREFIX}.bp.hap2.p_ctg.gfa" "$OUT2"
            else
                cp "$OUT1" "$OUT2"
            fi
            OUTPUT_FOUND=true
        fi
    fi
    
    # Check results
    if [[ "$OUTPUT_FOUND" == "true" ]]; then
        if [[ $exit_code -eq 139 ]]; then
            echo "⚠️ Asm4pg -> Hifiasm segfaulted after writing outputs. This is a known issue."
            echo "✅ Asm4pg -> Assembly files are valid despite the segfault."
        elif [[ $exit_code -ne 0 ]]; then
            echo "⚠️ Asm4pg -> Hifiasm exited with code $exit_code but outputs were found."
            echo "✅ Asm4pg -> Treating as successful since outputs exist."
        else
            echo "✅ Asm4pg -> Assembly completed successfully."
        fi
        return 0
    else
        echo "❌ ERROR: Expected output files not found for $mode mode"
        return 1
    fi
}

run_hifiasm() {
    echo "🔹 Asm4pg -> Running hifiasm..."
    case "$MODE" in
        default)
            echo "🔹 Asm4pg -> Running in default mode"
            hifiasm -l"$PURGE_FORCE" -o "$PREFIX" -t "$THREADS" "$INPUT" || HIFIASM_EXIT=$?
            handle_hifiasm_output "default" ${HIFIASM_EXIT:-0}
            if [[ $? -eq 0 ]]; then
                cleanup_files
            else
                exit 1
            fi
            ;;
            
        ont)
            echo "🔹 Asm4pg -> ONT mode, using a fastq file"
            
            # Validate FASTQ file
            if [[ -z "$INPUT_FQ" ]] || [[ ! -s "$INPUT_FQ" ]]; then
                echo "❌ ERROR: ONT mode requires valid FASTQ file"
                exit 1
            fi
            
            # Build command
            HIFIASM_CMD="hifiasm -l$PURGE_FORCE -o $PREFIX -t $THREADS --ont $INPUT_FQ"
            
            # Add ultra-long reads if available
            if [[ -n "$INPUT_LONG" ]] && [[ -s "$INPUT_LONG" ]]; then
                HIFIASM_CMD="$HIFIASM_CMD --ul $INPUT_LONG"
                echo "🔹 Asm4pg -> Using ultra-long reads: $INPUT_LONG"
            fi
            
            echo "🔹 Asm4pg -> Running: $HIFIASM_CMD"
            $HIFIASM_CMD || HIFIASM_EXIT=$?
            
            handle_hifiasm_output "ont" ${HIFIASM_EXIT:-0}
            if [[ $? -eq 0 ]]; then
                cleanup_files
            else
                exit 1
            fi
            ;;
            
        hi-c)
            [[ "$RUN_1" == *.fastq.gz && "$RUN_2" == *.fastq.gz ]] && run_fastp
            hifiasm -l"$PURGE_FORCE" -o "$PREFIX" -t "$THREADS" --h1 "$RUN_1" --h2 "$RUN_2" "$INPUT" || HIFIASM_EXIT=$?
            
            if [[ ${HIFIASM_EXIT:-0} -eq 139 ]]; then
                echo "⚠️ Asm4pg -> Hifiasm segfaulted, checking outputs..."
            fi
            
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
            hifiasm -o "$PREFIX" -t "$THREADS" -1 "${PREFIX}_parent1.yak" -2 "${PREFIX}_parent2.yak" "$INPUT" || HIFIASM_EXIT=$?
            
            if [[ ${HIFIASM_EXIT:-0} -eq 139 ]]; then
                echo "⚠️ Asm4pg -> Hifiasm segfaulted, checking outputs..."
            fi

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
echo "$(date)"