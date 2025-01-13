#!/bin/bash
# Script to convert BAM or FASTQ files to FASTA.gz, and run quality control tools (LongQC or FastQC) with customizable output directories
# Author: Lucien PIAT
# Date: January 13, 2025

# Arguments
INPUT_FILE="$1"
OUTPUT_DIR="$2"
QC_OUTPUT_DIR="$3"

# Check if the output directory is specified, otherwise default to current directory
if [ -z "$OUTPUT_DIR" ]; then
    OUTPUT_DIR="."
fi

# Check if the QC output directory is specified, otherwise default to current directory
if [ -z "$QC_OUTPUT_DIR" ]; then
    QC_OUTPUT_DIR="."
fi

# Create a recap file in the output directory
RECAP_FILE="$OUTPUT_DIR/recap.txt"
echo "Recap of transformations and QC steps" > "$RECAP_FILE"
echo "=====================================" >> "$RECAP_FILE"
echo "Input file: $INPUT_FILE" >> "$RECAP_FILE"
echo "Output directory: $OUTPUT_DIR" >> "$RECAP_FILE"
echo "QC output directory: $QC_OUTPUT_DIR" >> "$RECAP_FILE"
echo "" >> "$RECAP_FILE"

# Function to convert BAM to FASTA.gz
convert_bam_to_fasta() {
    BAM_FILE="$1"
    OUTPUT_FILE="$2"

    echo "Converting BAM to FASTA: $BAM_FILE -> $OUTPUT_FILE"
    samtools fasta "$BAM_FILE" | gzip > "$OUTPUT_FILE"
    if [ $? -eq 0 ]; then
        echo "Conversion completed: $OUTPUT_FILE"
        echo "Converted BAM to FASTA: $BAM_FILE -> $OUTPUT_FILE" >> "$RECAP_FILE"
    else
        echo "Error: BAM to FASTA conversion failed!"
        exit 1
    fi
}

# Function to convert FASTQ to FASTA.gz
convert_fastq_to_fasta() {
    FASTQ_FILE="$1"
    OUTPUT_FILE="$2"

    echo "Converting FASTQ to FASTA: $FASTQ_FILE -> $OUTPUT_FILE"
    seqtk seq -a "$FASTQ_FILE" | gzip > "$OUTPUT_FILE"
    if [ $? -eq 0 ]; then
        echo "Conversion completed: $OUTPUT_FILE"
        echo "Converted FASTQ to FASTA: $FASTQ_FILE -> $OUTPUT_FILE" >> "$RECAP_FILE"
    else
        echo "Error: FASTQ to FASTA conversion failed!"
        exit 1
    fi
}

# Function to zip a FASTA file
zip_fasta() {
    FASTA_FILE="$1"
    OUTPUT_FILE="$2"

    echo "Zipping FASTA: $FASTA_FILE -> $OUTPUT_FILE"
    gzip -c "$FASTA_FILE" > "$OUTPUT_FILE"
    if [ $? -eq 0 ]; then
        echo "Zipping completed: $OUTPUT_FILE"
        echo "Zipped FASTA: $FASTA_FILE -> $OUTPUT_FILE" >> "$RECAP_FILE"
    else
        echo "Error: FASTA zipping failed!"
        exit 1
    fi
}

# Function to run LongQC on a BAM file
run_longqc() {
    BAM_FILE="$1"
    QC_OUTPUT="$2"

    echo "Running LongQC on BAM file: $BAM_FILE"
    longqc "$BAM_FILE" -o "$QC_OUTPUT"
    if [ $? -eq 0 ]; then
        echo "LongQC completed successfully. Results saved to $QC_OUTPUT"
        echo "LongQC completed on BAM: $BAM_FILE -> $QC_OUTPUT" >> "$RECAP_FILE"
    else
        echo "Error: LongQC failed!"
        exit 1
    fi
}

# Function to run FastQC on a FASTQ file
run_fastqc() {
    FASTQ_FILE="$1"
    QC_OUTPUT="$2"

    echo "Running FastQC on FASTQ file: $FASTQ_FILE"
    fastqc "$FASTQ_FILE" --outdir="$QC_OUTPUT"
    if [ $? -eq 0 ]; then
        echo "FastQC completed successfully. Results saved to $QC_OUTPUT"
        echo "FastQC completed on FASTQ: $FASTQ_FILE -> $QC_OUTPUT" >> "$RECAP_FILE"
    else
        echo "Error: FastQC failed!"
        exit 1
    fi
}

# Check file extension and process accordingly
FILE_EXTENSION="${INPUT_FILE##*.}"

# Ensure the input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file does not exist!"
    exit 1
fi

# Handle different file types
case "$FILE_EXTENSION" in
    bam)
        # If it's a BAM file, convert it to FASTA.gz and run LongQC
        OUTPUT_FILE="$OUTPUT_DIR/$(basename "$INPUT_FILE" .bam).fasta.gz"
        convert_bam_to_fasta "$INPUT_FILE" "$OUTPUT_FILE"
        run_longqc "$INPUT_FILE" "$QC_OUTPUT_DIR"
        ;;
    fastq)
        # If it's a FASTQ file, convert it to FASTA.gz and run FastQC
        OUTPUT_FILE="$OUTPUT_DIR/$(basename "$INPUT_FILE" .fastq).fasta.gz"
        if [[ "$INPUT_FILE" == *.gz ]]; then
            # If the FASTQ file is gzipped, unzip before converting
            gunzip -c "$INPUT_FILE" | seqtk seq -a | gzip > "$OUTPUT_FILE"
        else
            convert_fastq_to_fasta "$INPUT_FILE" "$OUTPUT_FILE"
        fi
        run_fastqc "$INPUT_FILE" "$QC_OUTPUT_DIR"
        ;;
    fasta)
        # If it's already a FASTA file, just zip it
        OUTPUT_FILE="$OUTPUT_DIR/$(basename "$INPUT_FILE" .fasta).fasta.gz"
        zip_fasta "$INPUT_FILE" "$OUTPUT_FILE"
        ;;
    *)
        echo "Error: Unsupported file type: $FILE_EXTENSION"
        exit 1
        ;;
esac

echo "Processing completed. Output saved to: $OUTPUT_DIR"
echo "Quality control results saved to: $QC_OUTPUT_DIR"
echo "Recap saved to: $RECAP_FILE"
