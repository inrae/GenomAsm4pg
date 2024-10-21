
# Rule to run quast on all the assembled genomes
assemblies = find_all_assemblies()

rule QUAST:
    params:
        assemblies=assemblies,
        output_folder= res_path + "/global_quast_report/"
    output:
        res_path + "/global_quast_report/report.html"
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/staphb/quast:5.2.0"
    shell:
        """
        python /quast-5.2.0/quast-lg.py {params.assemblies} -o {params.output_folder} && 
        rm -rf {params.output_folder}/contigs_reports/
        """