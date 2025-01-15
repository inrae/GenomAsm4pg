#!/bin/bash
# Script to dynamically run quast on produced genomes, with focus on basic stat plots in PNG format
# Author: Lucien PIAT
# For: Project Pangenoak
# Date: January 6, 2025

# Arguments
REFERENCE_GENOME="$1"
PURGE_BOOL="$2"
RAGTAG_BOOL="$3"
RAW_HAP1="$4"
RAW_HAP2="$5"
FINAL_HAP1="$6"
FINAL_HAP2="$7"
RAGTAG_HAP1="$8"
RAGTAG_HAP2="$9"
OUTPUT_DIR="${10}"
RESULT_DIR="$11"

# Create the list of genomes to run quast on
echo "Asm4pg -> Preparing genome list for QUAST analysis..."
genomes=("$FINAL_HAP1" "$FINAL_HAP2")
echo " - Added final haplotypes: $FINAL_HAP1, $FINAL_HAP2"

if [ "$PURGE_BOOL" == "True" ]; then
    genomes+=("$RAW_HAP1" "$RAW_HAP2")
    echo " - Purge option enabled: added raw haplotypes: $RAW_HAP1, $RAW_HAP2"
fi

if [ "$RAGTAG_BOOL" == "True" ]; then
    genomes+=("$RAGTAG_HAP1" "$RAGTAG_HAP2")
    echo " - RagTag option enabled: added RagTag haplotypes: $RAGTAG_HAP1, $RAGTAG_HAP2"
fi

# Build the quast command
echo "Asm4pg -> Building the QUAST command..."
quast_cmd="python /quast-5.2.0/metaquast.py --threads 20 --large --no-html --no-check --plots-format png "
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

# Isolating desired outputs
echo "Asm4pg -> Isolating QUAST basic stat plots..."
mkdir -p "$RESULT_DIR"
cp "$OUTPUT_DIR/combined_reference/basic_stats/cumulative_plot.png" "$RESULT_DIR/cumulative_plot.png"
cp "$OUTPUT_DIR/combined_reference/basic_stats/GC_content_plot.png" "$RESULT_DIR/GC_content_plot.png"
cp "$OUTPUT_DIR/combined_reference/basic_stats/Nx_plot.png" "$RESULT_DIR/Nx_plot.png"

# Exit status check
if [ $? -eq 0 ]; then
    echo "Asm4pg -> QUAST completed successfully."
else
    echo "Asm4pg -> ERROR: QUAST encountered an issue. Check the output for details."
    exit 1
fi
