#!/bin/bash
#SBATCH --cpus-per-task=1
#SBATCH -o slurm_logs/out_job_%j.out
#SBATCH -e slurm_logs/err_job_%j.err
#SBATCH --time=80:00:00
#SBATCH -J asm4pg
#SBATCH --mem=10G

# Verify arguments
if [ $# -ne 1 ]; then
    echo "Usage: $0 [dry|dag|run]"
    echo "    dry - run the specified Snakefile in dry-run mode"
    echo "    dag - generate DAG for the specified Snakefile"
    echo "    run - run the specified Snakefile normally"
    exit 1
fi

# Update this with the path to your images
echo 'Loading modules'
module purge
module load containers/Apptainer/1.2.5 
module load devel/Miniconda/Miniconda3

echo 'Activating environment'
source activate wf_env

echo 'Starting Snakemake workflow'

run_snakemake() {
    local option="$1"

    case "$option" in
        dry)
            snakemake -c $(nproc) --dry-run
            ;;
        dag)
            snakemake -c $(nproc) --dag > dag.dot
            if [ $? -eq 0 ]; then
                echo "Asm4pg -> DAG has been successfully generated as dag.dot"
            else
                echo "Asm4pg -> Error: Failed to generate DAG."
                exit 1
            fi
            ;;
        run)
            snakemake --workflow-profile ./.config/snakemake/profiles/slurm #--unlock
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

# Execute the function with the provided option
run_snakemake "$1"
