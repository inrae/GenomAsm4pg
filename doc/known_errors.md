# Troubleshooting

## BUSCO Rule Failures

During first run, multiple simultaneous BUSCO lineage downloads may cause job conflicts. Simply rerun the workflow after completion to resolve this.

## Snakemake Locked Directory

If workflow rerun fails after job cancellation:
1. Run `job.sh/local_run.sh unlock`
2. Then rerun the workflow normaly

## HPC Problems

The `job.sh` script is incompatible with HPCs that restrict job nesting.

For older SLURM versions, you may encounter: `srun: unrecognized option '--cpu-bind=q'`. This is a [known SLURM/Snakemake issue](https://github.com/snakemake/snakemake/issues/2071) requiring SLURM update.

Temporary workaround for thoses issues include using `local_run.sh` with sbatch:
```bash
module load Singularity
source activate wf_env
sbatch ./local_run.sh dry
```