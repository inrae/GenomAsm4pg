#!/bin/bash

#==============================================================
# Script for separating mitochondrial and nuclear reads
# Handles both FASTA and FASTQ based on mode
# Authors: MG, SSB
# Date: 24/09/2025
#==============================================================

set -euo pipefail

# --- Arguments ---
RUN_BOOL="$1"
INPUT_FASTA="$2"
INPUT_FASTQ="$3"
MITO_REF="$4"
THREADS="$5"
WORK_DIR="$6"            
FINAL_NUCLEAR_FASTA="$7"   
FINAL_NUCLEAR_FASTQ="$8"   
FINAL_MITO_FASTA="$9"      
FINAL_MITO_FASTQ="${10}"
MODE="${11}"

USER_SCRIPT="./workflow/scripts/workflow_sep_mito.sh"

# --- Execution ---
if [[ "$RUN_BOOL" == "True" ]]; then
    echo "Asm4pg -> Starting mitochondrial/nuclear read separation"
    echo "Asm4pg -> Mode: $MODE"
    
    # Determine which file to process based on mode
    if [[ "$MODE" == "ont" ]]; then
        # ONT mode: process FASTQ to preserve quality scores
        echo "Asm4pg -> ONT mode detected: processing FASTQ file to preserve quality scores"
        
        # Check if FASTQ has actual content
        if [[ ! -s "$INPUT_FASTQ" ]] || [[ $(zcat "$INPUT_FASTQ" 2>/dev/null | head -c 1 | wc -c) -eq 0 ]]; then
            echo "ERROR: FASTQ file is empty but ONT mode requires FASTQ with quality scores" >&2
            exit 1
        fi
        
        # Process FASTQ
        bash "$USER_SCRIPT" \
            -i "$INPUT_FASTQ" \
            -o "$WORK_DIR" \
            -r "$MITO_REF" \
            -t "$THREADS"
        
        # Move FASTQ outputs to final locations
        mv "$WORK_DIR/01_separation/reads_nuclear.fastq.gz" "$FINAL_NUCLEAR_FASTQ"
        mv "$WORK_DIR/01_separation/reads_mito.fastq.gz" "$FINAL_MITO_FASTQ"
        
        # Convert FASTQ to FASTA for QC tools that might need it
        echo "Asm4pg -> Converting separated FASTQ to FASTA for QC compatibility"
        zcat "$FINAL_NUCLEAR_FASTQ" | awk 'NR%4==1{sub("^@", ">", $0); print} NR%4==2{print}' | gzip > "$FINAL_NUCLEAR_FASTA"
        zcat "$FINAL_MITO_FASTQ" | awk 'NR%4==1{sub("^@", ">", $0); print} NR%4==2{print}' | gzip > "$FINAL_MITO_FASTA"
        
    else
        # Non-ONT mode: process FASTA
        echo "Asm4pg -> Non-ONT mode: processing FASTA file"
        
        # Process FASTA
        bash "$USER_SCRIPT" \
            -i "$INPUT_FASTA" \
            -o "$WORK_DIR" \
            -r "$MITO_REF" \
            -t "$THREADS"
        
        # Move outputs (workflow_sep_mito.sh outputs are named .fastq.gz but contain FASTA format)
        mv "$WORK_DIR/01_separation/reads_nuclear.fastq.gz" "$FINAL_NUCLEAR_FASTA"
        mv "$WORK_DIR/01_separation/reads_mito.fastq.gz" "$FINAL_MITO_FASTA"
        
        # Create empty FASTQ placeholders for pipeline consistency
        echo "" | gzip > "$FINAL_NUCLEAR_FASTQ"
        echo "" | gzip > "$FINAL_MITO_FASTQ"
    fi
    
    # Report statistics
    echo "Asm4pg -> Separation complete. Checking output files:"
    echo "  Nuclear FASTA: $(zcat "$FINAL_NUCLEAR_FASTA" 2>/dev/null | grep -c '^>' || echo 0) sequences"
    echo "  Mito FASTA: $(zcat "$FINAL_MITO_FASTA" 2>/dev/null | grep -c '^>' || echo 0) sequences"
    if [[ "$MODE" == "ont" ]]; then
        echo "  Nuclear FASTQ: $(zcat "$FINAL_NUCLEAR_FASTQ" 2>/dev/null | awk 'END{print NR/4}' || echo 0) reads"
        echo "  Mito FASTQ: $(zcat "$FINAL_MITO_FASTQ" 2>/dev/null | awk 'END{print NR/4}' || echo 0) reads"
    fi
    
else
    echo "Asm4pg -> Skipping separation: copying input files to output"
    cp "$INPUT_FASTA" "$FINAL_NUCLEAR_FASTA"
    cp "$INPUT_FASTQ" "$FINAL_NUCLEAR_FASTQ"
    
    # Create empty mitochondrial files for pipeline consistency
    echo "" | gzip > "$FINAL_MITO_FASTA"
    echo "" | gzip > "$FINAL_MITO_FASTQ"
fi

echo "Asm4pg -> Separation step finished"