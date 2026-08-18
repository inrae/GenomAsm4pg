# Troubleshooting

## Snakemake Locked Directory

If the workflow rerun fails after job cancellation:
1. Run `sbatch asm4pg unlock`.
2. Then rerun the workflow normally.

## HPC Problems

The `asm4pg run` script is incompatible with HPCs that restrict job nesting.

For older SLURM versions, you may encounter: `srun: unrecognized option '--cpu-bind=q'`. This is a [known SLURM/Snakemake issue](https://github.com/snakemake/snakemake/issues/2071) that requires a SLURM update.

Temporary workarounds for these issues include using `sbatch asm4pg local-run`. This will run the workflow on a single node. 
You should also increase the memory/threads given to the workflow in the `asm4pg` SLURM header.
