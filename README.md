# <A HREF="https://forgemia.inra.fr/asm4pg/GenomAsm4pg"> asm4pg </A>

An automatic and reproducible genome assembly workflow for pangenomic applications using PacBio HiFi data.

This workflow uses [Snakemake](https://snakemake.readthedocs.io/en/stable/) to quickly assemble genomes with a HTML report summarizing obtained assembly stats.

A first script (`prejob.sh`) prepares the data until _fasta.gz_ files are obtained. A second script (`job.sh`) runs the genome assembly and stats.

![workflow DAG](fig/rule_dag.svg)

## Table of contents

[TOC]

## Repo directory structure

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
- slurm
- conda
- singularity

## Workflow steps, programs & Docker images pulled by Snakemake

All images here will be pulled automatically by Snakemake the first time you run the workflow. It may take some time. Images are only downloaded once and reused automatically by the workflow.
Images are stored on the project's container registry but come from various container libraries:

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
    - image version: v5.3.1_cv1 ([link](https://hub.docker.com/r/ezlabgva/busco/tags))
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
    - **matplotlib** image version: v0.11.5-5-deb-py3_cv1 ([link](https://hub.docker.com/r/biocontainers/matplotlib-venn/tags))

**Report**

- **R markdown**
  - image version: 4.0.3 ([link](https://hub.docker.com/r/reslp/rmarkdown/tags))

## How to run the workflow

### Profile setup

The current profile is made for SLURM. To run this workflow on another HPC, create another profile (https://github.com/Snakemake-Profiles) and add it in the `.config/snakemake_profile` directory. Change the `CLUSTER_CONFIG` and `PROFILE` variables in `job.sh` and `prejob.sh`.
If you are using the current SLURM setup, change line 13 to your email adress in the `cluster_config`.yml file.

### SLURM logs

SLURM submission scripts, prejob.sh and job.sh, output standard and error output into slurm_logs directory. This directory must exist before running any of these submission script else slurm will refuse to submit these jobs.

```
# create if not exist
mkdir -p slurm_logs
```

## Workflow execution

Navigate into the `GenomAsm4pg` directory to run the bash scripts.

## Running the prejob

Create a test_data folder to hold the test data that will be used to run the pipeline and cd into it.

```
$ mkdir -p test_data
$ cd test_data/
```

Download the test data from `raw.github...` and place it into the `test_data` folder

Modify the following variables in the following files:

`.config/masterconfig.yaml`:

- `root`
  - The path where you want the output to be.
  - Set this as `./GenomAsm4pg`.
- `data`
  - The path where you want the input data to be.
  - Set this to `./test_data/`.
  - Alternatively, you have the option of running only on user-specified files:
    - Setting `get_all_tar_filename: True`, will uncompress all tar files.
    - If you want to choose the the files to uncompress, set `get_all_tar_filename: False` and type out the filenames as a list in `tarIDS`

`./prejob.sh`:

- `SNG_BIND`
  - Set this to be the same as the variable `root` in `.config/masterconfig.yaml` which should be `./GenomAsm4pg`
- Line 17, `#SBATCH --mail-user=`
  - Set this to be your email adress.
- `### Module Loading:`
  - If Singularity is not in the HPC environement, add `module load singularity` under Module loading.

Once these variables have been set, run the following:

```bash
sbatch prejob.sh
```

This will create multiple directories to prepare the data for the workflow. You will end up with a `bam_files` directory containing all _bam_ files, renamed as the tar filename if your data was named "ccs.bam", and a `fastx_files` directory containing all _fasta_ and _fastq_ files. The `extract` directory contains all other files that were in the tar ball.

```
workflow_results
└── 00_raw_data
    ├── bam_files
    ├── extract
    └── fastx_files
```

## Running the main workflow

The `fastx_files` directory will be the starting point for the assembly workflow. You can add other datasets but the workflow needs a _fasta.gz_ file. If _bam_ files or _fastq.gz_ files are available, the workflow runs raw data quality control steps.

You will have to modify other variables in `.config/masterconfig.yaml`:

- Setting `get_all_filenames: True` will take all of the `.fasta.gz` files in the `fastx_files` directory and set them as a list in `IDS`.
- Alternatively, give the fasta filenames as a list in `IDS` to specify files you want to run the pipeline on.

Your config should also follow this template

```yaml
# default assembly mode
sample_1_file_name:
  run: name
  ploidy: 2
  busco_lineage: eudicots_odb10
  mode: default

# trio assembly mode
sample_2_file_name:
  run: name
  ploidy: 2
  busco_lineage: eudicots_odb10
  mode: trio
  p1: path/to/parent/1/reads
  p2: path/to/parent/2/reads

  # hi-c assembly mode
sample_3_file_name:
  run: name
  ploidy: 2
  busco_lineage: eudicots_odb10
  mode: hi-c
  r1: path/to/r1/reads
  r2: path/to/r2/reads
```

- Make sure to set the `Sample_1_file_name` keys to match the file names in the `fastx_files` directory. An example can be seen in the `masterconfig.yaml` file which is configured to run on the provided test data.
- Choose your run name by setting `run`.
- Specify the organism ploidy with `ploidy`.
- Choose the BUSCO lineage with `lineage`.
- There are 3 modes to run hifiasm. In all cases, the organism has to be sequenced in PacBio HiFi. To choose the mode, modify the variable `mode` to either :
  - `default` for a HiFi-only assembly.
  - `trio` if you have parental reads (either HiFi or short reads) in addition to the sequencing of the organism.
    - Add a key corresponding to your filename and modify the variables `p1` and `p2` to be the parental reads. Supported filetypes are _fasta_, _fasta.gz_, _fastq_ and _fastq.gz_.
  - `hi-c` if the organism has been sequenced in paired-end Hi-C as well.
    - Add a key corresponding to your filename an modify the variables `r1` and `r2` to be the paired-end Hi-C reads. Supported filetypes are _fasta_, _fasta.gz_, _fastq_ and _fastq.gz_.

Modify the following variables in `./job.sh`:

- `SNG_BIND`
  - Set this to be the same as the variable `root` in `.config/masterconfig.yaml` which should be `./GenomAsm4pg`
- Line 17, `#SBATCH --mail-user=`
  - Set this to be your email adress.
- `### Module Loading:`
  - If Singularity is not in the HPC environement, add `module load singularity` under Module loading.

Once these variables have been set, run the following:

```bash
sbatch job.sh
```

All the slurm output logs are in the `slurm_logs` directory. There are .out and .err files for the worklow (*snakemake.cortex\*\*) and for each rules (*rulename.cortex\*\*).

### Dry run

To check if the workflow will run fine, you can do a dry run: uncomment line 56 in `job.sh` and comment line 59, then run

```bash
sbatch job.sh
```

Check the snakemake.cortex\*.out file in the `slurm_logs` directory, you should see a summary of the workflow.

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

## Known problems/errors

### HPC

The workflow does not work if the HPC does not allow a job to run other jobs.

### BUSCO

The first time you run the workflow, if there are multiple samples, the BUSCO lineage might be downladed multiple times. This can create a conflict between the jobs using BUSCO and may interrupt some of them. In that case, you only need to rerun the workflow once everything is done.

### Snakemake locked directory

When you try to rerun the workflow after cancelling a job, you may have to unlock the results directory. To do so, go in `.config/snakemake_profile/slurm` and uncomment line 14 of `config.yaml`. Run the workflow once to unlock the directory (it should only take a few seconds). Still in `config.yaml`, comment line 14. The workflow will be able to run and create outputs.

## How to cite asm4pg?

We are currently writing a publication about asm4pg. Meanwhile, if you use the pipeline, please cite it using the address of this repository.

## License

The content of this repository is licensed under <A HREF="https://choosealicense.com/licenses/gpl-3.0/">(GNU GPLv3)</A>

## Contacts

For any troubleshouting, issue or feature suggestion, please use the issue tab of this repository.
For any other question or if you want to help in developing asm4pg, please contact Ludovic Duvaux at ludovic.duvaux@inrae.fr
