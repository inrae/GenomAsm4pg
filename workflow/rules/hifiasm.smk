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
    envmodules:
        "hifiasm/0.16.1"
    container:
        "docker://dmolik/hifiasm:latest"
    shell:
        "hifiasm -l3 -o {params.prefix} -t {threads} {input}"