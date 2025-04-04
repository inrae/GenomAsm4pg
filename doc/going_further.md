# Going Further

## 01. Job.sh/local_run.sh Options

Usage: `asm4pg [dry|run|local-run|dag|rulegraph|unlock]`

- `dry` - run in dry-run mode
- `run` - run the workflow with SLURM
- `local-run` - run the workflow localy (on a single node)
- `dag` - generate the directed acyclic graph for the workflow
- `rulegraph` - generate the rulegraph for the workflow
- `unlock` - unlock the directory if Snakemake crashed

## 02. Workflow Options

Inside the `./.config/masterconfig.yaml` file, you can add more options.
Here are all the options and their default values:

- `reads`: Your reads (mandatory) (fasta.gz, fasta, fastq.gz, fastq, or bam)
- `mode`: [default, hi-c, trio] The mode for Hifiasm assembly (default: default)
- `r1`: If hi-c or trio mode, the run1/parent1 read file (fasta.gz, fastq.gz)
- `r2`: If hi-c or trio mode, the run2/parent2 read file
- `run_purge_dups`: [True, False] If set to true, the workflow will run [purge_dups](https://github.com/dfguan/purge_dups) on the assembly (default: False)
- `busco_lineage`: The BUSCO lineage of your organism listed [here](https://busco.ezlab.org/list_of_lineages.html) (default: eukaryota_odb10)
- `run_ragtag`: [True, False] If set to true, the workflow will run RagTag and produce a scaffold of the assemblies (default: False)
- `reference_genome`: The reference genome used for QUAST and RagTag scaffolding
- `run_quast`: [True, False] If set to true, the workflow will run Quast and porduce global assembly statistics.

⚠️ Advanced options (use only if you have read the tools' documentation; we strongly recommend keeping default values):

- `assembly_purge_force`: [1-3] The purge level of Hifiasm `-l` parameter, full description [here](https://hifiasm.readthedocs.io/en/latest/parameter-reference.html) (default: 3)
- `kmer_size`: The size of the kmers used for QC steps (default: 21)

## 03. Example Configurations

### Minimal Config

This minimal configuration will conduct a de novo assembly with default values:
```yaml
samples:
  example1:
    reads: example.fasta.gz
```

### Simple Config

This simple configuration will conduct a de novo assembly with tailored values. **We recommend using this type of configuration:**
```yaml
samples:
  example1:
    reads: example.fasta.gz
    busco_lineage: eudicots_odb10
    run_ragtag: True
    reference_genome: ref.fasta.gz
```

### Hi-C Config
This example shows how to use the workflow with Hi-C assembly mode which takes PacBio HiFi data and Hi-C data as input.
```yaml
samples:
  example1:
    reads: example.fasta.gz
    mode: hi-c
    r1: run1.fastq.gz
    r2: run2.fastq.gz
```
In R1 and R2 you can add fastq.gz of fasta.gz files. If they are of type fastq, a quality controll will occur before the assembly using `fastp -q 20 -l 50` YAHS

### Trio Config
This example shows how to use the workflow with trio assembly mode. The parental reads files can be Illumina or PacBio HiFi reads.
```yaml
samples:
  example1:
    reads: example.fasta.gz
    mode: trio
    r1: parent1.fasta.gz
    r2: parent2.fasta.gz
```

### Advanced Config
```yaml
samples:
  example1:
    reads: example.fasta.gz
    mode: hi-c
    r1: run1.fasta.gz
    r2: run2.fasta.gz
    run_purge_dups: True
    assembly_purge_force: 2
    ploidy: 2
    kmer_size: 21
    busco_lineage: eudicots_odb10
    run_ragtag: True
    reference_genome: ref.fasta.gz
```

## 04. Run the Workflow on Multiple Datasets

You can run the workflow on multiple datasets at the same time.
```yaml
samples:
  dataset_1:
    reads: example_1.fasta.gz
    run_purge_dups: True
  dataset_2:
    reads: example_2.fasta.gz
    run_purge_dups: False
  dataset_n:
    reads: example_n.fasta.gz
```