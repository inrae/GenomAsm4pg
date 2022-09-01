### assembly stats
# jellyfish .jf output file directory

rule kat:
    input:
        hap = "{resdir}/{id}/{run}/" + config["assembdir"] + "/" + config["asm_raw"] + "/" + config["asm"] + "/{id}_hap{n}.fa.gz",
        jellyfish = "{resdir}/{id}/{run}/" + config["qcdir"] + "/" + config["kmer"] + "/{id}.jf"
    output:
        "{resdir}/{id}/{run}/{stepdir}/{asmdir}/{subdir}/katplot/hap{n}/{id}_hap{n}.katplot.png"
    params:
        prefix="{id}_hap{n}",
        path="{resdir}/{id}/{run}/{stepdir}/{asmdir}/{subdir}/katplot/hap{n}/{id}_hap{n}"
    threads: 4
    envmodules:
        "kat/2.4.1"
    container: 
        "docker://quay.io/biocontainers/kat:2.4.1--py35h355e19c_3"
    shell:
        "kat comp -o {params.path} -t {threads} -m 21 --output_type png -v {input.jellyfish} {input.hap} && "
        "kat plot spectra-cn -x 200 -o {params.path}.katplot.png {params.path}-main.mx"