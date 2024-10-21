# Going further

[TOC]

## 01. In-depth options 
### Job.sh options

For a dry run
```bash
sbatch job.sh dry
```
If tou want to output the DAG of the workflow 
```bash
sbatch job.sh dag
```
To run the workflow
```bash
sbatch job.sh 
```

## Workflow options
Inside the ./.config/marsterconfig.yaml file you can add more options
```yaml
IDS: ["example1"]

example1:
  fasta: ./GenomAsm4pg/tutorial_data.fasta
  run: example_run
  ploidy: 2
  busco_lineage: eudicots_odb10
  assembly_purge_force: 3 
  run_purge_dups : True
  mode: default 
```

- `fasta` : Your reads
- `run` : The run name
- `ploidy` : The ploidy of the organims
- `busco_lineage` : The busco lineage of your organisms listed [here](https://busco.ezlab.org/list_of_lineages.html)
- `assembly_purge_force` : [1-3] the purge level of Hifiasm `-l` parametter, full description [here](https://hifiasm.readthedocs.io/en/latest/parameter-reference.html) default is set to 3
- `run_purge_dups` : [True, False] If set to true, the workflow will run [purge_dups](https://github.com/dfguan/purge_dups) on the assembly and rerun all the metrics. Default is set to False. Note that truning on this option will more tan double the runing time of the workflow. 
- `mode`: [default, hi-c, trio] See [Hi-C assembly mode tutorial](Assembly-Mode/Hi-C-tutorial.md) or the [Trio assembly mode tutorial](Assembly-Mode/Trio-tutorial.md)


## 2. Run the workflow on multiple datasets
You can run the workflow on multiple datasets at the same time.

```yaml
IDS: ["toy_dataset", "purge_dataset", "toy_dataset_hi-c", "toy_dataset_trio"]

toy_dataset:
  ...

toy_dataset_hi-c:
  ...

toy_dataset_trio:
  ...
```

You can remove dataset from IDS to assemble only chosen genomes:
```yaml
IDS: ["toy_dataset", "toy_dataset_trio"]
```
Running the workflow with this config will assemble only `toy_dataset` and `toy_dataset_trio`.


## 3. Optional fastq and bam files
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
