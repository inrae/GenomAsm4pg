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

# Initialize recap content
RECAP_CONTENT="RAGTAG: $RAGTAG
DIRR: $DIRR
THREADS: $THREADS
REF: $REF
HAP_IN: $HAP_IN
HAP_OUT: $HAP_OUT
"

if [[ "$RAGTAG" == "True" || "$RAGTAG" == "true" ]]; then
    echo "Asm4pg -> Running ragtag"
    RECAP_CONTENT+="Asm4pg -> Ragtag execution started\n"
    mkdir -p "$DIRR"

    if ragtag.py scaffold -o "$DIRR" -t "$THREADS" "$REF" "$HAP_IN"; then
        gzip "$DIRR/ragtag.scaffold.fasta"
        mv "$DIRR/ragtag.scaffold.fasta.gz" "$HAP_OUT"
        RECAP_CONTENT+="Asm4pg -> Ragtag execution completed\n"
        RECAP_CONTENT+="Output file: $HAP_OUT\n"
    else
        RECAP_CONTENT+="Asm4pg -> Ragtag execution failed\n"
        echo -e "$RECAP_CONTENT" > "$RECAP"
        exit 1
    fi
else
    echo "Asm4pg -> Ragtag option is off"
    RECAP_CONTENT+="Asm4pg -> Ragtag option is off\n"
    mkdir -p "$DIRR"
fi

# Write recap content to file at the end
echo -e "$RECAP_CONTENT" > "$RECAP"
