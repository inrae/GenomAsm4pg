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
    echo "Asm4pg -> Ragtag execution started" >> $RECAP
    mkdir -p $DIRR

    if ragtag.py scaffold -o $DIRR -t $THREADS $REF $HAP_IN; then
        gzip $DIRR/ragtag.scaffold.fasta
        mv $DIRR/ragtag.scaffold.fasta.gz $HAP_OUT
        echo "Asm4pg -> Ragtag execution completed" >> $RECAP
        echo "Output file: $HAP_OUT" >> $RECAP
    else
        echo "Asm4pg -> Ragtag execution failed" >> $RECAP
        exit 1
    fi
else
    echo "Asm4pg -> Ragtag option is off"
    echo "Asm4pg -> Ragtag option is off" >> $RECAP
    mkdir -p $DIRR
fi
