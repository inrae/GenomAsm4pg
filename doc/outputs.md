# Workflow Output

## Directories
- `01_raw_assembly`: Direct Hifiasm output
- `02_final_assembly`: Processed haplotypes (purged/scaffolded)
- `03_raw_qc`: Read quality metrics
- `04_assembly_qc`: Final assembly quality metrics

## Files
```bash
results/
└── run_results
    ├── 01_raw_assembly
    │   ├── raw_hap1.gfa                # Raw assembly graph for haplotype 1
    │   ├── raw_hap2.gfa                # Raw assembly graph for haplotype 2
    │   ├── hap1.fasta.gz               # Assembled sequence for haplotype 1
    │   ├── hap2.fasta.gz               # Assembled sequence for haplotype 2
    │   └── hifiasm_benchmark.txt       # Assembly performance metrics
    ├── 02_final_assembly
    │   ├── hap1
    │   │   ├── cutoffs                 # Purge_dups coverage cutoffs
    │   │   ├── ragtag_scafold
    │   │   │   └── recap.txt          # Scaffolding summary
    │   │   └── final_hap1.fasta.gz    # Final processed haplotype 1
    │   └── hap2                        # Similar structure for haplotype 2
    │   └── ...
    ├── 03_raw_data_qc
    │   ├── genomescope
    │   │   ├── linear_plot.png        # K-mer frequency distribution
    │   │   └── log_plot.png           # Log-scale k-mer distribution
    │   ├── jellyfish
    │   │   ├── run.histo              # K-mer count histogram
    │   │   └── run.jf                 # K-mer count database
    │   └── genometools_stats.txt      # Basic sequence statistics
    ├── 04_assembly_qc
    │ ├── hap1
    │ │   ├── busco                    # Completeness assessment
    │ │   │   └── busco_run1_hap1.txt
    │ │   ├── katplot                  # K-mer frequency analysis
    │ │   │   ├── run1_hap1.katplot.png
    │ │   │   ├── run1_hap1-main.mx.spectra-cn.png
    │ │   │   └── run1_hap1.stats
    │ │   ├── LTR                      # Transposable element analysis
    │ │   │   ├── recap_run1_hap1.tbl
    │ │   │   ├── run1_hap1.out.LAI
    │ │   │   └── run1_hap1.scn
    │ │   ├── run1_hap1_genometools_stats.txt  # Assembly statistics
    │ │   └── telomeres
    │ │   └── run1_hap1_telomeres.txt  # Telomere identification results
    │ ├── merqury                      # Assembly quality assessment
    │ │   ├── run1_merqury.completeness.stats
    │ │   ├── run1_merqury.only.hist
    │ │   └──run1_merqury.qv
    │ ├── quast                        # Assembly metrics and comparison
    │ │ └── report.html
    └── full_qc_report.html            # Complete quality control summary
```