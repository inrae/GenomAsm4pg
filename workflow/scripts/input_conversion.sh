#!/bin/bash

# Author: Lucien PIAT
# Date: January 13, 2025

set -e 

INPUT_FILE="$1"
OUTPUT_FILE="$2"
THREADS="$3"

if [[ -z "$INPUT_FILE" || -z "$OUTPUT_FILE" || -z "$THREADS" ]]; then
    echo "Usage: $0 <input_file> <output_file> <threads>"
    exit 1
fi

# Get file extension
EXTENSION="${INPUT_FILE##*.}"

echo "Asm4pg -> checking if input file needs to be converted"
if [[ "$INPUT_FILE" == *.fasta.gz ]]; then
    echo "Asm4pg -> No need for conversion"
    cp "$INPUT_FILE" "$OUTPUT_FILE"

elif [[ "$INPUT_FILE" == *.fastq.gz ]]; then
    echo "Asm4pg -> Converting FastQ to Fasta"
    zcat "$INPUT_FILE" | awk 'NR%4==1{sub(":.*", "", $0); print ">" substr($0,2)} NR%4==2{print}' | pigz -p "$THREADS" > "$OUTPUT_FILE"

elif [[ "$INPUT_FILE" == *.fasta || "$INPUT_FILE" == *.fastq ]]; then
    echo "Asm4pg -> Converting and compressing input file"
    awk 'NR%4==1{sub(":.*", "", $0); print ">" substr($0,2)} NR%4==2{print}' "$INPUT_FILE" | pigz -p "$THREADS" > "$OUTPUT_FILE"

elif [[ "$INPUT_FILE" == *.bam ]]; then
    echo "Asm4pg -> Converting BAM to FASTA"
    samtools fasta -@ "$THREADS" "$INPUT_FILE" | pigz -p "$THREADS" > "$OUTPUT_FILE"

else
    echo "Asm4pg -> Unsupported file format: $INPUT_FILE"
    exit 1
fi

echo "Asm4pg -> Processing completed: $OUTPUT_FILE"
