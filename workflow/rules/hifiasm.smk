### haplotypes assembly

rule hifiasm:
    input:
        config["root"] + "/" + config["resdir"] + "/" + config["fastxdir"] + "/{id}.fasta.gz"
    output:
        hap1 = config["root"] + "/" + config["resdir"] + "/{id}/{run}/{stepdir}/" + config["asm_raw"] + "/" + config["asm"] + "/{id}.bp.hap1.p_ctg.gfa",
        hap2 = config["root"] + "/" + config["resdir"] + "/{id}/{run}/{stepdir}/" + config["asm_raw"] + "/" + config["asm"] + "/{id}.bp.hap2.p_ctg.gfa"
    params:
        prefix = config["root"] + "/" + config["resdir"] + "/{id}/{run}/{stepdir}/" + config["asm_raw"] + "/" + config["asm"] + "/{id}"
    threads: 20
    resources:
        mem_mb=250000
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/hifiasm0.16.1"
    shell:
        "hifiasm -l3 -o {params.prefix} -t {threads} {input}"