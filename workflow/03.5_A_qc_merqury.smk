######### MERQURY
### create reads db necessary for merqury
rule meryl:
    input:
        config["root"] + "/" + config["resdir"] + "/" + config["fastxdir"] + "/{id}.fasta.gz"
    output:
        directory("{resdir}/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury/{id}_reads-db_k21.meryl")
    threads: 20
    resources:
        mem_mb=60000
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/merqury1.3"
    shell:
        "meryl k=21 count {input} output {output}"

### temporary haplotype copy used by merqury
rule cp_hap:
    input:
        hap1=rules.hap_gfa_to_fasta.output.hap1_fa,
        hap2=rules.hap_gfa_to_fasta.output.hap2_fa
    output:
        hap1=temp("{resdir}/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury/{id}_hap1.fa.gz"),
        hap2=temp("{resdir}/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury/{id}_hap2.fa.gz")
    params:
        path = "{resdir}/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury"
    shell:
        "cp {{{input.hap1},{input.hap2}}} {params.path}"

### assembly quality
rule merqury:
    input:
        read_db = rules.meryl.output,
        hap1 = rules.cp_hap.output.hap1,
        hap2 = rules.cp_hap.output.hap2
    output:
        qv = "{resdir}/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury/{id}_merqury.qv",
        stat = "{resdir}/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury/{id}_merqury.completeness.stats"
    params:
        prefix = "{id}_merqury",
        path = "{resdir}/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury",
    threads: 20
    resources:
        mem_mb=60000
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/merqury1.3"
    shell:
        "cd {params.path} && "
        "export MERQURY=/usr/local/share/merqury && "
        "merqury.sh {input.read_db} {input.hap1} {input.hap2} {params.prefix}"