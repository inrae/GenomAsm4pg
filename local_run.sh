#!/bin/bash

## TMP config to run on the CBIB
#SBATCH --job-name=asm4pg
#SBATCH --ntasks=25
#SBATCH --mem=300G
#SBATCH -o slurm_logs/out_job_%j.out
#SBATCH -e slurm_logs/err_job_%j.err

# Written by Lucien Piat at INRAe
# Use this script to run asm4pg localy or on a single HPC node
# 07/01/25

SNG_BIND=$(pwd)

run_snakemake() {
    local option="$1"

    case "$option" in
        dry)
            snakemake --use-singularity --singularity-args "-B $SNG_BIND" -j $(nproc) -n 
            ;;
        dag)
            snakemake --use-singularity --singularity-args "-B $SNG_BIND" -j $(nproc) --dag > dag.dot
            if [ $? -eq 0 ]; then
                echo "Asm4pg -> DAG has been successfully generated as dag.dot"
            else
                echo "Asm4pg -> Error: Failed to generate DAG."
                exit 1
            fi
            ;;
        rulegraph)
            snakemake --use-singularity --singularity-args "-B $SNG_BIND" -j $(nproc) --rulegraph > rulegraph.dot
            if [ $? -eq 0 ]; then
                echo "Asm4pg -> Rulegraph has been successfully generated as rulegraph.dot"
            else
                echo "Asm4pg -> Error: Failed to generate Rulegraph."
                exit 1
            fi
            ;;
        unlock)
            snakemake --use-singularity --singularity-args "-B $SNG_BIND" -j $(nproc) --unlock
            ;;
        run)
            snakemake --use-singularity --singularity-args "-B $SNG_BIND" -j $(nproc)
            ;;
        *)
            echo "Invalid option: $option"
            echo "Usage: $0 [dry|run|dag|rulegraph|unlock]"
            exit 1
            ;;
    esac

    # Check if the Snakemake command was successful
    if [ $? -eq 0 ]; then
        echo "Asm4pg -> Snakemake workflow completed successfully."
    else
        echo "Asm4pg -> Error: Snakemake workflow execution failed."
        exit 1
    fi
}

# Verify arguments
if [ $# -ne 1 ] || [ "$1" == "help" ]; then
    echo "Use this script to run asm4pg localy or on a single HPC node"
    echo ""
    echo "Usage: $0 [dry|run|dag|rulegraph|unlock]"
    echo "    dry - run the specified Snakefile in dry-run mode"
    echo "    run - run the specified Snakefile normally"
    echo "    dag - generate the directed acyclic graph for the specified Snakefile"
    echo "    rulegraph - generate the rulegraph for the specified Snakefile"
    echo "    unlock - Unlock the directory if snakemake crashed"
    exit 1
fi

# Execute the function with the provided option
run_snakemake "$1"
