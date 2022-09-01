def get_p1(wildcards):
    id = wildcards.id
    p1 = config[f'{id}']["p1"]
    return p1

def get_p2(wildcards):
    id = wildcards.id
    p2 = config[f'{id}']["p2"]
    return p2

rule meryl_trio:
    input:
        p1 = get_p1,
        p2 = get_p2
    output:
        p1 = directory("{resdir}/{id}/{run}/{stepdir}/" + config["asm_raw"] + "/" + config["asm_qc"] + "/merqury/P1_reads-db_k21.meryl"),
        p2 = directory("{resdir}/{id}/{run}/{stepdir}/" + config["asm_raw"] + "/" + config["asm_qc"] + "/merqury/P2_reads-db_k21.meryl")
    threads: 10
    resources:
        mem_mb=60000
    container:
        "workflow/img/merqury.sif"
    shell:
        "meryl k=21 count {input.p1} output {output.p1} && "
        "meryl k=21 count {input.p2} output {output.p2}"

rule cp_trio:
    input:
        hap1 = rules.hap_gfa_to_fasta.output.hap1_fa,
        hap2 = rules.hap_gfa_to_fasta.output.hap2_fa
    output:
        hap1 = temp("{resdir}/{id}/{run}/{stepdir}/" + config["asm_raw"] + "/" + config["asm_qc"] + "/merqury/{id}_hap1.fasta.gz"),
        hap2 = temp("{resdir}/{id}/{run}/{stepdir}/" + config["asm_raw"] + "/" + config["asm_qc"] + "/merqury/{id}_hap2.fasta.gz")
    params:
        path="{resdir}/{id}/{run}/{stepdir}/" + config["asm_raw"] + "/" + config["asm_qc"] + "/merqury"
    shell:
        "cp {input.hap1} {output.hap1} && "
        "cp {input.hap2} {output.hap2}"

rule unzip:
    input:
        rules.cp_trio.output.hap1,
        rules.cp_trio.output.hap2
    output:
        hap1 = temp("{resdir}/{id}/{run}/{stepdir}/" + config["asm_raw"] + "/" + config["asm_qc"] + "/merqury/{id}_hap1.fasta"),
        hap2 = temp("{resdir}/{id}/{run}/{stepdir}/" + config["asm_raw"] + "/" + config["asm_qc"] + "/merqury/{id}_hap2.fasta")
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
        "{resdir}/{id}/{run}/{stepdir}/" + config["asm_raw"] + "/" + config["asm_qc"] + "/merqury/merqury_trio.completeness.stats",
        "{resdir}/{id}/{run}/{stepdir}/" + config["asm_raw"] + "/" + config["asm_qc"] + "/merqury/merqury_trio.qv",
        "{resdir}/{id}/{run}/{stepdir}/" + config["asm_raw"] + "/" + config["asm_qc"] + "/merqury/merqury_trio.{id}_hap1.block.N.png",
        "{resdir}/{id}/{run}/{stepdir}/" + config["asm_raw"] + "/" + config["asm_qc"] + "/merqury/merqury_trio.{id}_hap2.block.N.png",
        "{resdir}/{id}/{run}/{stepdir}/" + config["asm_raw"] + "/" + config["asm_qc"] + "/merqury/merqury_trio.{id}_hap1.100_20000.phased_block.stats",
        "{resdir}/{id}/{run}/{stepdir}/" + config["asm_raw"] + "/" + config["asm_qc"] + "/merqury/merqury_trio.{id}_hap2.100_20000.phased_block.stats",
        "{resdir}/{id}/{run}/{stepdir}/" + config["asm_raw"] + "/" + config["asm_qc"] + "/merqury/merqury_trio.hapmers.blob.png",
        p1_hapmer = directory("{resdir}/{id}/{run}/{stepdir}/" + config["asm_raw"] + "/" + config["asm_qc"] + "/merqury/P1_reads-db_k21.hapmer.meryl"),
        p2_hapmer = directory("{resdir}/{id}/{run}/{stepdir}/" + config["asm_raw"] + "/" + config["asm_qc"] + "/merqury/P2_reads-db_k21.hapmer.meryl")
    params:
        path = "{resdir}/{id}/{run}/{stepdir}/" + config["asm_raw"] + "/" + config["asm_qc"] + "/merqury",
        prefix = "merqury_trio"
    threads: 20
    resources:
        mem_mb=60000
    container:
        "workflow/img/merqury.sif"
    shell:
        "cd {params.path} && "
        "export MERQURY=/usr/local/share/merqury && "
        "$MERQURY/trio/hapmers.sh {input.p1} {input.p2} {input.read_db} && "
        "merqury.sh {input.read_db} {output.p1_hapmer} {output.p2_hapmer} {input.hap1} {input.hap2} {params.prefix}"

