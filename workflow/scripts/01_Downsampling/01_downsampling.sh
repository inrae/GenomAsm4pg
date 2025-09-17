#!/bin/bash

# Script de downsampling simple
# Usage: ./downsampling.sh -i input.fastq.gz -c 50 -l 20000

set -euo pipefail

# Valeurs par défaut
TARGET_COVERAGE=50
MIN_LENGTH=20000
INPUT_FILE=""
SEED=42

# Parsing des arguments
while getopts "i:c:l:s:h" opt; do
    case $opt in
        i) INPUT_FILE="$OPTARG";;
        c) TARGET_COVERAGE="$OPTARG";;
        l) MIN_LENGTH="$OPTARG";;
        s) SEED="$OPTARG";;
        h) echo "Usage: $0 -i input.fastq.gz [-c coverage] [-l min_length] [-s seed]"
           exit 0;;
        *) echo "Option invalide. Utilisez -h pour l'aide."; exit 1;;
    esac
done

# Vérification fichier d'entrée
[[ -z "$INPUT_FILE" ]] && { echo "Erreur: fichier d'entrée requis (-i)"; exit 1; }
[[ ! -f "$INPUT_FILE" ]] && { echo "Erreur: fichier $INPUT_FILE introuvable"; exit 1; }

# Variables
BASENAME=$(basename "$INPUT_FILE" .fastq.gz | sed 's/\.fastq$//')
WORK_DIR="/home/gmichel/work/ganoderma_african/data/processed/02_assembly/01_Downsampling/${BASENAME}_downsample_${TARGET_COVERAGE}x"
mkdir -p "$WORK_DIR"

echo "Downsampling: $INPUT_FILE vers ${TARGET_COVERAGE}X"

# Chargement modules
module load bioinfo/SeqKit/2.9.0

# Extraction du nom de l'échantillon pour récupérer la taille de génome connue
SAMPLE_NAME=$(basename "$INPUT_FILE" .fastq.gz | sed 's/20250812_//' | sed 's/_PBE91006_NBD114_PCA100302//')

# Définition des tailles de génome connues (en bp)
case "$SAMPLE_NAME" in
    "CAM_barcode14") GENOME_SIZE=46920000 ;;
    "GHA_barcode15") GENOME_SIZE=53710000 ;;
    "NIGB_barcode16") GENOME_SIZE=49650000 ;;
    "NIGC_barcode17") GENOME_SIZE=48360000 ;;
    "RDC_barcode18") GENOME_SIZE=48430000 ;;
    "RDC1_barcode19") GENOME_SIZE=48770000 ;;
    "ST158_barcode20") GENOME_SIZE=44890000 ;;
    "ST142_barcode21") GENOME_SIZE=49270000 ;;
    "unclassified_noBarcode") GENOME_SIZE=48000000 ;; # Estimation par défaut
    *) 
        echo "Échantillon $SAMPLE_NAME non reconnu, utilisation de 48 Mb par défaut"
        GENOME_SIZE=48000000
        ;;
esac

echo "Échantillon: $SAMPLE_NAME"
echo "Genome size (connu): ${GENOME_SIZE} bp"

# Calcul couverture actuelle
TOTAL_BASES=$(zcat "$INPUT_FILE" | awk 'NR%4==2{bases+=length($0)}END{print bases}')
CURRENT_COV=$(echo "scale=2; $TOTAL_BASES / $GENOME_SIZE" | bc -l)
echo "Couverture actuelle: ${CURRENT_COV}X"

# Calcul fraction
FRACTION=$(echo "scale=6; $TARGET_COVERAGE / $CURRENT_COV" | bc -l)
echo "Fraction: $FRACTION"

# Downsampling
OUTPUT_DOWN="${WORK_DIR}/${BASENAME}_${TARGET_COVERAGE}x.fastq.gz"
OUTPUT_REST="${WORK_DIR}/${BASENAME}_reste.fastq.gz"
OUTPUT_LONG="${WORK_DIR}/${BASENAME}_longreads_${MIN_LENGTH}bp.fastq.gz"

echo "Downsampling avec seqkit..."
seqkit sample -p "$FRACTION" -s "$SEED" "$INPUT_FILE" -o "$OUTPUT_DOWN"

# Extraction reads non sélectionnés
echo "Extraction reads exclus..."
seqkit seq -n "$OUTPUT_DOWN" > "${WORK_DIR}/selected_ids.txt"
seqkit grep -v -f "${WORK_DIR}/selected_ids.txt" "$INPUT_FILE" -o "$OUTPUT_REST"

# Extraction long reads
echo "Extraction long reads..."
seqkit seq -m "$MIN_LENGTH" "$OUTPUT_REST" -o "$OUTPUT_LONG"

# Vérification
DOWNSAMPLED_BASES=$(zcat "$OUTPUT_DOWN" | awk 'NR%4==2{bases+=length($0)}END{print bases}')
ACTUAL_COV=$(echo "scale=2; $DOWNSAMPLED_BASES / $GENOME_SIZE" | bc -l)
echo "Couverture obtenue: ${ACTUAL_COV}X"

# Génération du résumé
SUMMARY_FILE="${WORK_DIR}/downsampling_summary.txt"
echo "=== RÉSUMÉ DOWNSAMPLING ===" > "$SUMMARY_FILE"
echo "Fichier d'entrée: $INPUT_FILE" >> "$SUMMARY_FILE"
echo "Date: $(date)" >> "$SUMMARY_FILE"
echo "Seed utilisé: $SEED" >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"
echo "=== PARAMÈTRES ===" >> "$SUMMARY_FILE"
echo "Échantillon: $SAMPLE_NAME" >> "$SUMMARY_FILE"
echo "Couverture cible: ${TARGET_COVERAGE}X" >> "$SUMMARY_FILE"
echo "Longueur minimale: ${MIN_LENGTH} bp" >> "$SUMMARY_FILE"
echo "Taille génome (connue): ${GENOME_SIZE} bp" >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"
echo "=== STATISTIQUES ===" >> "$SUMMARY_FILE"
echo "Total bases original: ${TOTAL_BASES} bp" >> "$SUMMARY_FILE"
echo "Couverture actuelle: ${CURRENT_COV}X" >> "$SUMMARY_FILE"
echo "Fraction utilisée: $FRACTION" >> "$SUMMARY_FILE"
echo "Bases downsamplées: ${DOWNSAMPLED_BASES} bp" >> "$SUMMARY_FILE"
echo "Couverture obtenue: ${ACTUAL_COV}X" >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"
echo "=== FICHIERS GÉNÉRÉS ===" >> "$SUMMARY_FILE"
echo "Downsamplé: $(basename "$OUTPUT_DOWN")" >> "$SUMMARY_FILE"
echo "Reads exclus: $(basename "$OUTPUT_REST")" >> "$SUMMARY_FILE"
echo "Long reads: $(basename "$OUTPUT_LONG")" >> "$SUMMARY_FILE"

# Nettoyage
rm -f "${WORK_DIR}/selected_ids.txt"

echo "Terminé! Résultats dans: $WORK_DIR"
echo "Résumé: $SUMMARY_FILE"