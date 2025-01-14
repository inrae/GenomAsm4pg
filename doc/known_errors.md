# Troubleshooting

## One of the BUSCO rules failed
The first time you run the workflow, the BUSCO lineage might be downloaded multiple times. This can create a conflict between the jobs using BUSCO and may interrupt some of them. In that case, you only need to rerun the workflow once everything is done.

## Snakemake locked directory
When you try to rerun the workflow after cancelling a job, you may have to unlock the results directory. To do so, go in `job.sh/local_run.sh` and uncomment `#--unlock`. Run the workflow once to unlock the directory (it should only take a few seconds). Still in `job.sh/local_run.sh`, re add the `#`. The workflow will be able to run and create outputs.

## HPC problems
The asm4pg.sh does not work with HPC that does not allow a job to run other jobs.

If the version of SLRUM in the HPC is old, you may run into this error `srun: unrecognized option '--cpu-bind=q'` this is a known SLURM/Snakemake issue and SLRUM needs to be updated (https://github.com/snakemake/snakemake/issues/2071)

A temporary sollution is to run the ./local_run.sh with sbatch :
```
module load Singularity
source activate wf_env
sbatch ./local_run.sh dry
```