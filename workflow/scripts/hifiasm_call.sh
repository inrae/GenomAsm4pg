#!/bin/bash
# Script to dynamically run hifiasm with the correct command based on the mode
# Author: Lucien PIAT
# For: Project Pangenoak
# Date: January 6, 2025

# Usage: ./hifiasm_call.sh mode purge_force threads input [run_1] [run_2]

MODE=$1
PURGE_FORCE=$2
THREADS=$3
INPUT=$4
RUN_1=$5
RUN_2=$6
PREFIX=$7

echo "Asm4pg -> Given hifiasm parameters :"
echo "MODE: $MODE"
echo "PURGE_FORCE: $PURGE_FORCE"
echo "THREADS: $THREADS"
echo "INPUT: $INPUT"
echo "RUN_1: $RUN_1"
echo "RUN_2: $RUN_2"
echo "PREFIX: $PREFIX"


# Run the appropriate hifiasm command based on the mode
case "$MODE" in
    default)
        echo "Asm4pg -> Running hifiasm in default mode..."
        hifiasm -l${PURGE_FORCE} -o ${PREFIX} -t ${THREADS} ${INPUT}
        ;;
    hi-c)
        echo "Asm4pg -> Running hifiasm in hi-c mode..."
        hifiasm -l${PURGE_FORCE} -o ${PREFIX} -t ${THREADS} --h1 ${RUN_1} --h2 ${RUN_2} ${INPUT}
        echo "Asm4pg -> Renaming hifiasm output files"
        mv ${PREFIX}.hic.hap1.p_ctg.gfa ${PREFIX}.bp.hap1.p_ctg.gfa 
        mv ${PREFIX}.hic.hap2.p_ctg.gfa ${PREFIX}.bp.hap2.p_ctg.gfa 
        ;;
    trio)
        echo "Asm4pg -> Hifiasm called in trio mode..."
        echo "Asm4pg -> Generating yak file for parent 1 ($RUN_1)"
        yak count -k31 -b37 -t16 -o ${PREFIX}/yak/parent1.yak ${RUN_1}
        echo "Asm4pg -> Generating yak file for parent 1 ($RUN_2)"
        yak count -k31 -b37 -t16 -o ${PREFIX}/yak/parent2.yak ${RUN_2}
        echo "Asm4pg -> Running hifiasm in trio mode..."
        hifiasm -o ${PREFIX} -t ${THREADS} -1 ${PREFIX}/yak/parent1.yak -2 ${PREFIX}/yak/parent2.yak ${INPUT}
        echo "Asm4pg -> Renaming hifiasm output files"
        mv ${PREFIX}.dip.hap1.p_ctg.gfa ${PREFIX}.bp.hap1.p_ctg.gfa 
        mv ${PREFIX}.dip.hap2.p_ctg.gfa ${PREFIX}.bp.hap2.p_ctg.gfa
        ;;
    *)
        echo "Asm4pg -> Unknown hifiasm mode: $MODE"
        ;;
esac
