def get_r1(wildcards):
    id = wildcards.id
    r1 = config[f'{id}']["r1"]
    return r1

def get_r2(wildcards):
    id = wildcards.id
    r2 = config[f'{id}']["r2"]
    return r2

rule hifiasm_hic:
    input:
        # Hi-C paired-end reads
        r1 = get_r1,
        r2 = get_r2,
        # hifi reads
        hifi = config["root"] + "/" + config["resdir"] + "/" + config["fastxdir"] + "/{id}.fasta.gz"
    output:
        hap1 = config["root"] + "/" + config["resdir"] + "/{id}/{run}/{stepdir}/" + config["asm_raw"] + "/" + config["asm"] + "/{id}.hic.hap1.p_ctg.gfa",
        hap2 = config["root"] + "/" + config["resdir"] + "/{id}/{run}/{stepdir}/" + config["asm_raw"] + "/" + config["asm"] + "/{id}.hic.hap2.p_ctg.gfa"
    params:
        prefix= config["root"] + "/" + config["resdir"] + "/{id}/{run}/{stepdir}/" + config["asm_raw"] + "/" + config["asm"] + "/{id}"
    threads: 20
    resources:
        mem_mb=250000
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/hifiasm0.16.1"
    shell:
        "hifiasm -l3 -o {params.prefix} -t {threads} --h1 {input.r1} --h2 {input.r2} {input.hifi}"