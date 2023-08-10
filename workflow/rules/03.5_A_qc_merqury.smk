######### MERQURY
### create reads db necessary for merqury
rule meryl:
    input:
        config["root"] + "/" + config["resdir"] + "/" + config["fastxdir"] + "/{id}.fasta.gz"
    output:
        directory(res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury/{id}_reads-db_k21.meryl")
    benchmark:
        res_path + "/{runid}/benchmark/{id}_meryl.txt"
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
        hap1=temp(res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury/{id}_hap1.fa.gz"),
        hap2=temp(res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury/{id}_hap2.fa.gz")
    params:
        path = res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury"
    shell:
        "cp {{{input.hap1},{input.hap2}}} {params.path}"

### assembly quality
rule merqury:
    input:
        read_db = rules.meryl.output,
        hap1 = rules.cp_hap.output.hap1,
        hap2 = rules.cp_hap.output.hap2
    output:
        qv = res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury/{id}_merqury.qv",
        stat = res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury/{id}_merqury.completeness.stats"
    params:
        prefix = "{id}_merqury",
        path = res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury",
    benchmark:
        res_path + "/{runid}/benchmark/{id}_merqury.txt"
    threads: 20
    resources:
        mem_mb=60000
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/merqury1.3"
    shell:
        "cd {params.path} && "
        "export MERQURY=/usr/local/share/merqury && "
        "merqury.sh {input.read_db} {input.hap1} {input.hap2} {params.prefix}"

######### MERQURY TRIO
rule meryl_trio:
    input:
        p1 = get_p1,
        p2 = get_p2
    output:
        p1 = directory(res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury/{id}_P1_reads-db_k21.meryl"),
        p2 = directory(res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury/{id}_P2_reads-db_k21.meryl")
    benchmark:
        res_path + "/{runid}/benchmark/{id}_meryl_trio.txt"
    threads: 10
    resources:
        mem_mb=60000
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/merqury1.3"
    shell:
        "meryl k=21 count {input.p1} output {output.p1} && "
        "meryl k=21 count {input.p2} output {output.p2}"

rule cp_trio:
    input:
        hap1 = rules.hap_gfa_to_fasta.output.hap1_fa,
        hap2 = rules.hap_gfa_to_fasta.output.hap2_fa
    output:
        hap1 = temp(res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury/{id}_hap1.fasta.gz"),
        hap2 = temp(res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury/{id}_hap2.fasta.gz")
    params:
        path=res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury"
    shell:
        "cp {input.hap1} {output.hap1} && "
        "cp {input.hap2} {output.hap2}"

rule unzip:
    input:
        rules.cp_trio.output.hap1,
        rules.cp_trio.output.hap2
    output:
        hap1 = temp(res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury/{id}_hap1.fasta"),
        hap2 = temp(res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury/{id}_hap2.fasta")
    shell:
        "unpigz -k -p 1 {input}"

rule merqury_trio:
    input:
        p1 = rules.meryl_trio.output.p1,
        p2 = rules.meryl_trio.output.p2,
        read_db = rules.meryl.output,
        hap1 = rules.unzip.output.hap1,
        hap2 = rules.unzip.output.hap2
    output:
        res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury/{id}_merqury_trio.qv",
        res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury/{id}_merqury_trio.completeness.stats",
        res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury/{id}_merqury_trio.{id}_hap1.block.N.png",
        res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury/{id}_merqury_trio.{id}_hap2.block.N.png",
        res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury/{id}_merqury_trio.{id}_hap1.100_20000.phased_block.stats",
        res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury/{id}_merqury_trio.{id}_hap2.100_20000.phased_block.stats",
        res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury/{id}_merqury_trio.hapmers.blob.png",
        p1_hapmer = directory(res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury/{id}_P1_reads-db_k21.hapmer.meryl"),
        p2_hapmer = directory(res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury/{id}_P2_reads-db_k21.hapmer.meryl")
    params:
        path = res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury",
        prefix = "{id}_merqury_trio"
    benchmark:
        res_path + "/{runid}/benchmark/{id}_merqury_trio.txt"
    threads: 20
    resources:
        mem_mb=60000
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/merqury1.3"
    shell:
        "cd {params.path} && "
        "export MERQURY=/usr/local/share/merqury && "
        "$MERQURY/trio/hapmers.sh {input.p1} {input.p2} {input.read_db} && "
        "merqury.sh {input.read_db} {output.p1_hapmer} {output.p2_hapmer} {input.hap1} {input.hap2} {params.prefix}"

