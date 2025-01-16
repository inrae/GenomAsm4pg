#!/bin/bash
# Script to convert BAM or FASTQ files to FASTA.gz
# Author: Lucien PIAT
# Date: January 13, 2025

#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 -i <input_file> -o <output_file>"
    echo "Supported input formats: .bam, .fastq, .fastq.gz"
    echo "Output will be a compressed FASTA (.fasta.gz) file."
    exit 1
}

# Parse arguments
while getopts ":i:o:" opt; do
    case $opt in
        i) input_file="$OPTARG" ;;
        o) output_file="$OPTARG" ;;
        *) usage ;;
    esac
done

# Check if input and output files are provided
if [ -z "$input_file" ] || [ -z "$output_file" ]; then
    usage
fi

# Ensure necessary tools are installed
if ! command -v samtools &> /dev/null || ! command -v seqtk &> /dev/null; then
    echo "Error: 'samtools' and 'seqtk' are required but not installed."
    exit 1
fi

# Determine the input file type and convert
case "$input_file" in
    *.bam)
        echo "Processing BAM file..."
        samtools fasta "$input_file" | gzip > "$output_file"
        ;;
    *.fastq)
        echo "Processing FASTQ file..."
        seqtk seq -A "$input_file" | gzip > "$output_file"
        ;;
    *.fastq.gz)
        echo "Processing compressed FASTQ file..."
        seqtk seq -A <(gzip -dc "$input_file") | gzip > "$output_file"
        ;;
    *)
        echo "Error: Unsupported file type. Please provide a .bam, .fastq, or .fastq.gz file."
        exit 1
        ;;
esac

# Confirm completion
echo "Conversion complete. Output written to: $output_file"
