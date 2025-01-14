# Going further

## 01. Job.sh/local_run.sh options
Usage: job.sh/local_run.sh [dry|run|dag|rulegraph|unlock]
- [dry] - run the specified Snakefile in dry-run mode
- [run] - run the specified Snakefile normally
- [dag] - generate the directed acyclic graph for the specified Snakefile
- [rulegraph] - generate the rulegraph for the specified Snakefile
- [unlock] - Unlock the directory if snakemake crashed

## 02. Workflow options
Inside the ./.config/marsterconfig.yaml file you can add more options

Here are all the options and their default values : 
- `fasta_gz` : Your reads (mandatory)
- `mode`: [default, hi-c, trio] The mode for hifiasm assembly (default: default)
  - `r1` if hi-c of trio mode the run1/parent1 read file
  - `r2` if hi-c of trio mode the run2/parent2 read file
- `run_purge_dups` : [True, False]  If set to true, the workflow will run [purge_dups](https://github.com/dfguan/purge_dups) on the assembly. (default: False)
- `busco_lineage` : The busco lineage of your organisms listed [here](https://busco.ezlab.org/list_of_lineages.html) (default: eukaryota_odb10)
- `ploidy` : The ploidy of the organims (default: 2)
- `run_ragtag` : [True, False]  If set to true, the workflow will run RagTag and produce a scafold of the assemblies (default: False)
  - `reference_genome` : The reference genome used for Quast and RagTag scafolding 


/!\ Advanced options, use only if you have read the docs of the tools, we strogly advise keeping default values : 
- `assembly_purge_force` : [1-3] the purge level of Hifiasm `-l` parametter, full description [here](https://hifiasm.readthedocs.io/en/latest/parameter-reference.html) (default: 3)
- `kmer_size` : The sizes of the kmers used for QC steps (default: 21)

## 03. Example configurations
### Minimal config 
```yaml
samples:
  example1:
    fasta_gz: example.fasta.gz
```

### Simple config
```yaml
samples:
  example1:
    fasta_gz: example.fasta.gz
    busco_lineage: eudicots_odb10
    run_purge_dups: True
    run_ragtag: True
    reference_genome: ref.fasta.gz
    
```
### Hi-c config
```yaml
samples:
  example1:
    fasta_gz: example.fasta.gz
    mode: hi-c
    r1: run1.fasta.gz
    r2: run2.fasta.gz

```

### Trio config
```yaml
samples:
  example1:
    fasta_gz: example.fasta.gz
    mode: trio
    r1: parent1.fasta.gz
    r2: parent2.fasta.gz
```

### Adanced config
```yaml
samples:
  example1:
    fasta_gz: example.fasta.gz
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

## 04. Run the workflow on multiple datasets
You can run the workflow on multiple datasets at the same time.

```yaml
samples:
  dataset_1:
    fasta_gz: example_1.fasta.gz
    run_purge_dups: True
  dataset_2:
    fasta_gz: example_2.fasta.gz
    run_purge_dups: False
  dataset_n:
    fasta_gz: example_n.fasta.gz
```

