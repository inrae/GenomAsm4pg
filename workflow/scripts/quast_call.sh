#!/bin/bash
# Script to dynamically run quast on produced genomes
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

# Create the list of genomes to run quast on
genomes=("$FINAL_HAP1" "$FINAL_HAP2")

if [ "$PURGE_BOOL" == "True" ]; then
    genomes+=("$RAW_HAP1" "$RAW_HAP2")
fi

if [ "$RAGTAG_BOOL" == "True" ]; then
    genomes+=("$RAGTAG_HAP1" "$RAGTAG_HAP2")
fi

# Build the quast command
quast_cmd="quast "
if [ "$REFERENCE_GENOME" != "None" ]; then
    quast_cmd+="--reference $REFERENCE_GENOME "
fi
quast_cmd+="${genomes[@]} --output-dir $OUTPUT_DIR"

# Run the quast command
eval $quast_cmd
