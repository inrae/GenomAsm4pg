# Content of each .smk file
## 01_qc
For raw data QC. Rules include the following programs:
- longQC
- fastQC
- Genometools
- Jellyfish
- GenomeScope

## 02_asm
For assembly. Rules include different running modes of hifiasm, as well as a rule to obtain a FASTA from the hifiasm GFA output.

## 03_asm_qc
For assembly QC. Rules include the following programs:
- busco
- kat
- FindTelomeres
- Genometools

## 03.5_A_qc_merqury
For assembly QC. Rules include the following programs:
- meryl
- merqury
There is the regular merqury and merqury for trio

## 04_purge_dups
For assembly purging, removal of haplotigs. Include purge_dups

## 05_purged_asm_qc
For assembly QC after purging. Rules include:
- busco
- kat
- FindTelomeres
- Genometools

## 05.5_PA_qc_merqury
For assembly QC after purging. Rules include:
- meryl
- merqury
There is the regular merqury and merqury for trio

## 06_sym_link_hap
For easy acces to purged assemblies. Symbolic link in the run directory.

## 07_report
For automatic report. Report is in the run directory. Run a R markdown script.
2 versions:
- regular & hi-c
- trio