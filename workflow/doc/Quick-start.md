This tutorial shows how to use the workflow with default assembly mode which takes PacBio Hifi data as input.

[TOC]

# Clone repository
```bash
cd .
git clone https://forgemia.inra.fr/asm4pg/GenomAsm4pg.git
```

# 1. Cluster profile setup
```bash
cd GenomAsm4pg/.config/snakemake_profile
```
The current profile is made for SLURM. If you use it, change line 13 to your email address in the `cluster_config`.yml file.

To run this workflow on another HPC, create another profile (https://github.com/Snakemake-Profiles) and add it in the `.config/snakemake_profile` directory. Change the `CLUSTER_CONFIG` and `PROFILE` variables in `job.sh` and `prejob.sh` scripts.


# 2. Config file
**TO-DO : add a toy fasta.**
```bash
cd ..
```

Modify `masterconfig.yaml`. Root refers to the path for the output data.
```yaml
# absolute path to your desired output path
root: ./GenomAsm4pg/tutorial_output
```

The reads file is `toy_dataset.fasta`, its name is used as key in config. 

```yaml
####################### job - workflow #######################
### CONFIG
IDS: ["toy_dataset"]

toy_dataset:
  fasta: "./GenomAsm4pg/tutorial_data/toy_dataset.fasta"
  run: tutorial
  ploidy: 2
  busco_lineage: eudicots_odb10
  mode: default
```

# 3. Create slurm_logs directory
```bash
cd ..
mkdir slurm_logs
```
SLURM logs for each rule will be in this directory, there are .out and .err files for the worklow (*snakemake.cortex**) and for each rules (*rulename.cortex**).

# 4. Mail setup
Modify line 17 to your email address in `job.sh`.

# 5. Dry run
To check the config, first do a dry run of the workflow.

```bash
sbatch job.sh dry
```
# 6. Run 
If the dry run is successful, check that the `SNG_BIND` variable in `job.sh` is the same as `root` variable in `masterconfig.yaml`. 

If Singularity is not in the HPC environment, add `module load singularity` under `module load snakemake/6.5.1`.

You can run the workflow.

```bash
sbatch job.sh
```

# Other assembly modes
If you want to use additional Hi-C data or parental data, follow the [Hi-C assembly mode tutorial](Documentation/Assembly-Mode/Hi-C-tutorial) or the [Trio assembly mode tutorial](Assembly-Mode/Trio-tutorial.md). To go further with the workflow use go [here](Going-further.md).
