### unzip haplotypes.fasta before busco stats
HAP_FA_GZ = config["root"] + "/" + config["resdir"] + "/{id}/{run}/" + config["assembdir"] + "/" + config["asm_raw"] + "/" + config["asm"] + "/{id}_hap{n}.fa.gz"

rule unzip_hap_fasta:
    input:
        HAP_FA_GZ
    output:
        temp("{resdir}/{id}/{run}/{stepdir}/{asmdir}/" + config["asm"] + "/{id}_hap{n}.fa")
    shell:
        "unpigz -k -p 1 {input}"