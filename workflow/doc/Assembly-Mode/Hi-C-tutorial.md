Please look at [quick start](../Quick-start) first, some of the steps are omitted here.

This tutorial shows how to use the workflow with hi-c assembly mode which takes PacBio Hifi data and Hi-C data as input.

# 1. Config file
**TO-DO : add a toy dataset fasta and hi-c.**
```bash
cd GenomAsm4pg/.config
```

Modify `masterconfig.yaml`. The PacBio HiFi file is `toy_dataset_hi-c.fasta`, its name is used as key in config. The Hi-C files are `data_r1.fasta` and `data_r2.fasta`

```yaml
####################### job - workflow #######################
### CONFIG

IDS: ["toy_dataset_hi-c"]

toy_dataset_hi-c:
  fasta: ./GenomAsm4pg/tutorial_data/hi-c/toy_dataset_hi-c.fasta
  run: hi-c_tutorial
  ploidy: 2
  busco_lineage: eudicots_odb10
  mode: hi-c
  r1: ./GenomAsm4pg/tutorial_data/hi-c/data_r1.fasta
  r2: ./GenomAsm4pg/tutorial_data/hi-c/data_r1.fasta
```

# 2. Dry run
To check the config, first do a dry run of the workflow.

```bash
sbatch job.sh dry
```
# 3. Run 
If the dry run is successful, you can run the workflow.

```bash
sbatch job.sh
```

# Other assembly modes
If you want to use parental data, follow the [Trio assembly mode tutorial](../Assembly-Mode/Trio-tutorial).
To go further with the workflow use go [here](../Going-further).
