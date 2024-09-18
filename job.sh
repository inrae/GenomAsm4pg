#!/bin/bash
################################ Slurm options #################################
### prepare_calling_jobs
#SBATCH -J smk_main
### Max run time "hours:minutes:seconds"
#SBATCH --time=96:00:00
#SBATCH --ntasks=1 #nb of processes
#SBATCH --cpus-per-task=1 # nb of cores for each process(1 process)
#SBATCH --mem=10G # max of memory (-m) 
### Requirements nodes/servers (default: 1)
#SBATCH --nodes=1
### Requirements cpu/core/task (default: 1)
#SBATCH --ntasks-per-node=1
#SBATCH -o slurm_logs/snakemake.%N.%j.out
#SBATCH -e slurm_logs/snakemake.%N.%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=lucien.piat@inare.fr
################################################################################

# Useful information to print
echo '########################################'
echo 'Date:' $(date --iso-8601=seconds)
echo 'User:' $USER
echo 'Host:' $HOSTNAME
echo 'Job Name:' $SLURM_JOB_NAME
echo 'Job ID:' $SLURM_JOB_ID
echo 'Number of nodes assigned to job:' $SLURM_JOB_NUM_NODES
echo 'Total number of cores for job (?):' $SLURM_NTASKS
echo 'Number of requested cores per node:' $SLURM_NTASKS_PER_NODE
echo 'Nodes assigned to job:' $SLURM_JOB_NODELIST
echo 'Number of CPUs assigned for each task:' $SLURM_CPUS_PER_TASK
echo 'Directory:' $(pwd)
# Detail Information:
echo 'scontrol show job:'
scontrol show job $SLURM_JOB_ID
echo '########################################'

# Function to load modules
load_modules() {
    module purge  # Clear any previously loaded modules

    # Loop through each module and load it
    for module_name in "$@"; do
        module load "$module_name"
    done
}

# Here specify the modules to load and their path
load_modules "python/3.9.7" "snakemake/6.5.1"

### variables
SNG_BIND="/mnt/cbib/pangenoak_trials/GenomAsm4pg/"
CLUSTER_CONFIG=".config/snakemake_profile/slurm/cluster_config.yml"
MAX_CORES=10
PROFILE=".config/snakemake_profile/slurm"

echo 'Starting Snakemake workflow'

### Snakemake commands
if [ "$1" = "dry" ]
then
    # dry run
    snakemake --profile $PROFILE -j $MAX_CORES --use-singularity --singularity-args "-B $SNG_BIND" --cluster-config $CLUSTER_CONFIG -n -r
elif [ -z "$1" ]
then
    # run
    snakemake --profile $PROFILE -j $MAX_CORES --use-singularity --singularity-args "-B $SNG_BIND" --cluster-config $CLUSTER_CONFIG
else
    echo "Error: Invalid argument. Use 'dry' or no argument." >&2
    exit 1
fi