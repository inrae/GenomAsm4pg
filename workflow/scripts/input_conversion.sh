#!/bin/bash

# Author: Lucien PIAT
# Date: January 13, 2025

set -e  # Exit on error

INPUT_FILE="$1"
OUTPUT_FA="$2"
THREADS="$3"
MODE="$4"
OUTPUT_FQ="$5"

# Get file extension after the first dot
EXTENSION="${INPUT_FILE#*.}"  # Remove everything before the first dot
EXTENSION="${EXTENSION,,}"     # Convert to lowercase

echo "🔹 Asm4pg -> Checking input file type: $INPUT_FILE"

if [[ "$MODE" == "ont" ]]; then
    echo "🔹 Asm4pg -> ONT mode detected, producing a FASTQ (assembly) file and FASTA file (QC)"
fi

# Handle different file extensions
case "$EXTENSION" in
    fa.gz|fasta.gz)
        if [[ "$MODE" == "ont" ]]; then
            echo "❌ Asm4pg -> In ONT mode, FASTQ input is required"
            exit 1
        fi
        echo "🔹 Asm4pg -> No conversion needed for .fasta.gz or .fa.gz, copying"
        cp "$INPUT_FILE" "$OUTPUT_FA"
        ;;

    fq.gz|fastq.gz)
        echo "🔹 Asm4pg -> Converting FastQ to Fasta (gzipped)"
        zcat "$INPUT_FILE" | awk 'NR%4==1{sub(":.*", "", $0); print ">" substr($0,2)} NR%4==2{print}' | pigz -p "$THREADS" > "$OUTPUT_FA"
        if [[ "$MODE" == "ont" ]]; then
            echo "🔹 Asm4pg -> Copying FastQ input to output for ONT mode"
            cp "$INPUT_FILE" "$OUTPUT_FQ"
        fi
        ;;

    fasta|fa)
        if [[ "$MODE" == "ont" ]]; then
            echo "❌ Asm4pg -> In ONT mode, FASTQ input is required"
            exit 1
        fi
        echo "🔹 Asm4pg -> Converting and compressing .fasta or .fa file"
        awk 'NR%2==1{sub(":.*", "", $0); print ">" substr($0,2)} NR%2==2{print}' "$INPUT_FILE" | pigz -p "$THREADS" > "$OUTPUT_FA"
        ;;

    fastq|fq)
        echo "🔹 Asm4pg -> Converting and compressing .fastq or .fq file"
        awk 'NR%4==1{sub(":.*", "", $0); print ">" substr($0,2)} NR%4==2{print}' "$INPUT_FILE" | pigz -p "$THREADS" > "$OUTPUT_FA"
        if [[ "$MODE" == "ont" ]]; then
            echo "🔹 Asm4pg -> Compressing FastQ input for ONT mode"
            pigz -p "$THREADS" -c "$INPUT_FILE" > "$OUTPUT_FQ"
        fi
        ;;

    bam)
        echo "🔹 Asm4pg -> Converting BAM to FASTA"
        samtools fasta -@ "$THREADS" "$INPUT_FILE" | pigz -p "$THREADS" > "$OUTPUT_FA"
        if [[ "$MODE" == "ont" ]]; then
            echo "🔹 Asm4pg -> Converting BAM to FASTQ for ONT mode"
            samtools fastq -@ "$THREADS" "$INPUT_FILE" | pigz -p "$THREADS" > "$OUTPUT_FQ"
        fi
        ;;

    *)
        echo "❌ Asm4pg -> Unsupported file format: $INPUT_FILE"
        exit 1
        ;;
esac

if [[ "$MODE" != "ont" ]]; then
    echo "🔹 Asm4pg -> ont mode off, no need for fastq file"
else
    echo "🔹 Asm4pg -> Produced FASTA.gz and FASTQ.gz files"
fi
echo "✅ Asm4pg -> Processing completed: $OUTPUT_FA"
