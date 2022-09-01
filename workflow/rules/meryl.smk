### create reads db necessary for merqury
rule meryl:
    input:
        config["root"] + "/" + config["resdir"] + "/" + config["fastxdir"] + "/{id}.fasta.gz"
    output:
        directory("{resdir}/{id}/{run}/{stepdir}/" + config["asm_raw"] + "/" + config["asm_qc"] + "/merqury/{id}_reads-db_k21.meryl")
    threads: 20
    resources:
        mem_mb=60000
    container:
        "workflow/img/merqury.sif"
    shell:
        "meryl k=21 count {input} output {output}"