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

## Jobs stay PENDING with reason `PartitionTimeLimit`

Every rule job asks for the wall time in `default-resources: runtime=` of
`.config/snakemake/profiles/slurm/config.yaml` (**minutes**), which the SLURM
executor passes as `sbatch -t`. If that is longer than the partition's own
limit, the jobs are accepted but never scheduled. Lower `runtime` to fit the
partition you submit to (genotoul: `workq` is capped at 4 days), or submit to a
partition that allows more. `squeue -u $USER -l` shows the requested
`TIME_LIMIT` next to the reason.

If the limit you see is not the one configured here, something in your
environment is overriding it -- check `SBATCH_TIMELIMIT`, which takes
precedence over the `#SBATCH --time` header in `asm4pg`.

## `No such file or directory` for reads that do exist

Only the working directory is mounted inside the containers. Anything else --
reads on a scratch filesystem, an `output_dir_pdw` elsewhere, reference
genomes -- needs `asm4pg --bind /path/one,/path/two`, which `asm4pg` passes both
as `--singularity-args` and as `APPTAINER_BINDPATH`/`SINGULARITY_BINDPATH` so
the mounts reach the SLURM worker nodes too.
