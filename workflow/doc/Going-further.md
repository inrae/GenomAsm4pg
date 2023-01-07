[TOC]

# 1. Multiple datasets
You can run the workflow on multiple datasets at the same time.

## 1.1. All datasets
With `masterconfig.yaml` as follow, running the workflow will assemble each dataset in its specific assembly mode.
You can add as many datasets as you want, each with different parameters. 

```yaml
IDS: ["toy_dataset", "toy_dataset_hi-c", "toy_dataset_trio"]

toy_dataset:
  fasta: "./GenomAsm4pg/tutorial_data/toy_dataset.fasta"
  run: tutorial
  ploidy: 2
  busco_lineage: eudicots_odb10
  mode: default

toy_dataset_hi-c:
  fasta: ./GenomAsm4pg/tutorial_data/hi-c/toy_dataset_hi-c.fasta
  run: hi-c_tutorial
  ploidy: 2
  busco_lineage: eudicots_odb10
  mode: hi-c
  r1: ./GenomAsm4pg/tutorial_data/hi-c/data_r1.fasta
  r2: ./GenomAsm4pg/tutorial_data/hi-c/data_r1.fasta

toy_dataset_trio:
  fasta: ./GenomAsm4pg/tutorial_data/trio/toy_dataset_trio.fasta
  run: trio_tutorial
  ploidy: 2
  busco_lineage: eudicots_odb10
  mode: trio
  p1: ./GenomAsm4pg/tutorial_data/trio/data_p1.fasta
  p2: ./GenomAsm4pg/tutorial_data/trio/data_p2.fasta
```
## 1.2. On chosen datasets
You can remove dataset from IDS to assemble only chosen genomes:
```yaml
IDS: ["toy_dataset", "toy_dataset_trio"]

toy_dataset:
  fasta: "./GenomAsm4pg/tutorial_data/toy_dataset.fasta"
  run: tutorial
  ploidy: 2
  busco_lineage: eudicots_odb10
  mode: default

toy_dataset_hi-c:
  fasta: ./GenomAsm4pg/tutorial_data/hi-c/toy_dataset_hi-c.fasta
  run: hi-c_tutorial
  ploidy: 2
  busco_lineage: eudicots_odb10
  mode: hi-c
  r1: ./GenomAsm4pg/tutorial_data/hi-c/data_r1.fasta
  r2: ./GenomAsm4pg/tutorial_data/hi-c/data_r1.fasta

toy_dataset_trio:
  fasta: ./GenomAsm4pg/tutorial_data/trio/toy_dataset_trio.fasta
  run: trio_tutorial
  ploidy: 2
  busco_lineage: eudicots_odb10
  mode: trio
  p1: ./GenomAsm4pg/tutorial_data/trio/data_p1.fasta
  p2: ./GenomAsm4pg/tutorial_data/trio/data_p2.fasta
```
Running the workflow with this config will assemble only `toy_dataset` and `toy_dataset_trio`.

# 2. Different run names
If you want to try different parameters on the same dataset, changing the run name will create a new directory and keep the previous data.

In the [Hi-C tutorial](), we used the following config.
```yaml
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

If you want to compare the Hi-C and default assembly modes, you can run the workflow with a different run name and the default mode.
```yaml
IDS: ["toy_dataset_hi-c"]

toy_dataset_hi-c:
  fasta: ./GenomAsm4pg/tutorial_data/hi-c/toy_dataset_hi-c.fasta
  run: default_comparaison
  ploidy: 2
  busco_lineage: eudicots_odb10
  mode: default
```
You will end up with 2 sub-directories for toy_dataset_hi-c (`hi-c_tutorial` and `default_comparaison`) and keep the data from the previous run in Hi-C mode.

# 3. The same dataset with different parameters at once
If you want to do the previous example in one run, you will have to create a symbolic link to the fasta with a different filename.

YAML files do not allow multiple uses of the same key. The following config does not work.
```yaml
## DOES NOT WORK
IDS: ["toy_dataset_hi-c"]

toy_dataset_hi-c:
  run: hi-c_tutorial
  ploidy: 2
  busco_lineage: eudicots_odb10
  mode: hi-c
  r1: ./GenomAsm4pg/tutorial_data/hi-c/data_r1.fasta
  r2: ./GenomAsm4pg/tutorial_data/hi-c/data_r1.fasta

toy_dataset_hi-c:
  run: default_comparaison
  ploidy: 2
  busco_lineage: eudicots_odb10
  mode: default
```

**TO COMPLETE**

# 4. Optional fastq and bam files
If fastq and bam are available and you want to do raw QC with fastQC and longQC, add the `fastq` and/or `bam` key in your config. The fasta, fastq and bam filenames have to be the same. For example:

```yaml
IDS: ["toy_dataset"]

toy_dataset:
  fasta: "./GenomAsm4pg/tutorial_data/toy_dataset.fasta"
  fastq: "./GenomAsm4pg/tutorial_data/toy_dataset.fastq"
  bam: "./GenomAsm4pg/tutorial_data/toy_dataset.bam"
  run: tutorial
  ploidy: 2
  busco_lineage: eudicots_odb10
  mode: default
```