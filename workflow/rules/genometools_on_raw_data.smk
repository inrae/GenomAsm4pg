### read stats

rule genometools_on_raw_data:
    input:
        config["root"] + "/" + config["resdir"] + "/" + config["fastxdir"] + "/{id}.fasta.gz"
    output:
        "{resdir}/{id}/{run}/{stepdir}/{tooldir}/{id}.RawStat.txt"
    priority: 1
    threads: 4
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/genometools1.5.9"
    shell:
        "gt seqstat {input} > {output}"