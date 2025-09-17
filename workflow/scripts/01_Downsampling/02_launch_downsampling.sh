#!/bin/bash

#SBATCH -c 4
#SBATCH --mem=60G
#SBATCH --job-name=downsampling
# Script de downsampling avec analyses GenomeScope

RAW_DIR="/tmp/ganoderma_african/data/processed/02_assembly/00_clean_read/"
Script="/home/gmichel/work/ganoderma_african/scripts/02_assembly/01_Downsampling/01_downsampling.sh"
for fastq in "$RAW_DIR"/*/01_separation/reads_nuclear.fastq.gz; do
    full_name=$(basename "$(dirname "$(dirname "$fastq")")" _workflow)
    isolate_name=$(echo "$full_name" | sed 's/_PBE91006_NBD114_PCA100302$//')
    isolate_code=$(echo "$fastq" | sed 's|.*/20250812_\([^_]*\)_.*|\1|')
    #mv $fastq $full_name
    echo "$full_name"
    echo "$fastq"
    echo "Traitement: $(basename "$fastq")"
    #$Script -i "$fastq" -c 50 -l 20000 -s 42
done
