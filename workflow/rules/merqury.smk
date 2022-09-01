### temporary haplotype copy used by merqury
rule cp_hap:
    input:
        hap1=rules.hap_gfa_to_fasta.output.hap1_fa,
        hap2=rules.hap_gfa_to_fasta.output.hap2_fa
    output:
        hap1=temp("{resdir}/{id}/{run}/{stepdir}/{asmdir}/{subdir}/merqury/{id}_hap1.fa.gz"),
        hap2=temp("{resdir}/{id}/{run}/{stepdir}/{asmdir}/{subdir}/merqury/{id}_hap2.fa.gz")
    params:
        path = "{resdir}/{id}/{run}/{stepdir}/{asmdir}/{subdir}/merqury"
    shell:
        "cp {{{input.hap1},{input.hap2}}} {params.path}"

### assembly quality
rule merqury:
    input:
        read_db = rules.meryl.output,
        hap1 = rules.cp_hap.output.hap1,
        hap2 = rules.cp_hap.output.hap2
    output:
        "{resdir}/{id}/{run}/{stepdir}/{asmdir}/{subdir}/merqury/merqury.qv",
        "{resdir}/{id}/{run}/{stepdir}/{asmdir}/{subdir}/merqury/merqury.completeness.stats"
    params:
        prefix = "merqury",
        path = "{resdir}/{id}/{run}/{stepdir}/{asmdir}/{subdir}/merqury",
    threads: 20
    resources:
        mem_mb=60000
    container:
        "workflow/img/merqury.sif"
    shell:
        "cd {params.path} && "
        "export MERQURY=/usr/local/share/merqury && "
        "merqury.sh {input.read_db} {input.hap1} {input.hap2} {params.prefix}"

# similar to merqury.smk
## copy reads db created with meryl
rule purge_cp_meryl:
    input:
        rules.meryl.output
    output:
        temp(directory("{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm_qc"] + "/merqury/{id}_reads-db_k21.meryl"))
    params:
        path="{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm_qc"] + "/merqury"
    shell:
        "cp -r {input} {params.path}"

use rule cp_hap as purge_cp with:
    input:
        hap1="{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm"] + "/hap1/{id}_hap1.purged.fa",
        hap2="{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm"] + "/hap2/{id}_hap2.purged.fa"
    output:
        hap1=temp("{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm_qc"] + "/merqury/{id}_hap1.purged.fa"),
        hap2=temp("{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm_qc"] + "/merqury/{id}_hap2.purged.fa")
    params:
        path="{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm_qc"] + "/merqury"

use rule merqury as purge_merqury with:
    input:
        read_db = rules.purge_cp_meryl.output,
        hap1 = rules.purge_cp.output.hap1,
        hap2 = rules.purge_cp.output.hap2
    output:
        "{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm_qc"] + "/merqury/purge_merqury.qv",
        "{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm_qc"] + "/merqury/purge_merqury.completeness.stats"
    params:
        prefix = "purge_merqury",
        path = "{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm_qc"] + "/merqury"