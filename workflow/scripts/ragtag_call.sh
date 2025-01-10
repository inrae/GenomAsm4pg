#!/bin/bash
# Script to dynamically run ragtag or not
# Author: Lucien PIAT
# For: Project Pangenoak
# Date: January 6, 2025

RAGTAG=$1
DIRR=$2
THREADS=$3
REF=$4
HAP_IN=$5
HAP_OUT=$6
RECAP=$7

# Echo parameters into the recap file
echo "RAGTAG: $RAGTAG" > $RECAP
echo "DIRR: $DIRR" >> $RECAP
echo "THREADS: $THREADS" >> $RECAP
echo "REF: $REF" >> $RECAP
echo "HAP_IN: $HAP_IN" >> $RECAP
echo "HAP_OUT: $HAP_OUT" >> $RECAP

if [[ "$RAGTAG" == "True" || "$RAGTAG" == "true" ]]; then
    echo "Asm4pg -> Running ragtag"
    echo "Ragtag execution started" >> $RECAP
    mkdir -p $DIRR

    ragtag.py scaffold -o $DIRR -t $THREADS $REF $HAP_IN
    gzip $DIRR/ragtag.scaffold.fasta
    mv $DIRR/ragtag.scaffold.fasta.gz $HAP_OUT
    echo "Ragtag execution completed" >> $RECAP
    echo "Output file: $HAP_OUT" >> $RECAP
else
    echo "Asm4pg -> Ragtag option is off"
    echo "Ragtag option is off" >> $RECAP
    mkdir -p $DIRR
fi
