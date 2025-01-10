#!/bin/bash
# Script to run locally, DO NOT USE AS IS ON A CLUSTER!

# Written by Lucien Piat at INRAe
# 07/01/24

SNG_BIND=$(pwd)

run_snakemake() {
    local option="$1"

    case "$option" in
        dry)
            snakemake --use-singularity --singularity-args "-B $SNG_BIND" -j $(nproc) -n -R all
            ;;
        dag)
            snakemake --use-singularity --singularity-args "-B $SNG_BIND" -j $(nproc) -R all --dag > dag.dot
            if [ $? -eq 0 ]; then
                echo "Asm4pg -> DAG has been successfully generated as dag.dot"
            else
                echo "Asm4pg -> Error: Failed to generate DAG."
                exit 1
            fi
            ;;
        run)
            snakemake --use-singularity --singularity-args "-B $SNG_BIND" -j $(nproc) -R all #--forceall
            ;;
        *)
            echo "Invalid option: $option"
            echo "Usage: $0 [dry|dag|run]"
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
if [ $# -ne 1 ]; then
    echo "Usage: $0 [dry|dag|run]"
    echo "    dry - run the specified Snakefile in dry-run mode"
    echo "    dag - generate DAG for the specified Snakefile"
    echo "    run - run the specified Snakefile normally"
    exit 1
fi

# Execute the function with the provided option
run_snakemake "$1"
