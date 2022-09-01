### find telomeres in fasta files
rule find_telomeres:
    input:
        rules.unzip_hap_fasta.output
    output:
        "{resdir}/{id}/{run}/{stepdir}/{asmdir}/" + config["asm_qc"] + "/telomeres/{id}_hap{n}_telomeres.txt"
    container:
        "docker://quay.io/biocontainers/biopython:1.75"
    shell:
        "python3 workflow/scripts/FindTelomeres.py {input} > {output}"

rule purge_find_telomeres:
    input:
        rules.purge_dups.output.purge
    output:
        "{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm_qc"] + "/telomeres/{id}_hap{n}_purged_telomeres.txt"
    container:
        "docker://quay.io/biocontainers/biopython:1.75"
    shell:
        "python3 workflow/scripts/FindTelomeres.py {input} > {output}"