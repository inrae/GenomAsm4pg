### kmer stats : jellyfish .histo used by genomescope
### assembly stats : jellyfish .jf used by KAT

rule jellyfish:
    input:
        config["root"] + "/" + config["resdir"] + "/" + config["fastxdir"] + "/{id}.fasta.gz"
    output:
        jf = "{resdir}/{id}/{run}/{stepdir}/{tooldir}/{id}.jf",
        histo = "{resdir}/{id}/{run}/{stepdir}/{tooldir}/{id}.histo"
    priority: 1
    threads: 4
    resources:
        mem_mb=40000
    envmodules:
        "jellyfish/2.3.0"
    container:
        "docker://quay.io/biocontainers/kmer-jellyfish:2.3.0--h9f5acd7_3"
    shell:
        "jellyfish count -m 21 -s 100M -t 10 -o {output[0]} -C <(zcat {input}) && "
        "jellyfish histo -h 1000000 -t 10 {output[0]} > {output[1]}"