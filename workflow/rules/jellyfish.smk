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
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/jellyfish2.3.0"
    shell:
        "jellyfish count -m 21 -s 100M -t 10 -o {output[0]} -C <(zcat {input}) && "
        "jellyfish histo -h 1000000 -t 10 {output[0]} > {output[1]}"