### merqury after purging the haplotypes
rule cp_purge_trio:
    input:
        meryl_db = rules.meryl.output,
        p1 = rules.merqury_trio.output.p1_hapmer,
        p2 = rules.merqury_trio.output.p2_hapmer
    output:
        meryl_db = temp(directory("{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm_qc"] + "/merqury/{id}_reads-db_k21.meryl")),
        p1 = temp(directory("{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm_qc"] + "/merqury/P1_reads-db_k21.hapmer.meryl")),
        p2 = temp(directory("{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm_qc"] + "/merqury/P2_reads-db_k21.hapmer.meryl"))
    params:
        path = "{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" +  config["asm_qc"] + "/merqury",
    shell:
        "cp -r {input.meryl_db} {params.path} && "
        "ln -s {input.p1} {output.p1} && "
        "ln -s {input.p2} {output.p2}"

rule cp_hap_trio:
    input:
        hap1 = "{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm"] + "/hap1/{id}_hap1.purged.fa",
        hap2 = "{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm"] + "/hap2/{id}_hap2.purged.fa",
    output:
        hap1 = temp("{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm_qc"] + "/merqury/{id}_hap1.purged.fasta"),
        hap2 = temp("{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm_qc"] + "/merqury/{id}_hap2.purged.fasta"),
    params:
        path = "{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm_qc"] + "/merqury"
    shell:
        "cp {input.hap1} {output.hap1} && "
        "cp {input.hap2} {output.hap2}"

rule purge_merqury_trio:
    input:
        p1 = rules.cp_purge_trio.output.p1,
        p2 = rules.cp_purge_trio.output.p2,
        read_db = rules.cp_purge_trio.output.meryl_db,
        hap1 = rules.cp_hap_trio.output.hap1,
        hap2 = rules.cp_hap_trio.output.hap2
    output:
        "{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm_qc"] + "/merqury/purge_merqury_trio.{id}_hap1.purged.100_20000.phased_block.stats",
        "{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm_qc"] + "/merqury/purge_merqury_trio.{id}_hap2.purged.100_20000.phased_block.stats",
        "{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm_qc"] + "/merqury/purge_merqury_trio.{id}_hap1.purged.block.N.png",
        "{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm_qc"] + "/merqury/purge_merqury_trio.{id}_hap2.purged.block.N.png",
        "{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm_qc"] + "/merqury/purge_merqury_trio.qv",
        "{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm_qc"] + "/merqury/purge_merqury_trio.completeness.stats",
        "{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm_qc"] + "/merqury/purge_merqury_trio.hapmers.blob.png"
    params:
        path = "{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm_qc"] + "/merqury",
        prefix = "purge_merqury_trio"
    threads: 20
    resources:
        mem_mb=60000
    container:
        "workflow/img/merqury.sif"
    shell:
        "cd {params.path} && "
        "export MERQURY=/usr/local/share/merqury && "
        "merqury.sh {input.read_db} {input.p1} {input.p2} {input.hap1} {input.hap2} {params.prefix}"