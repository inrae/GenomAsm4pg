# Troubleshooting

## BUSCO Rule Failures

During the first run, multiple simultaneous BUSCO lineage downloads may cause job conflicts. Simply rerun the workflow after completion to resolve this issue.

## Snakemake Locked Directory

If the workflow rerun fails after job cancellation:
1. Run `job.sh/local_run.sh unlock`.
2. Then rerun the workflow normally.

## HPC Problems

The `job.sh` script is incompatible with HPCs that restrict job nesting.

For older SLURM versions, you may encounter: `srun: unrecognized option '--cpu-bind=q'`. This is a [known SLURM/Snakemake issue](https://github.com/snakemake/snakemake/issues/2071) that requires a SLURM update.

Temporary workarounds for these issues include using `local_run.sh` with sbatch:
```bash
module load Singularity
source activate wf_env
sbatch ./local_run.sh dry
```