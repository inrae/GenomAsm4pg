### read stats

rule genometools_on_raw_data:
    input:
        config["root"] + "/" + config["resdir"] + "/" + config["fastxdir"] + "/{id}.fasta.gz"
    output:
        "{resdir}/{id}/{run}/{stepdir}/{tooldir}/{id}.RawStat.txt"
    priority: 1
    threads: 4
    envmodules:
        "genometools/1.5.7"
    container:
        "docker://biocontainers/genometools:v1.5.9ds-4-deb_cv1"
    shell:
        "gt seqstat {input} > {output}"