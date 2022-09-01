### QC

rule fastqc:
    input:
        config["root"] + "/" + config["resdir"] + "/" + config["fastxdir"] + "/{Fid}.fastq.gz"
    output:
        multiext("{resdir}/{Fid}/{run}/{stepdir}/{tooldir}/{Fid}_fastqc", ".html", ".zip")
    params:
        output_path="{resdir}/{Fid}/{run}/{stepdir}/{tooldir}/"
    priority: 1
    threads: 4
    envmodules:
        "FastQC/0.11.5"
    container:
        "docker://biocontainers/fastqc:v0.11.5_cv4"
    shell:
        "fastqc -o {params.output_path} {input}"