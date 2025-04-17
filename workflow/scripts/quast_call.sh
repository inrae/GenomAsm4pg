#!/bin/bash
# Script to dynamically run QUAST on produced genomes
# Author: Lucien PIAT
# For: Project Pangenoak
# Date: April 17, 2025

set -e  # Stop on error

# ============================
# Argument validation
# ============================

if [[ $# -lt 7 ]]; then
    echo "Usage: $0 <REFERENCE_GENOME> <PURGE_BOOL> <RAW_HAP1> <RAW_HAP2> <FINAL_HAP1> <FINAL_HAP2> <OUTPUT_DIR>"
    exit 1
fi

# ============================
# Input arguments
# ============================

REFERENCE_GENOME="$1"
PURGE_BOOL="$2"
RAW_HAP1="$3"
RAW_HAP2="$4"
FINAL_HAP1="$5"
FINAL_HAP2="$6"
OUTPUT_DIR="$7"

# Use all available cores
THREADS=$(nproc)
echo "🔹 Asm4pg -> Detected $THREADS threads available for QUAST"

# Optional: Check if dependencies exist
if ! command -v python &> /dev/null; then
    echo "❌ Python is not installed or not in PATH"
    exit 1
fi
if [[ ! -x "/quast-5.2.0/quast.py" ]]; then
    echo "❌ QUAST script not found at /quast-5.2.0/quast.py"
    exit 1
fi

# ============================
# Genome list construction
# ============================

echo "🔹 Asm4pg -> Preparing genome list for QUAST analysis..."

genomes=("$FINAL_HAP1" "$FINAL_HAP2")
echo " - Added final haplotypes: $FINAL_HAP1, $FINAL_HAP2"

if [[ "$PURGE_BOOL" == "True" || "$PURGE_BOOL" == "true" ]]; then
    genomes+=("$RAW_HAP1" "$RAW_HAP2")
    echo " - Purge option enabled: added raw haplotypes: $RAW_HAP1, $RAW_HAP2"
fi

# ============================
# Build QUAST command
# ============================

echo "🔹 Asm4pg -> Building the QUAST command..."

quast_cmd=(python /quast-5.2.0/quast.py)
quast_cmd+=(--threads "$THREADS")

if [[ "$REFERENCE_GENOME" != "None" && -n "$REFERENCE_GENOME" ]]; then
    echo " - Reference genome specified: $REFERENCE_GENOME"
    quast_cmd+=(--reference "$REFERENCE_GENOME")
fi

quast_cmd+=("${genomes[@]}")
quast_cmd+=(--output-dir "$OUTPUT_DIR")

echo "✅ Asm4pg -> Constructed QUAST command:"
printf ' %q' "${quast_cmd[@]}"
echo

echo "🔹 Asm4pg -> Running QUAST..."
"${quast_cmd[@]}"
echo "✅ Asm4pg -> QUAST completed successfully."
