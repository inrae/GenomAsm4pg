# Assembly workflow for pangenome
This workflow uses [Snakemake](https://snakemake.readthedocs.io/en/stable/) to quickly assemble genomes with a HTML report summarizing obtained assembly stats. This workflow uses PacBio HiFi data.

A first script (```prejob.sh```) prepares the data until fasta.gz files are obtained. A second script (```job.sh```) runs the genome assembly and stats.

![workflow DAG](fig/rule_dag.svg)

## Table of contents
[TOC]

## Repo directory structure

```
├── README.md
├── job.sh
├── prejob.sh
├── workflow
│   ├── rules
│   ├── modules
│   ├── scripts
│   ├── pre-job_snakefiles
|   └── Snakefile
└──  .config
    ├── snakemake_profile
    |  └── slurm
    |       ├── cluster_config.yml
    |       ├── config.yaml
    |       ├── CookieCutter.py
    |       ├── settings.json
    |       ├── slurm_utils.py
    |       ├── slurm-jobscript.sh
    |       ├── slurm-status.py
    |       └── slurm-submit.py
    └── masterconfig.yaml
```

## Requirements
- snakemake >= 6.5.1
- singularity

## Workflow steps, programs & Docker images pulled by Snakemake
All images here will be pulled automatically by Snakemake the first time you run the workflow. It may take some time. Images are only downloaded once and reused automatically by the workflow.

**Pre-assembly**
- Conversion of PacBio bam to fasta & fastq
    - **smrtlink** (https://www.pacb.com/support/software-downloads/)
        - image version: 9.0.0.92188 ([link](https://hub.docker.com/r/bryce911/smrtlink/tags))
- Fastq to fasta conversion
    - **seqtk** (https://github.com/lh3/seqtk)
        - image version: 1.3--dc0d16b ([link](https://hub.docker.com/r/nanozoo/seqtk))
- Raw data quality control
    - **fastqc** (https://github.com/s-andrews/FastQC)
        - image version: v0.11.5_cv4 ([link](https://hub.docker.com/r/biocontainers/fastqc/tags))
    - **lonqQC** (https://github.com/yfukasawa/LongQC)
        - image version: latest (April 2022) ([link](https://hub.docker.com/r/grpiccoli/longqc/tags))
- Metrics
    - **genometools** (https://github.com/genometools/genometools)
        - image version: v1.5.9ds-4-deb_cv1 ([link](https://hub.docker.com/r/biocontainers/genometools/tags))
- K-mer analysis
    - **jellyfish** (https://github.com/gmarcais/Jellyfish)
        - image version: 2.3.0--h9f5acd7_3 ([link](https://quay.io/repository/biocontainers/kmer-jellyfish?tab=tags))
    - **genomescope** (https://github.com/tbenavi1/genomescope2.0)
        - image version: 2.0 ([link](https://hub.docker.com/r/abner12/genomescope))

**Assembly**
- Assembly
    - **hifiasm** (https://github.com/chhylp123/hifiasm)
        - image version: 0.16.1--h5b5514e_1 ([link](https://quay.io/repository/biocontainers/hifiasm?tab=tags))
- Metrics
    - **genometools** (same as Pre-assembly)
- Assembly quality control
    - **busco** (https://gitlab.com/ezlab/busco)
        - image version: v5.1.2_cv1 ([link](https://hub.docker.com/r/ezlabgva/busco/tags))
    - **kat** (https://github.com/TGAC/KAT)
        - image version: 2.4.1--py35h355e19c_3 ([link](https://quay.io/repository/biocontainers/kat))
- Error rate, QV & phasing
    - **meryl** and **merqury** (https://github.com/marbl/meryl, https://github.com/marbl/merqury)
        - image version: 1.3--hdfd78af_0 ([link](https://quay.io/repository/biocontainers/merqury?tab=tags))
- Detect assembled telomeres
    - **FindTelomeres** (https://github.com/JanaSperschneider/FindTelomeres)
        - **Biopython** image version: 1.75 ([link](https://quay.io/repository/biocontainers/biopython?tab=tags))
- Haplotigs and overlaps purging 
    - **purge_dups** (https://github.com/dfguan/purge_dups)
        - image version: 1.2.5--h7132678_2 ([link](https://quay.io/repository/biocontainers/purge_dups?tab=tags))

## How to run the workflow

### Merqury image manipulation
This is essential to get correct Merqury plots.

1. Download msttcorefonts

```
sudo apt-get update
wget http://ftp.de.debian.org/debian/pool/contrib/m/msttcorefonts/ttf-mscorefonts-installer_3.7_all.deb -P ~/Downloads
sudo apt install ~/Downloads/ttf-mscorefonts-installer_3.7_all.deb -y
sudo apt-mark hold ttf-mscorefonts-installer
```

2. Add the fonts to the image with [Singularity](https://docs.sylabs.io/guides/3.0/user-guide/index.html)

```
singularity pull docker://quay.io/biocontainers/merqury:1.3--hdfd78af_0
singularity build --sandbox merqury_sandbox merqury_1.3--hdfd78af_0.sif
```

Create a new directory in the merqury_sandbox directory and copy the fonts here.

```
mkdir -p merqury_sandbox/usr/share/fonts/truetype
cp -r /usr/share/fonts/truetype/msttcorefonts merqury_sandbox/usr/share/fonts/truetype
singularity build merqury.sif merqury_sandbox
```

3. Add the Merqury image to the workflow

Create a directory named `img` in the directory `workflow` and copy `merqury.sif` there.

### Profile setup
The current profile is made for SLURM. To run this workflow on another HPC, create another profile (https://github.com/Snakemake-Profiles) and add it in the `.config/snakemake_profile` directory. Change the `CLUSTER_CONFIG` and `PROFILE` variables in `job.sh` and `prejob.sh`.
If you are using the current SLURM setup, change line 13 to your email adress in the `cluster_config`.yml file.

### SLURM logs
SLURM submission scripts, prejob.sh and job.sh, output standard and error output into slurm_logs directory. This directory must exist before running any of these submission script else slurm will refuse to submit these jobs.

```
# create if not exist
mkdir -p slurm_logs
```

### Workflow execution
Go in the `Assemb_v2_Snakemake_FullAuto` directory to run the bash scripts.

1. **Data preparation**

Modify the following variables in file `.config/masterconfig.yaml`:
- `root`
    - The absolute path where you want the output to be.
- `data`
    - The path to the directory containing all input tar files.
This workflow can automatically determine the name of files in the specified `data` directory, or run only on given files :
- `get_all_tar_filename: True` will uncompress all tar files. If you want to choose the the files to uncompress, use `get_all_tar_filename: False` and give the filenames as a list in `tarIDS`


Modify the `SNG_BIND` variable in `prejob.sh`, it has to be the same as the variable `root` in `.config/masterconfig.yaml`. Change line 17 to your email adress.
If Singularity is not in the HPC environement, add `module load singularity` under Module loading.
Then run 
```bash
sbatch prejob.sh
```
This will create multiple directories to prepare the data for the workflow. You will end up with a `bam_files` directory containing all *bam* files, renamed as the tar filename if your data was named "ccs.bam", and a `fastx_files` directory containing all *fasta* and *fastq* files. The `extract` directory contains all other files that were in the tar ball.
```
workflow_results
└── 00_raw_data
    ├── bam_files
    ├── extract
    └── fastx_files
```

2. **Running the workflow**

The `fastx_files` directory will be the starting point for the assembly workflow. You can add other datasets but the workflow needs a *fasta.gz* file. If *bam* files or *fastq.gz* files are available, the workflow runs raw data quality control steps.

You will have to modify other variables in file `.config/masterconfig.yaml`:
- `get_all_filename: True` will run the workflow with all *fasta.gz* in the `fastx_files` directory as input. If you want to choose the input for the workflow, use `get_all_filename: False` and give the fasta filenames as a list in `IDS`.
- Choose your run name with `run`.
- Specify the organism ploidy with `ploidy`.
- Choose the BUSCO lineage with `lineage`.
- There are 3 modes to run hifiasm. In all cases, the organism have to be sequenced in PacBio HiFi. To choose the mode, modify the variable `mode` in file `.config/masterconfig.yaml` to either :
    - `default` for a HiFi-only assembly.
    - `trio` if you have parental reads (either HiFi or short reads) in addition to the sequencing of the organism.
        - Add a key corresponding to your filename and modify the variables `p1` and `p2` to be the parental reads. Supported filetypes are *fasta*, *fasta.gz*, *fastq* and *fastq.gz*.
    - `hi-c` if the organism has been sequenced in paired-end Hi-C as well.
        - Add a key corresponding to your filename an modify the variables `r1` and `r2` to be the paired-end Hi-C reads. Supported filetypes are *fasta*, *fasta.gz*, *fastq* and *fastq.gz*.

For example
```yaml
# trio datasets
sibling_1_dataset_placeholder:
  p1: path/to/parent/1/reads
  p2: path/to/parent/2/reads

sibling_2_dataset_placeholder:
  p1: path/to/parent/1/reads
  p2: path/to/parent/2/reads

# Hi-C datasets
hic_sample_dataset_1_name_placeholder:
  r1: path/to/r1/reads
  r2: path/to/r2/reads

hic_sample_dataset_2_name_placeholder:
  r1: path/to/r1/reads
  r2: path/to/r2/reads
```

Modify the `SNG_BIND` variable in `job.sh`, it has to be the same as the variable `root` in `.config/masterconfig.yaml`. Change line 17 to your email adress.
If Singularity is not in the HPC environement, add `module load singularity` under Module loading.
Then run 
```bash
sbatch job.sh
```

All the slurm output logs are in the `slurm_logs` directory. There are .out and .err files for the worklow (*snakemake.cortex**) and for each rules (*rulename.cortex**).

### Dry run
To check if the workflow will run fine, you can do a dry run: uncomment line 56 in `job.sh` and comment line 59, then run
```bash
sbatch job.sh
```
Check the snakemake.cortex*.out file in the `slurm_logs` directory, you should see a summary of the workflow.

### Outputs
These are the directories for the data produced by the workflow:
- An automatic report is generated in the `RUN` directory.
- `01_raw_data_QC` contains all quality control ran on the reads. FastQC and LongQC create html reports on fastq and bam files respectively, reads stats are given by Genometools, and predictions of genome size and heterozygosity are given by Genomescope (in directory `04_kmer`).
- `02_genome_assembly` contains 2 assemblies. The first one is in `01_raw_assembly`, it is the assembly obtained with hifiasm. The second one is in `02_after_purge_dups_assembly`, it is the hifiasm assembly after haplotigs removal by purge_dups. Both assemblies have a `01_assembly_QC` directory containing assembly statistics done by Genometools (in directory `assembly_stats`), BUSCO analyses (`busco`), k-mer profiles with KAT (`katplot`) and completedness and QV stats with Merqury (`merqury`) as well as assembled telomeres with FindTelomeres (`telomeres`).

```
workflow_results
├── 00_raw_data
└── FILENAME
    └── RUN
        ├── 01_raw_data_QC
        │   ├── 01_fastQC
        │   ├── 02_longQC
        │   ├── 03_genometools
        |   └── 04_kmer
        |       └── genomescope
        └── 02_genome_assembly
            ├── 01_raw_assembly
            │   ├── 00_assembly
            |   └── 01_assembly_QC
            |       ├── assembly_stats
            |       ├── busco
            |       ├── katplot
            |       ├── merqury
            |       └── telomeres
            └── 02_after_purge_dups_assembly
                ├── 00_assembly
                |   ├── hap1
                |   └── hap2
                └── 01_assembly_QC
                    ├── assembly_stats
                    ├── busco
                    ├── katplot
                    ├── merqury
                    └── telomeres
```


## Common Snakemake errors
### Unlock directory
When you try to rerun the workflow after cancelling a job, you may have to unlock the results directory. To do so, go in `.config/snakemake_profile/slurm` and uncomment line 14 of `config.yaml`. Run the workflow once to unlock the directory (it should only take a few seconds). Still in `config.yaml`, comment line 14. The workflow will be able to run and create outputs.