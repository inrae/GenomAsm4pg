# Workflow Steps and Program Versions

Images are automatically pulled by Snakemake on first run and stored in the project's container registry. Note that you can modify the container registry in the `./config/masterconfig.yaml` file to add your own instead.

## 01. Assembly

Assembly:
- [hifiasm](https://github.com/chhylp123/hifiasm) 0.24.0-r703
- [YAK](https://github.com/lh3/yak) 0.1
- [fastp](https://github.com/OpenGene/fastp) 0.24.0
- [YaHS](https://github.com/c-zhou/yahs) 1.2.2
- [Samtools](https://github.com/samtools/samtools) 1.18
- [bwa] (https://github.com/lh3/bwa)

Haplotigs and Overlaps Purging:
- [purge_dups](https://github.com/dfguan/purge_dups) 1.2.5
- matplotlib 0.11.5

Scaffolding:
- [RagTag](https://github.com/malonge/RagTag)

## Quality Control

K-mer Analysis:
- [jellyfish](https://github.com/gmarcais/Jellyfish) 2.3.0
- [genomescope](https://github.com/tbenavi1/genomescope2.0) 2.0

Metrics:
- [genometools](https://github.com/genometools/genometools) 1.5.9

Assembly Quality Control:
- [BUSCO](https://gitlab.com/ezlab/busco) 5.7.1
- [KAT](https://github.com/TGAC/KAT) 2.4.1

Error Rate, QV & Phasing:
- [meryl](https://github.com/marbl/meryl) and [merqury](https://github.com/marbl/merqury) 1.3

Telomere Detection:
- [FindTelomeres](https://github.com/JanaSperschneider/FindTelomeres)
- Biopython 1.75

Repeated Elements Quantification:
- [LTR_retriever](https://github.com/oushujun/LTR_retriever) 3.0.1
- [LTR_Finder](https://github.com/xzhub/LTR_Finder) (latest as of October 2024)

Contig Length Analysis:
- [QUAST](https://github.com/ablab/quast) 5.2.0

Report Generation:
- R markdown 4.0.3