#!/bin/bash
# Script to dynamically handle haplotigs with the correct command based on the mode
# Author: Lucien PIAT
# For: Project Pangenoak
# Date: January 6, 2025

# Usage: ./haplotigs_handling.sh purge_dups_option hap1_fasta hap2_fasta hap1_output hap2_output

PURGE_DUPS=$1
HAP_IN=$2
HAP_OUT=$3
PREFIX=$4
READS=$5
DIRR=$6

if [[ "$PURGE_DUPS" == "True" || "$PURGE_DUPS" == "true" ]]; then

    # Run purge_dups on both haplotypes

    echo "Asm4pg -> Running purge_dups on haplotigs..."

    # Create calcutus stats for purge_dups
    minimap2 -xasm20 $HAP_IN $READS | gzip -c - > $DIRR/$PREFIX.paf.gz
    pbcstat $DIRR/$PREFIX.paf.gz -O $DIRR
    calcuts $DIRR/PB.stat > $DIRR/cutoffs 2> $DIRR/calcuts.log

    # Split assembly & self-self alignment
    split_fa $HAP_IN > $DIRR/$PREFIX.split
    minimap2 -xasm5 -DP $DIRR/$PREFIX.split $DIRR/$PREFIX.split| gzip -c - > $DIRR/$PREFIX.split.self.paf.gz

    # Purge haplotigs & overlaps
    purge_dups -2 -T $DIRR/cutoffs -c $DIRR/PB.base.cov $DIRR/$PREFIX.split.self.paf.gz > $DIRR/dups.bed 2> $DIRR/purge_dups.log

    # Get purged primary and haplotig sequences from draft assembly
    get_seqs -e $DIRR/dups.bed $HAP_IN -p $DIRR/$PREFIX

    rm $DIRR/dups.bed
    rm $DIRR/PB.base.cov
    rm $DIRR/PB.cov
    rm $DIRR/*paf.gz
    rm $DIRR/*split*
    mv $DIRR/$PREFIX.purged.fa $HAP_OUT
    rm $DIRR/$PREFIX.hap.fa

else
    # If purge_dups is false, create symbolic links to the output location

    echo "Asm4pg -> Purge option is false. Leaving the assembly untouched"
    cp $HAP_IN $HAP_OUT #TODO find why ln is not working here

    # Add an empty cutoffs file so snakemake can link the rules
    echo "No cutoffs, purge_dups is turned off" > $DIRR/cutoffs
fi

