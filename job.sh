#!/bin/bash
################################ Slurm options #################################
### prepare_calling_jobs
#SBATCH -J smk_main
### Max run time "hours:minutes:seconds"
#SBATCH --time=120:00:00
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
#SBATCH --mail-user=sukanya.denni@univ-rouen.fr
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


### variables
CLUSTER_CONFIG=".config/snakemake_profile/slurm/cluster_config.yml"
MAX_CORES=10
PROFILE=".config/snakemake_profile/slurm"
SNG_BIND="/gpfs/scratch/sdenni/wf/GenomAsm4pg"

### Module Loading:
module purge
module load snakemake/6.5.1

echo 'Starting Snakemake workflow'

### create a log directory for slurm output files
mkdir -p slurm_logs

### Snakemake commands
## Dry run
# snakemake --profile $PROFILE -j $MAX_CORES --use-singularity  --singularity-args "-B $SNG_BIND" --cluster-config $CLUSTER_CONFIG -n -r

# snakemake --profile $PROFILE -j $MAX_CORES --use-singularity  --singularity-args "-B $SNG_BIND" --cluster-config $CLUSTER_CONFIG -f print

## Run
snakemake --profile $PROFILE -j $MAX_CORES --use-singularity --singularity-args "-B $SNG_BIND" --cluster-config $CLUSTER_CONFIG