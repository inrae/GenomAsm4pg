#!/bin/bash

# Author: Lucien PIAT
# Date: January 13, 2025

set -e  # Exit on error

INPUT_FILE="$1"
OUTPUT_FILE="$2"
THREADS="$3"

# Check if required arguments are provided
if [[ -z "$INPUT_FILE" || -z "$OUTPUT_FILE" || -z "$THREADS" ]]; then
    echo "Usage: $0 <input_file> <output_file> <threads>"
    exit 1
fi

# Get file extension after the first dot
EXTENSION="${INPUT_FILE#*.}"  # Remove everything before the first dot
EXTENSION="${EXTENSION,,}"     # Convert to lowercase

echo "🔹 Asm4pg -> Checking input file type: $INPUT_FILE"

# Handle different file extensions
case "$EXTENSION" in
    fa.gz|fasta.gz)
        echo "🔹 Asm4pg -> No conversion needed for .fasta.gz or .fa.gz, copying"
        cp "$INPUT_FILE" "$OUTPUT_FILE"
        ;;

    fq.gz|fastq.gz)
        echo "🔹 Asm4pg -> Converting FastQ to Fasta (gzipped)"
        zcat "$INPUT_FILE" | awk 'NR%4==1{sub(":.*", "", $0); print ">" substr($0,2)} NR%4==2{print}' | pigz -p "$THREADS" > "$OUTPUT_FILE"
        ;;

    fasta|fa)
        echo "🔹 Asm4pg -> Converting and compressing .fasta or .fa file"
        awk 'NR%2==1{sub(":.*", "", $0); print ">" substr($0,2)} NR%2==2{print}' "$INPUT_FILE" | pigz -p "$THREADS" > "$OUTPUT_FILE"
        ;;

    fastq|fq)
        echo "🔹 Asm4pg -> Converting and compressing .fastq or .fq file"
        awk 'NR%4==1{sub(":.*", "", $0); print ">" substr($0,2)} NR%4==2{print}' "$INPUT_FILE" | pigz -p "$THREADS" > "$OUTPUT_FILE"
        ;;

    bam)
        echo "🔹 Asm4pg -> Converting BAM to FASTA"
        samtools fasta -@ "$THREADS" "$INPUT_FILE" | pigz -p "$THREADS" > "$OUTPUT_FILE"
        ;;

    *)
        echo "❌ Asm4pg -> Unsupported file format: $INPUT_FILE"
        exit 1
        ;;
esac

echo "✅ Asm4pg -> Processing completed: $OUTPUT_FILE"
