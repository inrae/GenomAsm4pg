#!/bin/bash
# Script to dynamically run quast on produced genomes, with focus on basic stat plots in PNG format
# Author: Lucien PIAT
# For: Project Pangenoak
# Date: January 6, 2025

# Arguments
REFERENCE_GENOME="$1"
PURGE_BOOL="$2"
RAW_HAP1="$3"
RAW_HAP2="$4"
FINAL_HAP1="$5"
FINAL_HAP2="$6"
OUTPUT_DIR="${7}"
RESULT_DIR="$8"

# Create the list of genomes to run quast on
echo "Asm4pg -> Preparing genome list for QUAST analysis..."
genomes=("$FINAL_HAP1" "$FINAL_HAP2")
echo " - Added final haplotypes: $FINAL_HAP1, $FINAL_HAP2"

if [ "$PURGE_BOOL" == "True" ]; then
    genomes+=("$RAW_HAP1" "$RAW_HAP2")
    echo " - Purge option enabled: added raw haplotypes: $RAW_HAP1, $RAW_HAP2"
fi

# Build the quast command
echo "Asm4pg -> Building the QUAST command..."
quast_cmd="python /quast-5.2.0/metaquast.py --threads 20 --no-read-stats --large --no-snps --no-icarus --plots-format png "
if [ "$REFERENCE_GENOME" != "None" ]; then
    echo " - Reference genome specified: $REFERENCE_GENOME"
    quast_cmd+="--reference $REFERENCE_GENOME "
fi
echo " - Genomes to process: ${genomes[@]}"
quast_cmd+="${genomes[@]} --output-dir $OUTPUT_DIR"

# Verbose: Display the constructed command
echo "Asm4pg -> Constructed QUAST command:"
echo "$quast_cmd"

# Run the quast command
echo "Asm4pg -> Running QUAST..."
eval $quast_cmd

# Exit status check
if [ $? -eq 0 ]; then
    echo "Asm4pg -> QUAST completed successfully."
else
    echo "Asm4pg -> ERROR: QUAST encountered an issue. Check the output for details."
    exit 1
fi
