#!/bin/bash
# Script to run locally, DO NOT USE AS IS ON A CLUSTER!

SNG_BIND=$(pwd)

# Get the number of CPU cores dynamically
CORES=$(nproc)

run_snakemake() {

    local option="$2"     # The option for dry run or DAG
    echo "Starting $snakefile..."

    # Execute the Snakemake command with the specified option
    if [[ "$option" == "dry" ]]; then
        snakemake --use-singularity --singularity-args "-B $SNG_BIND" -j $CORES -n
    elif [[ "$option" == "dag" ]]; then
        snakemake --use-singularity --singularity-args "-B $SNG_BIND" -j $CORES --dag > dag.dot
        echo "DAG has been generated as dag.png"
        return
    else
        snakemake --use-singularity --singularity-args "-B $SNG_BIND" -j $CORES --forceall
    fi

    # Check if the Snakemake command was successful
    if [ $? -eq 0 ]; then
        echo "$snakefile completed successfully."
    else
        echo "Error: $snakefile failed."
        exit 1
    fi
}

if [ $# -eq 0 ]; then
    echo "Usage: $0 [dry|dag|run]"
    echo "    dry - run the specified Snakefile in dry-run mode"
    echo "    dag - generate DAG for the specified Snakefile"
    echo "    run - run the specified Snakefile normally (default)"
    exit 1
fi

run_snakemake "$option"
