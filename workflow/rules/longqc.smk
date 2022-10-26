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
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/longqc1.2.0c"
    shell:
        "longQC sampleqc -x pb-hifi -o {output} {input}"