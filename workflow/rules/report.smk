### create report at the end of the workflow
# path variables
ASM_QC = "{resdir}/{id}/{run}/" + config["assembdir"] + "/" + config["asm_raw"] + "/" + config["asm_qc"]
P_ASM_QC = "{resdir}/{id}/{run}/" + config["assembdir"] + "/" + config["asm_purged"] + "/" + config["asm_qc"]
rule report:
    input:
        # reads QC
        genomescope = "{resdir}/{id}/{run}/" + config["qcdir"] + "/" + config["kmer"] + "/genomescope/linear_plot.png",
        gt_reads = "{resdir}/{id}/{run}/" + config["qcdir"] + "/" + config["gentools"] + "/{id}.RawStat.txt",
        # hifiasm assembly QC
        gt_asm_1 = ASM_QC + "/assembly_stats/{id}_hap1.AStats.txt",
        gt_asm_2 = ASM_QC + "/assembly_stats/{id}_hap2.AStats.txt",
        busco_1 = ASM_QC + "/busco/{id}_hap1/short_summary.specific.eudicots_odb10.{id}_hap1.txt",
        busco_2 = ASM_QC + "/busco/{id}_hap2/short_summary.specific.eudicots_odb10.{id}_hap2.txt",
        kplot_1 = ASM_QC + "/katplot/hap1/{id}_hap1.katplot.png",
        kplot_2 = ASM_QC + "/katplot/hap2/{id}_hap2.katplot.png",
        tel_1 = ASM_QC + "/telomeres/{id}_hap1_telomeres.txt",
        tel_2 = ASM_QC + "/telomeres/{id}_hap2_telomeres.txt",
        merq_comp = ASM_QC + "/merqury/merqury.completeness.stats",
        merq_err = ASM_QC + "/merqury/merqury.qv",
        # after purge_dups assembly QC
        P_gt_asm_1 = P_ASM_QC + "/assembly_stats/{id}_purged_hap1.AStats.txt",
        P_gt_asm_2 = P_ASM_QC + "/assembly_stats/{id}_purged_hap2.AStats.txt",
        P_busco_1 = P_ASM_QC + "/busco/{id}_purged_hap1/short_summary.specific.eudicots_odb10.{id}_purged_hap1.txt",
        P_busco_2 = P_ASM_QC + "/busco/{id}_purged_hap2/short_summary.specific.eudicots_odb10.{id}_purged_hap2.txt",
        P_kplot_1 = P_ASM_QC + "/katplot/hap1/{id}_purged_hap1.katplot.png",
        P_kplot_2 = P_ASM_QC + "/katplot/hap2/{id}_purged_hap2.katplot.png",
        P_tel_1 = P_ASM_QC + "/telomeres/{id}_hap1_purged_telomeres.txt",
        P_tel_2 = P_ASM_QC + "/telomeres/{id}_hap2_purged_telomeres.txt",
        P_merq_comp = P_ASM_QC + "/merqury/purge_merqury.completeness.stats",
        P_merq_err = P_ASM_QC + "/merqury/purge_merqury.qv",
    output:
        "{resdir}/{id}/{run}/report.html"
    params:
        id="{id}",
        mode=config["mode"]
    container:
        "docker://reslp/rmarkdown:4.0.3"
    script:
        "../scripts/report.Rmd"

rule rename_report:
    input:
        rules.report.output
    output:
        "{resdir}/{id}/{run}/report_{id}_{run}.html"
    shell:
        "mv {input} {output}"