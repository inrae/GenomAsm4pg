#!/bin/bash

#==============================================================
# Script de séparation des reads mitochondriaux et nucléaires
# Auteur : MG, SSB
# Date   : 24/09/2025
#==============================================================

set -e  # arrêt en cas d'erreur

# --- Arguments ---
RUN_BOOL="$1"
INPUT_READS="$2"
MITO_REF="$3"
THREADS="$4"
WORK_DIR="$5"            # répertoire de travail
FINAL_NUCLEAR_OUT="$6"   # sortie attendue (nucléaire)
FINAL_MITO_OUT="$7"      # sortie attendue (mitochondrial)
USER_SCRIPT="./workflow/scripts/workflow_sep_mito.sh"

# --- Exécution ---
if [[ "$RUN_BOOL" == "True" ]]; then
    echo "[INFO] Lancement de la séparation des reads mitochondriaux / nucléaires"

    bash "$USER_SCRIPT" \
        -i "$INPUT_READS" \
        -o "$WORK_DIR" \
        -r "$MITO_REF" \
        -t "$THREADS"

    echo "[INFO] Déplacement des sorties vers les fichiers finaux"
    mv "$WORK_DIR/01_separation/reads_nuclear.fastq.gz" "$FINAL_NUCLEAR_OUT"
    mv "$WORK_DIR/01_separation/reads_mito.fastq.gz" "$FINAL_MITO_OUT"

else
    echo "[INFO] Étape ignorée : copie directe des reads en sortie"
    cp "$INPUT_READS" "$FINAL_NUCLEAR_OUT"
    touch "$FINAL_MITO_OUT"  # crée un fichier vide pour satisfaire Snakemake
fi

echo "[INFO] Étape de séparation terminée"
