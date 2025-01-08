# Trio mode tutorial

Please look at [quick start](../Quick-start.md) first, some of the steps are omitted here.

This tutorial shows how to use the workflow with hi-c assembly mode which takes PacBio Hifi data and Hi-C data as input.

## 1. Config file
**TO-DO : add a toy dataset fasta and parental fasta.**
```bash
cd GenomAsm4pg/.config
```

Modify `masterconfig.yaml`. The PacBio HiFi file is `toy_dataset_trio.fasta`, its name is used as key in config. The parental reads files are `data_p1.fasta` and `data_p2.fasta`.
Parental data is used as k-mers, you use Illumina or PacBio Hifi reads.

```yaml
####################### job - workflow #######################
### CONFIG

IDS: ["toy_dataset_trio"]

toy_dataset_trio:
  fasta: ./GenomAsm4pg/tutorial_data/trio/toy_dataset_trio.fasta
  run: trio_tutorial
  ploidy: 2
  busco_lineage: eudicots_odb10
  mode: trio
  p1: ./GenomAsm4pg/tutorial_data/trio/data_p1.fasta
  p2: ./GenomAsm4pg/tutorial_data/trio/data_p2.fasta
```

## 2. Dry run
To check the config, first do a dry run of the workflow.

```bash
sbatch job.sh dry
```
## 3. Run 
If the dry run is successful, you can run the workflow.

```bash
sbatch job.sh
```

## Other assembly modes
If you want to use Hi-C data, follow the [Hi-C assembly mode tutorial](Hi-C-tutorial.md).
To go further with the workflow use go [here](../Going-further.md).
