rule link_final_asm:
    input:
        hap1 = "{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm"] + "/hap1/{id}_hap1.purged.fa",
        hap2 = "{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm"] + "/hap2/{id}_hap2.purged.fa"
    output:
        hap1 = "{resdir}/{id}/{run}/{stepdir}/{id}_hap1.fa",
        hap2 = "{resdir}/{id}/{run}/{stepdir}/{id}_hap2.fa"
    shell:
        "ln -s {input.hap1} {output.hap1} && "
        "ln -s {input.hap2} {output.hap2}"