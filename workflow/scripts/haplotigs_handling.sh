#!/bin/bash
# Script to dynamically handle haplotigs with the correct command based on the mode
# Author: Lucien PIAT
# For: Project Pangenoak
# Date: April 3, 2025

set -e  # Exit immediately if a command fails
trap 'echo "❌ Asm4pg -> Error encountered. Exiting." >&2' ERR

# Usage: ./haplotigs_handling.sh purge_dups_option hap1_fasta hap2_fasta hap1_output hap2_output

PURGE_DUPS=$1
HAP_IN=$2
HAP_OUT=$3
PREFIX=$4
READS=$5
DIRR=$6

cleanup_temp_files() {
    echo "🔹 Asm4pg -> Cleaning temporary files..."
    rm -f "$DIRR/dups.bed" "$DIRR/PB.cov.wig" "$DIRR/dups.bed" "$DIRR/calcuts.log" "$DIRR/purge_dups.log" "$DIRR/"*.paf.gz "$DIRR/"*split* "$DIRR/$PREFIX.purged.fa"
}

run_purge_dups() {
    echo "🔹 Asm4pg -> Running purge_dups on haplotigs..."

    echo "🔹 Asm4pg -> Running minimap2..."
    minimap2 -x asm20 "$HAP_IN" "$READS" | gzip -c - > "$DIRR/$PREFIX.paf.gz"

    echo "🔹 Asm4pg -> Running pbcstat..."
    pbcstat "$DIRR/$PREFIX.paf.gz" -O "$DIRR"

    echo "🔹 Asm4pg -> Running calcuts..."
    calcuts "$DIRR/PB.stat" > "$DIRR/cutoffs" 2> "$DIRR/calcuts.log"

    echo "🔹 Asm4pg -> Splitting assembly..."
    split_fa "$HAP_IN" > "$DIRR/$PREFIX.split"

    echo "🔹 Asm4pg -> Running minimap2 self-alignment..."
    minimap2 -x asm5 -DP "$DIRR/$PREFIX.split" "$DIRR/$PREFIX.split" | gzip -c - > "$DIRR/$PREFIX.split.self.paf.gz"

    echo "🔹 Asm4pg -> Purging haplotigs and overlaps..."
    purge_dups -2 -T "$DIRR/cutoffs" -c "$DIRR/PB.base.cov" "$DIRR/$PREFIX.split.self.paf.gz" > "$DIRR/dups.bed" 2> "$DIRR/purge_dups.log"

    echo "🔹 Asm4pg -> Extracting purged sequences..."
    get_seqs -e "$DIRR/dups.bed" "$HAP_IN" -p "$DIRR/$PREFIX"

    echo "🔹 Asm4pg -> Compressing and moving output..."
    gzip -c "$DIRR/$PREFIX.purged.fa" > "$HAP_OUT"

    cleanup_temp_files
}

echo "🔹 Asm4pg -> Starting haplotigs handling"
if [[ "$PURGE_DUPS" =~ ^(true|True|yes|Yes)$ ]]; then
    run_purge_dups
else
    echo "🔹 Asm4pg -> Purge option is false"
    cp  $HAP_IN $HAP_OUT

    echo "✅ Asm4pg -> Creating empty cutoffs file..."
    echo "No cutoffs, purge_dups is turned off" > "$DIRR/cutoffs"
fi
echo "✅ Asm4pg -> Done with haplotigs handling"
