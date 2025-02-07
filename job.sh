#!/bin/bash
#SBATCH --cpus-per-task=1
#SBATCH -o slurm_logs/out_job_%j.out
#SBATCH -e slurm_logs/err_job_%j.err
#SBATCH --time=80:00:00
#SBATCH -J asm4pg
#SBATCH --mem=10G

# Written by Lucien Piat at INRAe
# Use this script to run asm4pg on a HPC
# 07/01/25

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
        rulegraph)
            snakemake -c $(nproc) --rulegraph > rulegraph.dot
            if [ $? -eq 0 ]; then
                echo "Asm4pg -> Rulegraph has been successfully generated as rulegraph.dot"
            else
                echo "Asm4pg -> Error: Failed to generate Rulegraph."
                exit 1
            fi
            ;;
        unlock)
            snakemake --workflow-profile ./.config/snakemake/profiles/slurm --unlock
            ;;
        run)
            snakemake --workflow-profile ./.config/snakemake/profiles/slurm 
            ;;
        *)
            echo "Invalid option: $option"
            echo "Usage: $0 [dry|run|dag|rulegraph|unlock]"
            exit 1
            ;;
    esac
}

# Execute the function with the provided option
run_snakemake "$1"
