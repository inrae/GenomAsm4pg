#!/bin/bash

# ============================================================
# Script : manage_downsampling.sh
# Objectif : Gérer le sous-échantillonnage des reads via Snakemake
# Auteur   : MG, SSB
# Date     : 24 Septembre, 2025
# ============================================================

set -euo pipefail  # Arrêt si erreur, variable non définie, ou pipe cassé

# --- Assignation des arguments ---
RUN_BOOL="$1"                # Booléen -> "True" ou "False"
INPUT_READS="$2"             # Fichier FASTQ en entrée
COVERAGE="$3"                # Couverture cible (ex: 50)
KMER_SIZE="$4"               # Taille des k-mers
PLOIDY="$5"                  # Ploïdie (ex: 2)
THREADS="$6"                 # Nombre de threads
WORK_DIR="$7"                # Répertoire temporaire de travail
FINAL_DOWNSAMPLED_OUT="$8"   # Fichier final downsampled attendu
FINAL_LONGREADS_OUT="$9"     # Fichier final longreads attendu
USER_SCRIPT="./workflow/scripts/script_downsampling.sh" # Script original utilisateur

# --- Exécution conditionnelle ---
if [[ "$RUN_BOOL" == "True" ]]; then
    echo "Asm4pg -> Starting reads downsampling to ${COVERAGE}x."

    # Lancement du script utilisateur
    bash "$USER_SCRIPT" \
        -i "$INPUT_READS" \
        -o "$WORK_DIR" \
        -c "$COVERAGE" \
        -k "$KMER_SIZE" \
        -p "$PLOIDY" \
        -t "$THREADS"

    # Vérifie que les sorties existent
    echo "Asm4pg -> Checking for expected outputs."
    DOWNSAMPLED_FILE=$(ls "$WORK_DIR"/*_downsampled_"${COVERAGE}"x.fastq.gz 2>/dev/null || true)
    LONGREADS_FILE=$(ls "$WORK_DIR"/*_longreads_*.fastq.gz 2>/dev/null || true)

    if [[ -z "$DOWNSAMPLED_FILE" ]]; then
        echo "ERROR: No downsampled reads found in $WORK_DIR" >&2
        exit 1
    fi
    if [[ -z "$LONGREADS_FILE" ]]; then
        echo "ERROR: No longreads file found in $WORK_DIR" >&2
        exit 1
    fi

    # Déplace les sorties à l’endroit attendu par Snakemake
    echo "Asm4pg -> Moving outputs to final destination."
    mv "$DOWNSAMPLED_FILE" "$FINAL_DOWNSAMPLED_OUT"
    mv "$LONGREADS_FILE" "$FINAL_LONGREADS_OUT"

else
    echo "Asm4pg -> Skipping downsampling. Copying input to output."
    cp "$INPUT_READS" "$FINAL_DOWNSAMPLED_OUT"
    touch "$FINAL_LONGREADS_OUT" # Crée un fichier vide pour Snakemake
fi

echo "Asm4pg -> Downsampling step finished."
