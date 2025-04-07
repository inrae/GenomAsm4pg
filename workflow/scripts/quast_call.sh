#!/bin/bash
# Script to dynamically run QUAST on produced genomes, focusing on basic stat plots in PNG format
# Author: Lucien PIAT
# For: Project Pangenoak
# Date: January 6, 2025

set -e  # Stop on error

# Arguments
REFERENCE_GENOME="$1"
PURGE_BOOL="$2"
RAW_HAP1="$3"
RAW_HAP2="$4"
FINAL_HAP1="$5"
FINAL_HAP2="$6"
OUTPUT_DIR="${7}"
RESULT_DIR="$8"

# Use all available cores
THREADS=$(nproc)
echo "🔹 Asm4pg -> Detected $THREADS threads available for quast"

echo "🔹 Asm4pg -> Preparing genome list for QUAST analysis..."

genomes=("$FINAL_HAP1" "$FINAL_HAP2")
echo " - Added final haplotypes: $FINAL_HAP1, $FINAL_HAP2"

if [[ "$PURGE_BOOL" == "True" || "$PURGE_BOOL" == "true" ]]; then
    genomes+=("$RAW_HAP1" "$RAW_HAP2")
    echo " - Purge option enabled: added raw haplotypes: $RAW_HAP1, $RAW_HAP2"
fi

# Build QUAST command as array
echo "🔹 Asm4pg -> Building the QUAST command..."
quast_cmd=(python /quast-5.2.0/metaquast.py)
quast_cmd+=(--threads "$THREADS" --no-read-stats --large --no-snps --no-icarus --plots-format png)

if [[ "$REFERENCE_GENOME" != "None" && -n "$REFERENCE_GENOME" ]]; then
    echo " - Reference genome specified: $REFERENCE_GENOME"
    quast_cmd+=(--reference "$REFERENCE_GENOME")
fi

quast_cmd+=("${genomes[@]}")
quast_cmd+=(--output-dir "$OUTPUT_DIR")

# Show command
echo "✅ Asm4pg -> Constructed QUAST command:"
printf ' %q' "${quast_cmd[@]}"
echo

# Run QUAST
echo "🔹 Asm4pg -> Running QUAST..."
"${quast_cmd[@]}"

echo "✅ Asm4pg -> QUAST completed successfully."
