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

echo "MODE: $MODE"
echo "PURGE_FORCE: $PURGE_FORCE"
echo "THREADS: $THREADS"
echo "INPUT: $INPUT"
echo "RUN_1: $RUN_1"
echo "RUN_2: $RUN_2"
echo "PREFIX: $PREFIX"


echo ${INPUT}
ls

# Run the appropriate hifiasm command based on the mode
case "$MODE" in
    default)
        echo "Running in default mode..."
        hifiasm -l${PURGE_FORCE} -o ${PREFIX} -t ${THREADS} ${INPUT}
        ;;
    hi-c)
        echo "Running in hi-c mode..."
        hifiasm -l${PURGE_FORCE} -o ${PREFIX} -t ${THREADS} --h1 ${RUN_1} --h2 ${RUN_2} ${INPUT}
        mv ${PREFIX}.hic.hap1.p_ctg.gfa ${PREFIX}.bp.hap1.p_ctg.gfa 
        mv ${PREFIX}.hic.hap2.p_ctg.gfa ${PREFIX}.bp.hap2.p_ctg.gfa 
        ;;
    *)
        echo "Unknown mode: $MODE"
        ;;
esac
