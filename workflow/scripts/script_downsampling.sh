#!/bin/bash

#================================================================
# Downsampling script with genome size from GenomeScope
# Authors: MG, SSB
#================================================================
# Pipeline steps:
#   1. Parse genome size from provided GenomeScope summary
#   2. Calculate current coverage and determine ratio
#   3. Downsample reads with SeqKit
#   4. Extract long reads (>= MIN_LENGTH)
#   5. Generate summary and cleanup
#================================================================

set -euo pipefail

# --- Default parameters ---
TARGET_COVERAGE=50
MIN_LENGTH=20000
THREADS=8
SEED=42
INPUT_FILE=""
OUTPUT_DIR=""
GENOMESCOPE_SUMMARY=""

usage() {
    echo "Usage: $0 -i <input.fastq.gz> -o <output_dir> -g <genomescope_summary.txt> [options]"
    echo "Options:"
    echo "  -g <file>  GenomeScope summary file (required)"
    echo "  -c <int>   Target coverage (default: 50)"
    echo "  -l <int>   Minimum length for long read extraction (default: 20000)"
    echo "  -t <int>   Threads (default: 8)"
    echo "  -h         Help"
    exit 1
}

while getopts "i:o:g:c:l:t:h" opt; do
    case ${opt} in
        i) INPUT_FILE="$OPTARG" ;;
        o) OUTPUT_DIR="$OPTARG" ;;
        g) GENOMESCOPE_SUMMARY="$OPTARG" ;;
        c) TARGET_COVERAGE="$OPTARG" ;;
        l) MIN_LENGTH="$OPTARG" ;;
        t) THREADS="$OPTARG" ;;
        h) usage ;;
        *) usage ;;
    esac
done

# Checks
if [[ -z "$INPUT_FILE" || -z "$OUTPUT_DIR" || -z "$GENOMESCOPE_SUMMARY" ]]; then
    echo "Error: -i, -o and -g are required."
    usage
fi
if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Error: input file not found: $INPUT_FILE"
    exit 1
fi
if [[ ! -f "$GENOMESCOPE_SUMMARY" ]]; then
    echo "Error: GenomeScope summary file not found: $GENOMESCOPE_SUMMARY"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

# Clean up filename
BASE_WITH_DOTS=$(basename "$INPUT_FILE" .fastq.gz)
# Also handle .fasta.gz files
if [[ "$BASE_WITH_DOTS" == "$INPUT_FILE" ]]; then
    BASE_WITH_DOTS=$(basename "$INPUT_FILE" .fasta.gz)
fi
BASENAME=${BASE_WITH_DOTS//./_}

# Intermediate/result files
OUTPUT_DOWNSAMPLED="${OUTPUT_DIR}/${BASENAME}_downsampled_${TARGET_COVERAGE}x.fastq.gz"
OUTPUT_LONGREADS="${OUTPUT_DIR}/${BASENAME}_longreads_${MIN_LENGTH}bp.fastq.gz"
SUMMARY_FILE="${OUTPUT_DIR}/summary_downsampling.txt"

echo "=== Step 1: Parsing genome size from GenomeScope summary ==="
# Parse results
ESTIMATED_GENOME_SIZE=$(awk '/Genome Haploid Length/ {gsub(/,/, "", $4); print $4}' "$GENOMESCOPE_SUMMARY")
if [[ -z "$ESTIMATED_GENOME_SIZE" ]]; then
    echo "Error: genome size not found in $GENOMESCOPE_SUMMARY"
    exit 1
fi
echo "Estimated genome size: $ESTIMATED_GENOME_SIZE bp"

echo "=== Step 2: Calculating current coverage and sampling fraction ==="
# Detect if input is FASTA or FASTQ
if zcat "$INPUT_FILE" 2>/dev/null | head -n1 | grep -q "^>"; then
    echo "Input detected as FASTA format"
    TOTAL_BASES=$(zcat "$INPUT_FILE" | awk '/^>/{if(seq) print length(seq); seq=""; next}{seq=seq$0}END{if(seq) print length(seq)}' | awk '{sum+=$1}END{print sum}')
else
    echo "Input detected as FASTQ format"
    TOTAL_BASES=$(zcat "$INPUT_FILE" | awk 'NR%4==2{bases+=length($0)}END{print bases}')
fi

CURRENT_COV=$(echo "scale=2; $TOTAL_BASES / $ESTIMATED_GENOME_SIZE" | bc -l)
FRACTION=$(echo "scale=6; $TARGET_COVERAGE / $CURRENT_COV" | bc -l)
if (( $(echo "$FRACTION > 1" | bc -l) )); then
    FRACTION=1.0
fi
echo "Current coverage: ${CURRENT_COV}X"
echo "Target coverage: ${TARGET_COVERAGE}X"
echo "Sampling fraction: $FRACTION"

echo "=== Step 3: Downsampling with SeqKit ==="
seqkit sample -p "$FRACTION" -s "$SEED" "$INPUT_FILE" | gzip > "$OUTPUT_DOWNSAMPLED"

echo "=== Step 4: Extracting long reads (>= $MIN_LENGTH bp) ==="
SELECTED_IDS_TMP="${OUTPUT_DIR}/selected_ids.tmp.txt"
REST_READS_TMP="${OUTPUT_DIR}/rest_reads.tmp.fastq.gz"
if [ -s "$OUTPUT_DOWNSAMPLED" ]; then
    seqkit seq -n "$OUTPUT_DOWNSAMPLED" > "$SELECTED_IDS_TMP"
    seqkit grep -v -f "$SELECTED_IDS_TMP" "$INPUT_FILE" | gzip > "$REST_READS_TMP"
    seqkit seq -m "$MIN_LENGTH" "$REST_READS_TMP" | gzip > "$OUTPUT_LONGREADS"
else
    seqkit seq -m "$MIN_LENGTH" "$INPUT_FILE" | gzip > "$OUTPUT_LONGREADS"
fi

echo "=== Step 5: Summary ==="
# Count bases in downsampled file
if zcat "$OUTPUT_DOWNSAMPLED" 2>/dev/null | head -n1 | grep -q "^>"; then
    DOWNSAMPLED_BASES=$(zcat "$OUTPUT_DOWNSAMPLED" | awk '/^>/{if(seq) print length(seq); seq=""; next}{seq=seq$0}END{if(seq) print length(seq)}' | awk '{sum+=$1}END{print sum}')
else
    DOWNSAMPLED_BASES=$(zcat "$OUTPUT_DOWNSAMPLED" | awk 'NR%4==2{bases+=length($0)}END{print bases}')
fi

FINAL_COV=$(echo "scale=2; $DOWNSAMPLED_BASES / $ESTIMATED_GENOME_SIZE" | bc -l)

{
    echo "Downsampling summary"
    echo "===================="
    echo "Input file            : $INPUT_FILE"
    echo "GenomeScope summary   : $GENOMESCOPE_SUMMARY"
    echo "Genome size (bp)      : $ESTIMATED_GENOME_SIZE"
    echo "Initial coverage      : ${CURRENT_COV}X"
    echo "Target coverage       : ${TARGET_COVERAGE}X"
    echo "Achieved coverage     : ${FINAL_COV}X"
    echo "Original bases        : ${TOTAL_BASES}"
    echo "Downsampled bases     : ${DOWNSAMPLED_BASES}"
    echo "Seed used             : ${SEED}"
} > "$SUMMARY_FILE"

# Cleanup
rm -f "$SELECTED_IDS_TMP" "$REST_READS_TMP"

echo "Pipeline completed. Results available in: $OUTPUT_DIR"
cat "$SUMMARY_FILE"