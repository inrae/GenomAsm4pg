#!/bin/bash

#================================================================
# Script de downsampling avec estimation de la taille du génome
# Auteur  : MG, SSB
#================================================================
# Étapes du pipeline :
#   1. Comptage des k-mers avec Jellyfish
#   2. Estimation de la taille du génome avec GenomeScope
#   3. Calcul de la couverture actuelle et détermination du ratio
#   4. Sous-échantillonnage des reads avec SeqKit
#   5. Extraction des reads longs (>= MIN_LENGTH)
#   6. Génération d’un résumé et nettoyage
#================================================================

set -euo pipefail

# --- Paramètres par défaut ---
TARGET_COVERAGE=50
MIN_LENGTH=20000
KMER_SIZE=21
PLOIDY=1
THREADS=8
SEED=42
INPUT_FILE=""
OUTPUT_DIR=""

usage() {
    echo "Usage: $0 -i <input.fastq.gz> -o <output_dir> [options]"
    echo "Options:"
    echo "  -c <int>   Couverture cible (défaut: 50)"
    echo "  -k <int>   Taille des k-mers (défaut: 21)"
    echo "  -p <int>   Ploïdie (défaut: 1)"
    echo "  -l <int>   Longueur min pour extraction des reads longs (défaut: 20000)"
    echo "  -t <int>   Threads (défaut: 8)"
    echo "  -h         Aide"
    exit 1
}

while getopts "i:o:c:k:p:l:t:h" opt; do
    case ${opt} in
        i) INPUT_FILE="$OPTARG" ;;
        o) OUTPUT_DIR="$OPTARG" ;;
        c) TARGET_COVERAGE="$OPTARG" ;;
        k) KMER_SIZE="$OPTARG" ;;
        p) PLOIDY="$OPTARG" ;;
        l) MIN_LENGTH="$OPTARG" ;;
        t) THREADS="$OPTARG" ;;
        h) usage ;;
        *) usage ;;
    esac
done

# Vérifications
if [[ -z "$INPUT_FILE" || -z "$OUTPUT_DIR" ]]; then
    echo "Erreur: -i et -o sont obligatoires."
    usage
fi
if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Erreur: fichier d’entrée introuvable : $INPUT_FILE"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

# Nettoyage du nom de fichier
BASE_WITH_DOTS=$(basename "$INPUT_FILE" .fastq.gz)
BASENAME=${BASE_WITH_DOTS//./_}

# Fichiers intermédiaires / résultats
JELLYFISH_DB="${OUTPUT_DIR}/${BASENAME}_k${KMER_SIZE}.jf"
JELLYFISH_HISTO="${OUTPUT_DIR}/${BASENAME}_k${KMER_SIZE}.histo"
GENOMESCOPE_DIR="${OUTPUT_DIR}/genomescope_k${KMER_SIZE}"
OUTPUT_DOWNSAMPLED="${OUTPUT_DIR}/${BASENAME}_downsampled_${TARGET_COVERAGE}x.fastq.gz"
OUTPUT_LONGREADS="${OUTPUT_DIR}/${BASENAME}_longreads_${MIN_LENGTH}bp.fastq.gz"
SUMMARY_FILE="${OUTPUT_DIR}/summary_downsampling.txt"

echo "=== Étape 1: Comptage des k-mers avec Jellyfish (k=$KMER_SIZE) ==="
jellyfish count -m "$KMER_SIZE" -s 100M -t "$THREADS" -C -o "$JELLYFISH_DB" <(zcat "$INPUT_FILE")
jellyfish histo -h 1000000 -t "$THREADS" "$JELLYFISH_DB" > "$JELLYFISH_HISTO"

echo "=== Étape 2: Estimation de la taille du génome avec GenomeScope ==="
mkdir -p "$GENOMESCOPE_DIR"
genomescope.R -k "$KMER_SIZE" -i "$JELLYFISH_HISTO" -o "$GENOMESCOPE_DIR" -p "$PLOIDY"
GENOMESCOPE_SUMMARY="${GENOMESCOPE_DIR}/summary.txt"

# Parsing des résultats
ESTIMATED_GENOME_SIZE=$(awk '/Genome Haploid Length/ {gsub(/,/, "", $4); print $4}' "$GENOMESCOPE_SUMMARY")
if [[ -z "$ESTIMATED_GENOME_SIZE" ]]; then
    echo "Erreur: taille du génome non trouvée dans $GENOMESCOPE_SUMMARY"
    exit 1
fi
TOTAL_BASES=$(zcat "$INPUT_FILE" | awk 'NR%4==2{bases+=length($0)}END{print bases}')
CURRENT_COV=$(echo "scale=2; $TOTAL_BASES / $ESTIMATED_GENOME_SIZE" | bc -l)
FRACTION=$(echo "scale=6; $TARGET_COVERAGE / $CURRENT_COV" | bc -l)
if (( $(echo "$FRACTION > 1" | bc -l) )); then
    FRACTION=1.0
fi

echo "=== Étape 3: Sous-échantillonnage avec SeqKit ==="
seqkit sample -p "$FRACTION" -s "$SEED" "$INPUT_FILE" | gzip > "$OUTPUT_DOWNSAMPLED"

echo "=== Étape 4: Extraction des longs reads (>= $MIN_LENGTH bp) ==="
SELECTED_IDS_TMP="${OUTPUT_DIR}/selected_ids.tmp.txt"
REST_READS_TMP="${OUTPUT_DIR}/rest_reads.tmp.fastq.gz"
if [ -s "$OUTPUT_DOWNSAMPLED" ]; then
    seqkit seq -n "$OUTPUT_DOWNSAMPLED" > "$SELECTED_IDS_TMP"
    seqkit grep -v -f "$SELECTED_IDS_TMP" "$INPUT_FILE" | gzip > "$REST_READS_TMP"
    seqkit seq -m "$MIN_LENGTH" "$REST_READS_TMP" | gzip > "$OUTPUT_LONGREADS"
else
    seqkit seq -m "$MIN_LENGTH" "$INPUT_FILE" | gzip > "$OUTPUT_LONGREADS"
fi

echo "=== Étape 5: Résumé ==="
DOWNSAMPLED_BASES=$(zcat "$OUTPUT_DOWNSAMPLED" | awk 'NR%4==2{bases+=length($0)}END{print bases}')
FINAL_COV=$(echo "scale=2; $DOWNSAMPLED_BASES / $ESTIMATED_GENOME_SIZE" | bc -l)

{
    echo "Résumé du downsampling"
    echo "======================"
    echo "Fichier d'entrée      : $INPUT_FILE"
    echo "Taille du génome (bp) : $ESTIMATED_GENOME_SIZE"
    echo "Couverture initiale   : ${CURRENT_COV}X"
    echo "Couverture cible      : ${TARGET_COVERAGE}X"
    echo "Couverture obtenue    : ${FINAL_COV}X"
    echo "Bases originales      : ${TOTAL_BASES}"
    echo "Bases downsamplées    : ${DOWNSAMPLED_BASES}"
    echo "Seed utilisé          : ${SEED}"
} > "$SUMMARY_FILE"

rm -f "$JELLYFISH_DB" "$SELECTED_IDS_TMP" "$REST_READS_TMP"

echo "Pipeline terminé. Résultats disponibles dans : $OUTPUT_DIR"
