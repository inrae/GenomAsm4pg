#!/bin/bash

#==============================================================
# Workflow : Séparation des reads mitochondriaux et nucléaires
# Usage : ./workflow_sep_mito.sh -i input.fastq.gz -o output_dir -r reference_mito.fasta
#==============================================================

set -e

# --- Options ---
INPUT_FILE=""
OUTPUT_DIR=""
MITO_REFERENCE=""
THREADS=4
MINIMAP2_PRESET="map-ont"   # ajuster selon les données (map-hifi, map-ont, sr)

while getopts "i:o:r:t:h" opt; do
    case $opt in
        i) INPUT_FILE="$OPTARG" ;;
        o) OUTPUT_DIR="$OPTARG" ;;
        r) MITO_REFERENCE="$OPTARG" ;;
        t) THREADS="$OPTARG" ;;
        h) echo "Usage: $0 -i input.fastq.gz -o output_dir -r reference_mito.fasta [-t threads]"
           exit 0 ;;
        *) echo "Option invalide"; exit 1 ;;
    esac
done

# --- Vérifications ---
if [[ -z "$INPUT_FILE" ]]; then echo "Erreur: fichier d'entrée requis (-i)"; exit 1; fi
if [[ -z "$OUTPUT_DIR" ]]; then echo "Erreur: répertoire de sortie requis (-o)"; exit 1; fi
if [[ -z "$MITO_REFERENCE" ]]; then echo "Erreur: référence mitochondriale requise (-r)"; exit 1; fi
if [[ ! -f "$INPUT_FILE" ]]; then echo "Erreur: fichier $INPUT_FILE introuvable"; exit 1; fi
if [[ ! -f "$MITO_REFERENCE" ]]; then echo "Erreur: fichier $MITO_REFERENCE introuvable"; exit 1; fi

# --- Répertoires ---
SEPARATION_DIR="$OUTPUT_DIR/01_separation"
mkdir -p "$SEPARATION_DIR"

echo "Input          : $INPUT_FILE"
echo "Output dir     : $OUTPUT_DIR"
echo "Threads        : $THREADS"
echo "Preset minimap2: $MINIMAP2_PRESET"
echo ""

# --- Fichiers de sortie ---
MITO_IDS="$SEPARATION_DIR/mito_ids.txt"
NUCLEAR_IDS="$SEPARATION_DIR/nuclear_ids.txt"
MITO_READS_GZ="$SEPARATION_DIR/reads_mito.fastq.gz"
NUCLEAR_READS_GZ="$SEPARATION_DIR/reads_nuclear.fastq.gz"
ALL_ALIGNED_SAM="$SEPARATION_DIR/all_alignments.sam"

# Étape 1 : alignement des reads
echo "[1/5] Alignement avec minimap2..."
minimap2 -ax "$MINIMAP2_PRESET" -t "$THREADS" \
    "$MITO_REFERENCE" "$INPUT_FILE" > "$ALL_ALIGNED_SAM" 2> "$SEPARATION_DIR/minimap2.log"

# Étape 2 : IDs mitochondriaux
echo "[2/5] Extraction des IDs mitochondriaux..."
samtools view -F 4 "$ALL_ALIGNED_SAM" | cut -f1 | sort -u > "$MITO_IDS"

# Étape 3 : IDs nucléaires
echo "[3/5] Extraction des IDs nucléaires..."
samtools view -f 4 "$ALL_ALIGNED_SAM" | cut -f1 | sort -u > "$NUCLEAR_IDS"

# Étape 4 : Extraction des séquences
echo "[4/5] Extraction des reads..."
if [ -s "$MITO_IDS" ]; then
    seqtk subseq "$INPUT_FILE" "$MITO_IDS" | gzip > "$MITO_READS_GZ"
else
    echo "Aucun read mitochondrial trouvé."
    touch "$MITO_READS_GZ"
fi

if [ -s "$NUCLEAR_IDS" ]; then
    seqtk subseq "$INPUT_FILE" "$NUCLEAR_IDS" | gzip > "$NUCLEAR_READS_GZ"
else
    echo "Aucun read nucléaire trouvé."
    touch "$NUCLEAR_READS_GZ"
fi

# Étape 5 : statistiques
echo "[5/5] Statistiques..."
TOTAL_READS=$(zcat "$INPUT_FILE" | awk 'END{print NR/4}')
MITO_LINES=$(zcat "$MITO_READS_GZ" 2>/dev/null | wc -l)
MITO_READS=$((MITO_LINES / 4))
NUCLEAR_LINES=$(zcat "$NUCLEAR_READS_GZ" 2>/dev/null | wc -l)
NUCLEAR_READS=$((NUCLEAR_LINES / 4))

echo "Total reads      : $TOTAL_READS"
echo "Reads mitochondriaux : $MITO_READS"
echo "Reads nucléaires     : $NUCLEAR_READS"
echo ""
echo "Résultats :"
echo " - $MITO_READS_GZ"
echo " - $NUCLEAR_READS_GZ"

# Nettoyage
rm -f "$MITO_IDS" "$NUCLEAR_IDS" "$ALL_ALIGNED_SAM"
echo "Nettoyage terminé."
