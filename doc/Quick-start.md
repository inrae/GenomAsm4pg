# Quick start
This tutorial shows how to use the workflow with default assembly mode which takes PacBio Hifi data as input.

[TOC]

## Clone repository
```bash
git clone https://forgemia.inra.fr/asm4pg/GenomAsm4pg.git
```
Clone the repository in your desired folder.
## 1. Set up the scripts
### In job.sh
```bash
cd GenomAsm4pg/
vim job.sh
```
Modify:
- Line 17: Set your email address.
- Line 53: Set the path to your dataset folder.
### In masterconfig.yaml
```bash
vim .config/masterconfig.yaml
```
Modify 
- Line 2: Set the path to your output folder.
```yaml
# absolute path to your desired output path
root: ./GenomAsm4pg/<your_output_folder>
```
Modify 
- Line 18: Add all your raw datasets in IDS.
- Line 20: Provide the parameters for all datasets.
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
## 2. Addapt the scripts to your HPC
```bash
vim .config/snakemake_profile/slurm/cluster_config.yml
```
The current profile is configured for SLURM. If you use SLURM, change line 13 to your email address.

To run this workflow on another HPC, create a new profile (https://github.com/Snakemake-Profiles) and add it to the .config/snakemake_profile directory. Update the CLUSTER_CONFIG and PROFILE variables in the job.sh and prejob.sh scripts.

If your cluster doesn’t have Singularity enabled by default, add it to the list of modules to load in job.sh.

## 3. Dry run
To check the configuration, first perform a dry run of the workflow:
```bash
sbatch job.sh dry
```
You can consult the logs in the slurm_logs/ directory.
## 4. Run
If the dry run is successful, ensure that the SNG_BIND variable in job.sh matches the root variable in masterconfig.yaml.
Then, run the script:
```bash
sbatch job.sh
```
## Other assembly modes
If you want to use additional Hi-C data or parental data, follow the [Hi-C assembly mode tutorial](Assembly-Mode/Hi-C-tutorial.md) or the [Trio assembly mode tutorial](Assembly-Mode/Trio-tutorial.md). To go further with the workflow use go [here](Going-further.md).