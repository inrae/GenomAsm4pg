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
MITO_REF=$7     # reference mitogenome fasta, or None
MITO_FA=$8      # mitochondrial contigs removed from the assembly
MITO_TSV=$9     # their names, lengths and aligned fraction

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
    if ! calcuts "$DIRR/PB.stat" > "$DIRR/cutoffs" 2> "$DIRR/calcuts.log"; then
        if grep -q '\[M::calcuts\] Find 0 peaks' "$DIRR/calcuts.log"; then
            echo "⚠️  Asm4pg -> No peaks found in calcuts. Skipping purging and copying input to output."
            cp "$HAP_IN" "$HAP_OUT"
            echo "No cutoffs, calcuts found 0 peaks" > "$DIRR/cutoffs"
            cleanup_temp_files
            return 0
        else
            echo "❌ Asm4pg -> calcuts failed for another reason."
            exit 1
        fi
    fi

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

# Move the mitochondrial contigs (>= 90% of their length aligned to the reference mitogenome)
# out of the final assembly.
remove_mito_contigs() {
    : > "$MITO_FA"
    if [[ "$MITO_REF" == "None" ]]; then
        echo "No reference mitogenome given, no contig removed" > "$MITO_TSV"
        return 0
    fi

    echo "🔹 Asm4pg -> Removing mitochondrial contigs..."
    if ! minimap2 -x asm20 "$MITO_REF" "$HAP_OUT" > "$DIRR/$PREFIX.mito.paf"; then
        echo "⚠️  Asm4pg -> minimap2 against the mitogenome failed, no contig removed"
        echo "Mapping against the reference mitogenome failed, no contig removed" > "$MITO_TSV"
        rm -f "$DIRR/$PREFIX.mito.paf"
        return 0
    fi

    # Merge the aligned intervals of each contig, keep contigs covered at >= 90%
    sort -k1,1 -k3,3n "$DIRR/$PREFIX.mito.paf" | awk -v OFS='\t' '
        function flush() { if (q != "") { cov += e - s; if (cov / len >= 0.9) print q, len, sprintf("%.3f", cov / len) } }
        $1 != q { flush(); q = $1; len = $2; s = $3; e = $4; cov = 0; next }
        $3 > e  { cov += e - s; s = $3; e = $4; next }
        $4 > e  { e = $4 }
        END     { flush() }' > "$DIRR/$PREFIX.mito.ids"

    : > "$DIRR/$PREFIX.nomito.fa"
    zcat "$HAP_OUT" | awk -v ids="$DIRR/$PREFIX.mito.ids" -v mito="$MITO_FA" -v keep="$DIRR/$PREFIX.nomito.fa" '
        BEGIN { while ((getline l < ids) > 0) { split(l, a, "\t"); m[a[1]] = 1 } }
        /^>/  { out = (substr($1, 2) in m) ? mito : keep }
        { print > out }'
    gzip -c "$DIRR/$PREFIX.nomito.fa" > "$HAP_OUT"

    { echo "# $(wc -l < "$DIRR/$PREFIX.mito.ids") contig(s) removed, $(awk '{ s += $2 } END { print s + 0 }' "$DIRR/$PREFIX.mito.ids") bp, >= 90% aligned to the reference mitogenome"
      printf 'contig\tlength\taligned_fraction\n'
      cat "$DIRR/$PREFIX.mito.ids"; } > "$MITO_TSV"
    rm -f "$DIRR/$PREFIX.mito.paf" "$DIRR/$PREFIX.mito.ids" "$DIRR/$PREFIX.nomito.fa"
    cat "$MITO_TSV"
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
remove_mito_contigs
echo "✅ Asm4pg -> Done with haplotigs handling"
