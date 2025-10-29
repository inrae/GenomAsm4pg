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
    echo "🔹 Asm4pg -> ONT mode detected, producing both FASTQ (for assembly) and FASTA (for QC)"
else
    echo "🔹 Asm4pg -> Non-ONT mode, producing FASTA only, creating empty FASTQ placeholder"
fi

# Handle different file extensions
case "$EXTENSION" in
    fa.gz|fasta.gz)
        if [[ "$MODE" == "ont" ]]; then
            echo "❌ Asm4pg -> ERROR: In ONT mode, FASTQ input is required (need quality scores)"
            exit 1
        fi
        echo "🔹 Asm4pg -> No conversion needed for .fasta.gz or .fa.gz, copying"
        cp "$INPUT_FILE" "$OUTPUT_FA"
        # Create empty placeholder for non-ONT modes
        echo "" | gzip > "$OUTPUT_FQ"
        ;;

    fq.gz|fastq.gz)
        echo "🔹 Asm4pg -> Converting FastQ to Fasta (gzipped)"
        zcat "$INPUT_FILE" | awk 'NR%4==1{sub(":.*", "", $0); print ">" substr($0,2)} NR%4==2{print}' | pigz -p "$THREADS" > "$OUTPUT_FA"
        if [[ "$MODE" == "ont" ]]; then
            echo "🔹 Asm4pg -> Copying FastQ input for ONT assembly"
            cp "$INPUT_FILE" "$OUTPUT_FQ"
        else
            echo "🔹 Asm4pg -> Creating empty FASTQ placeholder for non-ONT mode"
            echo "" | gzip > "$OUTPUT_FQ"
        fi
        ;;

    fasta|fa)
        if [[ "$MODE" == "ont" ]]; then
            echo "❌ Asm4pg -> ERROR: In ONT mode, FASTQ input is required (need quality scores)"
            exit 1
        fi
        echo "🔹 Asm4pg -> Compressing .fasta or .fa file"
        pigz -p "$THREADS" -c "$INPUT_FILE" > "$OUTPUT_FA"
        # Create empty placeholder for non-ONT modes
        echo "" | gzip > "$OUTPUT_FQ"
        ;;

    fastq|fq)
        echo "🔹 Asm4pg -> Converting FastQ to Fasta and handling based on mode"
        awk 'NR%4==1{sub(":.*", "", $0); print ">" substr($0,2)} NR%4==2{print}' "$INPUT_FILE" | pigz -p "$THREADS" > "$OUTPUT_FA"
        if [[ "$MODE" == "ont" ]]; then
            echo "🔹 Asm4pg -> Compressing FastQ for ONT assembly"
            pigz -p "$THREADS" -c "$INPUT_FILE" > "$OUTPUT_FQ"
        else
            echo "🔹 Asm4pg -> Creating empty FASTQ placeholder for non-ONT mode"
            echo "" | gzip > "$OUTPUT_FQ"
        fi
        ;;
downsampling
    bam)
        echo "🔹 Asm4pg -> Converting BAM to FASTA"
        samtools fasta -@ "$THREADS" "$INPUT_FILE" | pigz -p "$THREADS" > "$OUTPUT_FA"
        if [[ "$MODE" == "ont" ]]; then
            echo "🔹 Asm4pg -> Converting BAM to FASTQ for ONT mode"
            samtools fastq -@ "$THREADS" "$INPUT_FILE" | pigz -p "$THREADS" > "$OUTPUT_FQ"
        else
            echo "🔹 Asm4pg -> Creating empty FASTQ placeholder for non-ONT mode"
            echo "" | gzip > "$OUTPUT_FQ"
        fi
        ;;

    *)
        echo "❌ Asm4pg -> Unsupported file format: $INPUT_FILE"
        exit 1
        ;;
esac

echo "✅ Asm4pg -> Processing completed"
echo "   FASTA output: $OUTPUT_FA (always created)"
echo "   FASTQ output: $OUTPUT_FQ ($(if [[ "$MODE" == "ont" ]]; then echo "real file for ONT"; else echo "empty placeholder"; fi))"