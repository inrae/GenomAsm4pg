#!/bin/bash
# Script to dynamically run ragtag or not
# Author: Lucien PIAT
# For: Project Pangenoak
# Date: January 6, 2025

RAGTAG=$1
HAP_IN=$2
HAP_OUT=$3
REF=$4
DIRR=$6
THREADS=$7

if [[ "$RAGTAG" == "True" || "$RAGTAG" == "true" ]]; then
    echo "Asm4pg -> Running ragtag"
    mkdir -p $DIRR
    ragtag.py scaffold -o $DIRR -t $THREADS $REF $HAP_IN
    mv $DIRR/ragtag.scaffold.fasta $HAP_OUT
    mv $DIRR/ragtag.scaffold.paf $HAP_OUT
else
    echo "Asm4pg -> Ragtag option is off"
    mkdir -p $DIRR
fi
