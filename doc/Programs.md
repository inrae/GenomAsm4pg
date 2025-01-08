# Workflow steps and program versions
All images here will be pulled automatically by Snakemake the first time you run the workflow. It may take some time. Images are only downloaded once and reused automatically by the workflow.
Images are stored on the project's container registry but come from various container libraries:

## 1. Pre-assembly
- Conversion of PacBio bam to fasta & fastq
    - [smrtlink](https://www.pacb.com/support/software-downloads/) 9.0.0
- Fastq to fasta conversion
    - [seqtk](https://github.com/lh3/seqtk) 1.3
- Raw data quality control
    - [fastqc](https://github.com/s-andrews/FastQC) 0.12.1
    - [lonqQC](https://github.com/yfukasawa/LongQC) 1.2.0c
- Metrics
    - [genometools](https://github.com/genometools/genometools) 1.5.9
- K-mer analysis
    - [jellyfish](https://github.com/gmarcais/Jellyfish) 2.3.0
    - [genomescope](https://github.com/tbenavi1/genomescope2.0) 2.0

## 2. Assembly
- Assembly
    - [hifiasm](https://github.com/chhylp123/hifiasm) 0.19.6
    - [YAK](https://github.com/lh3/yak) 0.1
- Metrics
    - [genometools](https://github.com/genometools/genometools) 1.5.9
- Assembly quality control
    - [BUSCO](https://gitlab.com/ezlab/busco) 5.7.1
    - [KAT](https://github.com/TGAC/KAT) 2.4.1
- Error rate, QV & phasing
    - [meryl](https://github.com/marbl/meryl) and [merqury](https://github.com/marbl/merqury) 1.3
- Detect assembled telomeres
    - [FindTelomeres](https://github.com/JanaSperschneider/FindTelomeres)
        - **Biopython** 1.75 
- Haplotigs and overlaps purging 
    - [purge_dups](https://github.com/dfguan/purge_dups) 1.2.5
        - **matplotlib** 0.11.5
- Repeted elements quantification 
    - [LTR_retriever](https://github.com/oushujun/LTR_retriever) 3.0.1
    - [LTR_Finder](https://github.com/xzhub/LTR_Finder) latest as of october 2024

## 3. Report
- **R markdown** 4.0.3
- [QUAST](https://github.com/ablab/quast) 5.2.0

# Docker images
The programs are pulled automatically as images by Snakemake the first time you run the workflow. It may take some time. Images are only downloaded once and reused automatically by the workflow.
Images are stored on the project's container registry but come from various container libraries:

- [smrtlink](https://hub.docker.com/r/bryce911/smrtlink/tags)
- [seqtk](https://hub.docker.com/r/nanozoo/seqtk)
- [fastqc](https://hub.docker.com/r/staphb/fastqc/tags)
- [lonqQC](https://hub.docker.com/r/grpiccoli/longqc/tags)
- [genometools](https://hub.docker.com/r/biocontainers/genometools/tags)
- [jellyfish](https://quay.io/repository/biocontainers/kmer-jellyfish?tab=tags)
- [genomescope](https://hub.docker.com/r/abner12/genomescope)
- hifiasm, custom
- yak, custom
- [BUSCO](https://hub.docker.com/r/ezlabgva/busco/tags)
- [KAT](https://quay.io/repository/biocontainers/kat)
- [meryl and merqury](https://quay.io/repository/biocontainers/merqury?tab=tags)
- [Biopython for FindTelomeres](https://quay.io/repository/biocontainers/biopython?tab=tags)
- [purge_dups](https://hub.docker.com/r/wangnan9394/purge_dups/tags)
- [matplotlib as companion to purge_dups](https://hub.docker.com/r/biocontainers/matplotlib-venn/tags)
- [R markdown](https://hub.docker.com/r/reslp/rmarkdown/tags)
- LTR_retriever
- LTR_Finder custom
- [QUAST](https://hub.docker.com/r/staphb/quast/tags)