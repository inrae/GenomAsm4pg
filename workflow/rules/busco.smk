### BUSCO stats on assembly

rule busco:
    input:
        rules.unzip_hap_fasta.output
    output:
        directory("{resdir}/{id}/{run}/{stepdir}/{asmdir}/{subdir}/busco/{id}_hap{n}"),
        "{resdir}/{id}/{run}/{stepdir}/{asmdir}/{subdir}/busco/{id}_hap{n}/short_summary.specific.eudicots_odb10.{id}_hap{n}.txt",
    params:
        prefix="{resdir}/{id}/{run}/{stepdir}/{asmdir}/{subdir}/busco",
        lineage=config["busco"]["lineage"],
        sample="{id}_hap{n}"
    threads: 20
    resources:
        mem_mb=100000
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/busco5.3.1"
    shell:
        "busco -f -i {input[0]} -l {params.lineage} --out_path {params.prefix} -o {params.sample} -m genome -c {threads}"