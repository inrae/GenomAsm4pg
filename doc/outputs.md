# Workflow output

## Directories
There are 4 directories for the data produced by the workflow:
- `01_raw_assembly` which contains the direct output of Hifiasm
- `02_final_assembly` which contains the assembled haplotypes that may have been purged of haplotigs and/or scafolded
- `03_raw_qc` which contains quality metrics for the reads.
- `04_assembly_qc` which contains quality metrics of the final assembly.

## Files 
```bash
results/    # Results folder containg all run
└── {sample}_results
    ├── 01_raw_assembly # Raw assembly folder with gfa and fasta files
    │   ├── {sample}_hap1.gfa
    │   ├── {sample}_hap2.gfa
    │   ├── {sample}_hap1.fasta.gz
    │   ├── {sample}_hap2.fasta.gz
    │   └──{sample}_hifiasm_benchmark.txt
    ├── 02_final_assembly # Final assembly driectory with fasta file
    │   ├── hap1
    │   │   ├── cutoffs
    │   │   ├── ragtag_scafold # Driectory that contains scafolded haplotypes
    │   │   │   └── recap.txt
    │   │   └── {sample}_final_hap1.fasta.gz
    │   └── hap2
    │       └──...
    ├── 03_raw_data_qc # Driectory that contains QC on the reads
    │   ├── genomescope
    │   │   └── ...
    │   ├── jellyfish
    │   │   └── ...
    │   └── {sample}_genometools_stats.txt
    └── 04_assembly_qc # Driectory with QC for the assembled haplotypes (one per haplotype)
        ├── hap1
        │   ├── busco
        │   │   └── busco_{sample}_hap1.txt
        │   ├── katplot
        │   │   ├── ...
        │   ├── LTR
        │   │   ├── ...
        │   ├── {sample}_hap1_genometools_stats.txt
        │   └── telomeres
        │       └── ...
        ├── merqury
        │   └── ...
        └── meryl
            └── ...
```