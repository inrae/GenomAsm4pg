# Troubleshooting

## Snakemake Locked Directory

If the workflow rerun fails after job cancellation:
1. Run `job.sh unlock`.
2. Then rerun the workflow normally.

## HPC Problems

The `job.sh run` script is incompatible with HPCs that restrict job nesting.

For older SLURM versions, you may encounter: `srun: unrecognized option '--cpu-bind=q'`. This is a [known SLURM/Snakemake issue](https://github.com/snakemake/snakemake/issues/2071) that requires a SLURM update.

Temporary workarounds for these issues include using `job.sh local-run` with sbatch. This will run the workflow on a single node. 
You should also increase the memory/threads given to the workflow in the `job.sh` SLURM header.

## QUAST Running Indefinitely

Sometimes, QUAST can take an exceptionally long time to complete. This is often due to Minimap2 struggling to align certain regions of the genome, which can slow down the process significantly.

Even if QUAST fails or gets stuck, the assemblies should still be produced successfully. You can proceed with downstream analyses without waiting indefinitely for QUAST to finish.

