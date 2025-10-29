#!/bin/bash

# ============================================================
# Script: manage_downsampling.sh
# Purpose: Manage read downsampling with mode awareness
# Authors: MG, SSB
# Date: 24 September, 2025
# ============================================================

set -euo pipefail

# --- Argument assignment ---
RUN_BOOL="$1"
INPUT_FASTA="$2"
INPUT_FASTQ="$3"
GENOMESCOPE_SUMMARY="$4"
COVERAGE="$5"
THREADS="$6"
WORK_DIR="$7"
FINAL_DOWNSAMPLED_FASTA="$8"
FINAL_DOWNSAMPLED_FASTQ="$9"
FINAL_LONGREADS_FASTA="${10}"
FINAL_LONGREADS_FASTQ="${11}"
MODE="${12}"

USER_SCRIPT="./workflow/scripts/script_downsampling.sh"

# --- Conditional execution ---
if [[ "$RUN_BOOL" == "True" ]]; then
    echo "Asm4pg -> Starting reads downsampling to ${COVERAGE}x"
    echo "Asm4pg -> Mode: $MODE"
    
    # Determine which file to process based on mode
    if [[ "$MODE" == "ont" ]]; then
        # ONT mode: process FASTQ to preserve quality scores
        echo "Asm4pg -> ONT mode: processing FASTQ file"
        
        # Check if FASTQ has actual content
        if [[ ! -s "$INPUT_FASTQ" ]] || [[ $(zcat "$INPUT_FASTQ" 2>/dev/null | head -c 1 | wc -c) -eq 0 ]]; then
            echo "ERROR: FASTQ file is empty but ONT mode requires FASTQ with quality scores" >&2
            exit 1
        fi
        
        # Run downsampling on FASTQ
        bash "$USER_SCRIPT" \
            -i "$INPUT_FASTQ" \
            -o "$WORK_DIR" \
            -g "$GENOMESCOPE_SUMMARY" \
            -c "$COVERAGE" \
            -t "$THREADS"
        
        # Find and move FASTQ outputs
        DOWNSAMPLED_FILE=$(ls "$WORK_DIR"/*_downsampled_"${COVERAGE}"x.fastq.gz 2>/dev/null || true)
        LONGREADS_FILE=$(ls "$WORK_DIR"/*_longreads_*.fastq.gz 2>/dev/null || true)
        
        if [[ -z "$DOWNSAMPLED_FILE" ]]; then
            echo "ERROR: No downsampled FASTQ found in $WORK_DIR" >&2
            exit 1
        fi
        
        mv "$DOWNSAMPLED_FILE" "$FINAL_DOWNSAMPLED_FASTQ"
        
        if [[ -n "$LONGREADS_FILE" ]]; then
            mv "$LONGREADS_FILE" "$FINAL_LONGREADS_FASTQ"
        else
            echo "" | gzip > "$FINAL_LONGREADS_FASTQ"
        fi
        
        # Convert to FASTA for QC tools
        echo "Asm4pg -> Converting downsampled FASTQ to FASTA for QC"
        zcat "$FINAL_DOWNSAMPLED_FASTQ" | awk 'NR%4==1{sub("^@", ">", $0); print} NR%4==2{print}' | gzip > "$FINAL_DOWNSAMPLED_FASTA"
        if [[ -s "$FINAL_LONGREADS_FASTQ" ]] && [[ $(zcat "$FINAL_LONGREADS_FASTQ" 2>/dev/null | head -c 1 | wc -c) -gt 0 ]]; then
            zcat "$FINAL_LONGREADS_FASTQ" | awk 'NR%4==1{sub("^@", ">", $0); print} NR%4==2{print}' | gzip > "$FINAL_LONGREADS_FASTA"
        else
            echo "" | gzip > "$FINAL_LONGREADS_FASTA"
        fi
        
    else
        # Non-ONT mode: process FASTA
        echo "Asm4pg -> Non-ONT mode: processing FASTA file"
        
        # Run downsampling on FASTA
        bash "$USER_SCRIPT" \
            -i "$INPUT_FASTA" \
            -o "$WORK_DIR" \
            -g "$GENOMESCOPE_SUMMARY" \
            -c "$COVERAGE" \
            -t "$THREADS"
        
        # Find and move outputs (they're named .fastq.gz but contain FASTA)
        DOWNSAMPLED_FILE=$(ls "$WORK_DIR"/*_downsampled_"${COVERAGE}"x.fastq.gz 2>/dev/null || true)
        LONGREADS_FILE=$(ls "$WORK_DIR"/*_longreads_*.fastq.gz 2>/dev/null || true)
        
        if [[ -z "$DOWNSAMPLED_FILE" ]]; then
            echo "ERROR: No downsampled reads found in $WORK_DIR" >&2
            exit 1
        fi
        
        mv "$DOWNSAMPLED_FILE" "$FINAL_DOWNSAMPLED_FASTA"
        
        if [[ -n "$LONGREADS_FILE" ]]; then
            mv "$LONGREADS_FILE" "$FINAL_LONGREADS_FASTA"
        else
            echo "" | gzip > "$FINAL_LONGREADS_FASTA"
        fi
        
        # Create empty FASTQ placeholders
        echo "" | gzip > "$FINAL_DOWNSAMPLED_FASTQ"
        echo "" | gzip > "$FINAL_LONGREADS_FASTQ"
    fi
    
else
    echo "Asm4pg -> Skipping downsampling: copying input to output"
    cp "$INPUT_FASTA" "$FINAL_DOWNSAMPLED_FASTA"
    cp "$INPUT_FASTQ" "$FINAL_DOWNSAMPLED_FASTQ"
    echo "" | gzip > "$FINAL_LONGREADS_FASTA"
    echo "" | gzip > "$FINAL_LONGREADS_FASTQ"
fi

echo "Asm4pg -> Downsampling step finished"