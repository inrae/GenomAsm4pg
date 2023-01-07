[TOC]

# One of the BUSCO rules failed
The first time you run the workflow, the BUSCO lineage might be downloaded multiple times. This can create a conflict between the jobs using BUSCO and may interrupt some of them. In that case, you only need to rerun the workflow once everything is done.

# Snakemake locked directory
When you try to rerun the workflow after cancelling a job, you may have to unlock the results directory. To do so, go in `.config/snakemake_profile/slurm` and uncomment line 14 of `config.yaml`. Run the workflow once to unlock the directory (it should only take a few seconds). Still in `config.yaml`, comment line 14. The workflow will be able to run and create outputs.