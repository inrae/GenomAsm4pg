#!/usr/bin/env bash

# Séparation des lectures chloroplastiques avant assemblage
#
# Protocole de Christophe Klopp
# Script adapté de Quynh-Trang Bui et intégré par Lucien Piat
# Date: 13/09/2026

set -uo pipefail

ORG_REF="$1"
INPUT_FASTA="$2"
INPUT_FASTQ="$3"
MODE="$4"
THREADS="$5"
WORK_DIR="$6"
OUT_NUCLEAR_FASTA="$7"
OUT_NUCLEAR_FASTQ="$8"
OUT_ORG_FASTA="$9"
OUT_ORG_FASTQ="${10}"
OUT_STATS="${11}"

MIN_COV="${MIN_COV:-0.90}"
MIN_ID="${MIN_ID:-0.90}"

empty_gz() { printf '' | gzip > "$1"; }
write_stats() { printf 'nuclear reads\t%s\nchloroplast reads\t%s\n' "$1" "$2" > "$OUT_STATS"; }

passthrough() {
    echo "🔹 Asm4pg -> keeping every read as nuclear"
    cp "$INPUT_FASTA" "$OUT_NUCLEAR_FASTA"
    cp "$INPUT_FASTQ" "$OUT_NUCLEAR_FASTQ"
    empty_gz "$OUT_ORG_FASTA"
    empty_gz "$OUT_ORG_FASTQ"
    write_stats "all (not separated)" "0"
}

##############################################
# 1) CAS OÙ IL N'Y A RIEN À SÉPARER
##############################################
if [[ "$ORG_REF" == "None" ]]; then
    echo "🔹 Asm4pg -> no chloroplast reference given, skipping separation"
    passthrough
    echo "✅ Asm4pg -> done"
    exit 0
fi

if [[ ! -s "$ORG_REF" ]]; then
    echo "⚠️  Asm4pg -> chloroplast reference '$ORG_REF' missing or empty, keeping all reads"
    passthrough
    exit 0
fi

if [[ "$MODE" == "ont" ]]; then
    IN="$INPUT_FASTQ"; PRESET="map-ont"
else
    IN="$INPUT_FASTA"; PRESET="map-hifi"
fi

if [[ ! -s "$IN" ]]; then
    echo "⚠️  Asm4pg -> input read file is empty, nothing to separate"
    passthrough
    exit 0
fi

mkdir -p "$WORK_DIR"
ORG_IDS="$WORK_DIR/organelle_ids.txt"
PAF="$WORK_DIR/organelle.paf"
DOUBLED="$WORK_DIR/reference_doubled.fa"

##############################################
# 2) ALIGNEMENT SUR LA RÉFÉRENCE DOUBLÉE
##############################################
echo "🔹 Asm4pg -> separating chloroplast reads (preset $PRESET, $THREADS threads)"

awk '/^>/{if(seq!="")print h"\n"seq seq; h=$0; seq=""; next}{seq=seq$0}
     END{if(seq!="")print h"\n"seq seq}' "$ORG_REF" > "$DOUBLED"

if ! minimap2 -x "$PRESET" -t "$THREADS" "$DOUBLED" "$IN" > "$PAF" 2> "$WORK_DIR/minimap2.log"; then
    echo "⚠️  Asm4pg -> alignment failed, keeping all reads as nuclear (see minimap2.log)"
    passthrough
    exit 0
fi

##############################################
# 3) IDs DES LECTURES CHLOROPLASTIQUES
##############################################
awk -v cov="$MIN_COV" -v id="$MIN_ID" \
    '$11 > 0 && ($4-$3)/$2 >= cov && $10/$11 >= id {print $1}' "$PAF" \
    | LC_ALL=C sort -u > "$ORG_IDS"

echo "🔹 Asm4pg -> chloroplast reads: $(wc -l < "$ORG_IDS") (coverage >= $MIN_COV, identity >= $MIN_ID)"

##############################################
# 4) PARTITION DES LECTURES
# take = les lectures listées, drop = le complément.
##############################################
take() {
    if [[ -s "$1" ]]; then
        seqtk subseq "$IN" "$1" | gzip > "$2" || { echo "⚠️  Asm4pg -> extraction failed for $2"; empty_gz "$2"; }
    else
        empty_gz "$2"
    fi
}
drop() {
    seqtk seq -A "$IN" 2>/dev/null | awk -v idf="$1" '
        BEGIN{while((getline l < idf) > 0) bad[l]=1}
        /^>/{id=substr($1,2); keep=!(id in bad)}
        keep' | gzip > "$2" || { echo "⚠️  Asm4pg -> nuclear extraction failed"; empty_gz "$2"; }
}

if [[ "$MODE" == "ont" ]]; then
    take "$ORG_IDS" "$OUT_ORG_FASTQ"
    awk -v idf="$ORG_IDS" '
        BEGIN{while((getline l < idf) > 0) bad[l]=1}
        (FNR-1)%4==0{id=substr($1,2); keep=!(id in bad)}
        keep' <(zcat "$IN") | gzip > "$OUT_NUCLEAR_FASTQ"
    zcat "$OUT_NUCLEAR_FASTQ" | awk 'NR%4==1{sub("^@",">",$0);print} NR%4==2{print}' | gzip > "$OUT_NUCLEAR_FASTA"
    zcat "$OUT_ORG_FASTQ"     | awk 'NR%4==1{sub("^@",">",$0);print} NR%4==2{print}' | gzip > "$OUT_ORG_FASTA"
else
    take "$ORG_IDS" "$OUT_ORG_FASTA"
    drop "$ORG_IDS" "$OUT_NUCLEAR_FASTA"
    empty_gz "$OUT_NUCLEAR_FASTQ"
    empty_gz "$OUT_ORG_FASTQ"
fi

##############################################
# 5) STATISTIQUES
##############################################
if [[ ! -s "$OUT_NUCLEAR_FASTA" ]]; then
    echo "⚠️  Asm4pg -> no nuclear reads left; is the reference really a chloroplast?"
fi

count() { if [[ "$MODE" == "ont" ]]; then zcat "$1" 2>/dev/null | awk 'END{print int(NR/4)}'; else zcat "$1" 2>/dev/null | grep -c '^>'; fi; }
N_NUC=$(count "$OUT_NUCLEAR_FASTA"); N_ORG=$(count "$OUT_ORG_FASTA")
write_stats "$N_NUC" "$N_ORG"
echo "✅ Asm4pg -> nuclear $N_NUC reads, chloroplast $N_ORG reads"

rm -f "$ORG_IDS" "$PAF" "$DOUBLED"
