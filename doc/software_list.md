# Workflow steps and program versions
All images here will be pulled automatically by Snakemake the first time you run the workflow. It may take some time. Images are only downloaded once and reused automatically by the workflow.
Images are stored on the project's container registry :

## 01. Assembly
- Assembly
    - [hifiasm](https://github.com/chhylp123/hifiasm) 0.19.6
    - [YAK](https://github.com/lh3/yak) 0.1
- Haplotigs and overlaps purging 
    - [purge_dups](https://github.com/dfguan/purge_dups) 1.2.5
        - **matplotlib** 0.11.5
- Scafolding 
    - [RagTag](https://github.com/malonge/RagTag)

## Quality Control
- K-mer analysis
    - [jellyfish](https://github.com/gmarcais/Jellyfish) 2.3.0
    - [genomescope](https://github.com/tbenavi1/genomescope2.0) 2.0
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
- Repeted elements quantification 
    - [LTR_retriever](https://github.com/oushujun/LTR_retriever) 3.0.1
    - [LTR_Finder](https://github.com/xzhub/LTR_Finder) latest as of october 2024
- Contig length exploration
    - [QUAST](https://github.com/ablab/quast) 5.2.0
- Report generation
    - **R markdown** 4.0.3