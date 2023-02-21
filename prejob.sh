#!/bin/bash
################################ Slurm options #################################
### prepare_calling_jobs
#SBATCH -J smk_prejob
### Max run time "hours:minutes:seconds"
#SBATCH --time=120:00:00
#SBATCH --ntasks=1 #nb of processes
#SBATCH --cpus-per-task=1 # nb of cores for each process(1 process)
#SBATCH --mem=10G # max of memory (-m) 
### Requirements nodes/servers (default: 1)
#SBATCH --nodes=1
### Requirements cpu/core/task (default: 1)
#SBATCH --ntasks-per-node=1
#SBATCH -o slurm_logs/snakemake_prejob.%N.%j.out
#SBATCH -e slurm_logs/snakemake_prejob.%N.%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=ken.smith@plantandfood.co.nz
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

### get SNG_BIND abs path using python
function SNG_BIND_ABS_PATH {
    SNG_BIND="$(python3 - <<END
import os

abs_path = os.getcwd()
abs_path_corrected = "/".join(abs_path.split("/")[2:])
abs_path_final = "/" + abs_path_corrected

print(abs_path_final)

END
)"
}
SNG_BIND_ABS_PATH

### variables
CLUSTER_CONFIG=".config/snakemake_profile/slurm/cluster_config.yml"
MAX_CORES=4
PROFILE=".config/snakemake_profile/slurm"
SMK_PATH="workflow/pre-job_snakefiles"


### Module Loading:
module purge
module load snakemake
module load singularity

echo 'Starting Snakemake - data preparation'

### create a log directory for slurm logs
mkdir -p slurm_logs

### Snakemake commands
# extract data 
snakemake -s $SMK_PATH/Snakefile1.smk --profile $PROFILE -j $MAX_CORES --cluster-config $CLUSTER_CONFIG
# move files
snakemake -s $SMK_PATH/Snakefile1.smk --profile $PROFILE -j $MAX_CORES --cluster-config $CLUSTER_CONFIG -R move_files
# smrtlink on bam data
snakemake -s $SMK_PATH/Snakefile2.smk --profile $PROFILE -j $MAX_CORES --use-singularity --singularity-args "-B $SNG_BIND" --cluster-config $CLUSTER_CONFIG
# convert fastq to fasta when necessary
snakemake -s $SMK_PATH/Snakefile3.smk --profile $PROFILE -j $MAX_CORES --use-singularity --singularity-args "-B $SNG_BIND" --cluster-config $CLUSTER_CONFIG