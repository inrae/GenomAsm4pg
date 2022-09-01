### QC on .bam files with LongQC

rule longqc:
    input:
        config["root"] + "/" + config["resdir"] + "/" + config["bamdir"] + "/{Bid}.bam"
    output:
        directory("{resdir}/{Bid}/{run}/{stepdir}/" + config["lqc"])
    priority: 1
    threads: 8
    resources:
        mem_mb=60000
    envmodules:
        "LongQC/1.2.0"
    container:
        "docker://grpiccoli/longqc:latest"
    shell:
        "longQC sampleqc -x pb-hifi -o {output} {input}"
        # "LongQC sampleqc -x pb-hifi -o {output} {input}"