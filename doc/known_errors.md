# Troubleshooting

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

## QUAST Running Indefinitely

Sometimes, QUAST can take an exceptionally long time to complete. This is often due to Minimap2 struggling to align certain regions of the genome, which can slow down the process significantly.

Even if QUAST fails or gets stuck, the assemblies should still be produced successfully. You can proceed with downstream analyses without waiting indefinitely for QUAST to finish.

If QUAST is still running or has failed, you can check preliminary results in the directory "results/{sample}_results/04_assembly_qc/quast/combined_reference/basic_stats"