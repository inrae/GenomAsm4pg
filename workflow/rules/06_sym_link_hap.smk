rule link_purged_asm:
    input:
        hap1 = res_path + "/{runid}/02_genome_assembly/02_after_purge_dups_assembly/00_assembly/{id}_hap1/{id}_hap1.purged.fa",
        hap2 = res_path + "/{runid}/02_genome_assembly/02_after_purge_dups_assembly/00_assembly/{id}_hap2/{id}_hap2.purged.fa"
    output:
        hap1 = res_path + "/{runid}/{id}_hap1.fa",
        hap2 = res_path + "/{runid}/{id}_hap2.fa"
    shell:
        "ln -s {input.hap1} {output.hap1} && "
        "ln -s {input.hap2} {output.hap2}"