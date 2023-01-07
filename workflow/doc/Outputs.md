[TOC]

# Directories
There are three directories for the data produced by the workflow:
- An automatic report is generated in the `RUN` directory.
- `01_raw_data_QC` contains all quality control ran on the reads. FastQC and LongQC create HTML reports on fastq and bam files respectively, reads stats are given by Genometools, and predictions of genome size and heterozygosity are given by Genomescope (in directory `04_kmer`).
- `02_genome_assembly` contains 2 assemblies. The first one is in `01_raw_assembly`, it is the assembly obtained with hifiasm. The second one is in `02_after_purge_dups_assembly`, it is the hifiasm assembly after haplotigs removal by purge_dups. Both assemblies have a `01_assembly_QC` directory containing assembly statistics done by Genometools (in directory `assembly_stats`), BUSCO analyses (`busco`), k-mer profiles with KAT (`katplot`) and completedness and QV stats with Merqury (`merqury`) as well as assembled telomeres with FindTelomeres (`telomeres`).
- `benchmark` contains main programs runtime

```
workflow_results
├── 00_input_data
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

# Additional files
- Symbolic links to haplotype 1 and haplotype 2 assemblies after purge_dups
- HTML report with the main results from each program
- Runtime file with the total workflow runtime for the dataset
