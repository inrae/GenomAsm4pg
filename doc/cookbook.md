## Running the assembly

**I have really high coverage, I want to downsample**
- *Why*: sometimes really high coverage can confuse hifiasm.
- *How to*: `run_downsampling: True` and `target_coverage: 50` (50X is usually plenty).

**I have parental reads**
- *Why*: parental k-mers let hifiasm assign each contig to a parent, giving two truly
  phased haplotypes instead of two arbitrary ones.
- *How to*: `mode: trio`, with `r1` and `r2` pointing at the two parents' read files. 

**I have Hi-C data**
- *Why*: Hi-C contact frequency phases the assembly without parents, and then scaffolds
  the contigs into chromosome-scale pieces.
- *How to*: `mode: hi-c`, with `r1`/`r2` the Hi-C R1/R2 FASTQ.

**I have ONT data**
- *Why*: hifiasm assembles ONT simplex R10 reads, but it needs the base qualities.
- *How to*: `mode: ont`, and give **FASTQ or BAM** a FASTA has no qualities and will be
  refused. Note hifiasm still labels this mode beta.

## Reading the results

**I have more than two peaks in the GenomeScope profile**
- *Why*: extra peaks usually mean the genome is not diploid or that something else is in
  the reads (contamination, organelles).
- *How to*: curentely we can only handle haploid and diploid genomes. 

**I have a lot of duplicated BUSCOs**
- *Why*: a high `D` in the compleasm summary almost always means retained haplotigs the
  same locus present once per haplotype in a single assembly.
- *How to*: `run_purge_dups: True`, then compare. Cross-check with the Merqury copy-number
  spectra: false duplication shows as read k-mers present twice in the assembly.

**I want BUSCO instead of compleasm**
- *Why*: a reviewer or a comparison with older work asks for BUSCO by name. On eukaryotes
  both align with miniprot and agree closely; compleasm is the faster of the two.
- *How to*: `use_busco: True` on the sample. Same `busco_lineage`, same place in the report,
  and the other tool does not run at all.

**Is purge_dups worth it?**
- *Why*: hifiasm already purges at `assembly_purge_force` (`-l`, default 3). purge_dups is
  a second, coverage-based pass.
- *How to*: worth it when duplication survives that first pass. It cuts both ways too
  aggressive and it deletes real sequence, so check the cutoffs plot the workflow produces
  and the completeness numbers before and after.

**What is a LAI score?**
- *Why*: the LTR Assembly Index rates assembly quality from how many intact LTR
  retrotransposons were reconstructed: <10 draft, 10–20 reference, >20 gold.
- It only means something in repeat-rich genomes a
  gene-dense or small genome may hold too few LTR-RTs for a score to be produced at all.

**What is QV?**
- *Why*: Merqury's consensus quality, on a log scale: QV 40 is one error per 10 kb, QV 50
  one per 100 kb. Higher is better.
- *How to*: read it in the report. It is reference-free it compares k-mers in the
  assembly against k-mers in your own reads.

**Is there a difference between the GFA and the FASTA?**
- *Why*: the GFA is the assembly *graph* the contigs plus how they connect and overlap.
  The FASTA is only the sequences, with those relationships dropped.
- *How to*: use the FASTA for anything downstream; open the raw GFA from
  `01_raw_assembly/` in Bandage when you want to see why a region stayed fragmented.

## Organelles and references

**I want to assemble the mitochondrion**
- *Why*: the mitogenome is recovered *from the finished assembly*, which works better than
  trying to isolate its reads beforehand.
- *How to*: `reference_mitochondrial_genome: [mitogenome.fasta, annotation.gb]` from a
  related species. Both files are required MitoHiFi needs the annotation. Providing the
  reference is what switches the step on; there is no separate flag.

**I want to extract chloroplast reads**
- *Why*: the plastid is high-copy and would otherwise become contigs in the nuclear
  assembly. It is removed from the *reads*, before assembly.
- *How to*: `reference_chloroplast_genome: chloroplast.fasta`. The reads pulled out are
  kept in `00_preprocess/chloroplast_<sample>.fasta.gz`.

**What is RagTag?**
- *Why*: it orders and orients your contigs against a reference to produce scaffolds. It
  adds no sequence and corrects nothing it only arranges what you assembled.
- *How to*: `run_ragtag: True` and `reference_genome: ref.fasta.gz`. Use a close relative;
  a distant reference will impose an order your genome does not have.
