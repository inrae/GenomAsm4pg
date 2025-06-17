# Tools and images

Images are automatically pulled by Snakemake on first run and stored in the project's container registry. Note that you can modify the container registry in the `./config/masterconfig.yaml` file to add your own instead.

## DAG of the workflow
![Workflow flowchart](dag.svg)  

## List of tools embeded in the workflow

- [hifiasm](https://github.com/chhylp123/hifiasm) 0.24.0-r703 https://doi.org/10.1038/s41592-020-01056-5 
- [Samtools](https://github.com/samtools/samtools) 1.10 and 1.13 https://doi.org/10.1093/gigascience/giab008 
- [fastp](https://github.com/OpenGene/fastp) 0.24.0  https://doi.org/10.1093/bioinformatics/bty560 
- [bwa](https://github.com/lh3/bwa)  0.7.17-r1188  https://doi.org/10.48550/arXiv.1303.3997
- [YaHS](https://github.com/c-zhou/yahs) 1.2.2  https://doi.org/10.1093/bioinformatics/btac808
- [purge_dups](https://github.com/dfguan/purge_dups) 1.2.5 https://doi.org/10.1093/bioinformatics/btaa025 
- [BUSCO](https://gitlab.com/ezlab/busco) 5.7.1  https://doi.org/10.1007/978-1-4939-9173-0_14
- biopython 1.75  https://doi.org/10.1093/bioinformatics/btp163 
- [genomescope](https://github.com/tbenavi1/genomescope2.0) 2.0 https://doi.org/10.1093/bioinformatics/btx153
- [merqury](https://github.com/marbl/merqury) and [meryl](https://github.com/marbl/meryl) 1.3 : https://doi.org/10.1186/s13059-020-02134-9
- [LTR_Finder](https://github.com/xzhub/LTR_Finder) 1.07  https://doi.org/10.1093/nar/gkm286
- [LTR_retriever](https://github.com/oushujun/LTR_retriever) 3.0.1  https://doi.org/10.1104/pp.17.01310
- [RagTag](https://github.com/malonge/RagTag) 2.0.1  https://doi.org/10.1186/s13059-022-02823-7
- [QUAST](https://github.com/ablab/quast) 5.2.0 https://doi.org/10.1093/bioinformatics/btt086
- [jellyfish](https://github.com/gmarcais/Jellyfish) 2.3.0  https://doi.org/10.1093/bioinformatics/btr011
- [KAT](https://github.com/TGAC/KAT) 2.4.1 https://doi.org/10.1093/bioinformatics/btw663
- [YAK](https://github.com/lh3/yak) 0.1
- R markdown 4.0.3
- matplotlib 0.11.5
- [genometools](https://github.com/genometools/genometools) 1.5.9 https://doi.org/10.1109/tcbb.2013.68
- [FindTelomeres](https://github.com/JanaSperschneider/FindTelomeres)