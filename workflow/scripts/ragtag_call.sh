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


if [[ "$RAGTAG" == "True" || "$RAGTAG" == "true" ]]; then

    echo "Asm4pg -> Running ragtag"
    mkdir -p $DIRR
    ragtag.py scaffold -o {params.out_dir} -t {threads} {input.reference} {input.assembly} &&

else
    echo "Asm4pg -> Ragtag option is off"
    mkdir -p $DIRR

fi



        
        mv {params.out_dir}/ragtag.scaffold.fasta {output.scaffold} &&
        mv {params.out_dir}/ragtag.scaffold.paf {output.alignment}