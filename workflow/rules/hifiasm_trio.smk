### get .yak from both parents
def get_p1(wildcards):
    id = wildcards.id
    p1 = config[f'{id}']["p1"]
    return p1

def get_p2(wildcards):
    id = wildcards.id
    p2 = config[f'{id}']["p2"]
    return p2

rule yak:
    input:
        p1 = get_p1,
        p2 = get_p2
    output:
        p1 = config["root"] + "/" + config["resdir"] + "/{id}/{run}/{stepdir}/" + config["asm_raw"] + "/" + config["asm"] + "/yak/{id}_parent1.yak",
        p2 = config["root"] + "/" + config["resdir"] + "/{id}/{run}/{stepdir}/" + config["asm_raw"] + "/" + config["asm"] + "/yak/{id}_parent2.yak"
    container:
        "docker://dmolik/hifiasm:latest"
    shell:
        "yak count -k31 -b37 -t16 -o {output.p1} {input.p1} && "
        "yak count -k31 -b37 -t16 -o {output.p2} {input.p2}"

### trio binning assembly
rule hifiasm_trio:
    input:
        p1 = rules.yak.output.p1,
        p2 = rules.yak.output.p2,
        child = config["root"] + "/" + config["resdir"] + "/" + config["fastxdir"] + "/{id}.fasta.gz"
    output:
        hap1 = config["root"] + "/" + config["resdir"] + "/{id}/{run}/{stepdir}/" + config["asm_raw"] + "/" + config["asm"] + "/{id}.dip.hap1.p_ctg.gfa",
        hap2 = config["root"] + "/" + config["resdir"] + "/{id}/{run}/{stepdir}/" + config["asm_raw"] + "/" + config["asm"] + "/{id}.dip.hap2.p_ctg.gfa"
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
        "hifiasm -o {params.prefix} -t {threads} -1 {input.p1} -2 {input.p2} {input.child}"