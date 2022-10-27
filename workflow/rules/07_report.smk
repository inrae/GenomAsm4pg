### create report at the end of the workflow
# path variables
res_path=config["root"] + "/" + config["resdir"]
RAW_QC = res_path + "/{runid}/01_raw_data_QC"
ASM_QC = res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC"
P_ASM_QC = res_path + "/{runid}/02_genome_assembly/02_after_purge_dups_assembly/01_assembly_QC"

rule report:
    input:
        # reads QC
        genomescope = RAW_QC + "/04_kmer/{id}_genomescope/linear_plot.png",
        gt_reads = RAW_QC + "/03_genometools/{id}.RawStat.txt",
        # hifiasm assembly QC
        gt_asm_1 = ASM_QC + "/assembly_stats/{id}_hap1.AStats.txt",
        gt_asm_2 = ASM_QC + "/assembly_stats/{id}_hap2.AStats.txt",
        busco_1 = ASM_QC + "/busco/{id}_hap1/short_summary.specific.eudicots_odb10.{id}_hap1.txt",
        busco_2 = ASM_QC + "/busco/{id}_hap2/short_summary.specific.eudicots_odb10.{id}_hap2.txt",
        kplot_1 = ASM_QC + "/katplot/hap1/{id}_hap1.katplot.png",
        kplot_2 = ASM_QC + "/katplot/hap2/{id}_hap2.katplot.png",
        tel_1 = ASM_QC + "/telomeres/{id}_hap1_telomeres.txt",
        tel_2 = ASM_QC + "/telomeres/{id}_hap2_telomeres.txt",
        merq_comp = rules.merqury.output.stat,
        merq_err = rules.merqury.output.qv,
        # after purge_dups assembly QC
        P_gt_asm_1 = P_ASM_QC + "/assembly_stats/{id}_purged_hap1.AStats.txt",
        P_gt_asm_2 = P_ASM_QC + "/assembly_stats/{id}_purged_hap2.AStats.txt",
        P_busco_1 = P_ASM_QC + "/busco/{id}_purged_hap1/short_summary.specific.eudicots_odb10.{id}_purged_hap1.txt",
        P_busco_2 = P_ASM_QC + "/busco/{id}_purged_hap2/short_summary.specific.eudicots_odb10.{id}_purged_hap2.txt",
        P_kplot_1 = P_ASM_QC + "/katplot/hap1/{id}_purged_hap1.katplot.png",
        P_kplot_2 = P_ASM_QC + "/katplot/hap2/{id}_purged_hap2.katplot.png",
        P_tel_1 = P_ASM_QC + "/telomeres/{id}_hap1_purged_telomeres.txt",
        P_tel_2 = P_ASM_QC + "/telomeres/{id}_hap2_purged_telomeres.txt",
        P_merq_comp = rules.purge_merqury.output.stat,
        P_merq_err = rules.purge_merqury.output.qv
    output:
        res_path + "/{runid}/{id}/report.html"
    params:
        id="{id}",
        mode=get_mode,
        run=get_run
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/rmarkdown4.0.3"
    script:
        "../scripts/report.Rmd"

rule rename_report:
    input:
        rules.report.output
    output:
        res_path + "/{runid}/report_{id}.html"
    shell:
        "mv {input} {output}"

rule report_trio:
    input:
        ### collect files to include in report
        # reads QC
        genomescope = RAW_QC + "/04_kmer/{id}_genomescope/linear_plot.png",
        gt_reads = RAW_QC + "/03_genometools/{id}.RawStat.txt",
        # hifiasm assembly QC
        gt_asm_1 = ASM_QC + "/assembly_stats/{id}_hap1.AStats.txt",
        gt_asm_2 = ASM_QC + "/assembly_stats/{id}_hap2.AStats.txt",
        busco_1 = ASM_QC + "/busco/{id}_hap1/short_summary.specific.eudicots_odb10.{id}_hap1.txt",
        busco_2 = ASM_QC + "/busco/{id}_hap2/short_summary.specific.eudicots_odb10.{id}_hap2.txt",
        kplot_1 = ASM_QC + "/katplot/hap1/{id}_hap1.katplot.png",
        kplot_2 = ASM_QC + "/katplot/hap2/{id}_hap2.katplot.png",
        tel_1 = ASM_QC + "/telomeres/{id}_hap1_telomeres.txt",
        tel_2 = ASM_QC + "/telomeres/{id}_hap2_telomeres.txt",
        merq_comp = ASM_QC + "/merqury/{id}_merqury_trio.completeness.stats",
        merq_err = ASM_QC + "/merqury/{id}_merqury_trio.qv",
        merq_blob = ASM_QC + "/merqury/{id}_merqury_trio.hapmers.blob.png",
        merq_block_1 = ASM_QC + "/merqury/{id}_merqury_trio.{id}_hap1.block.N.png",
        merq_block_2 = ASM_QC + "/merqury/{id}_merqury_trio.{id}_hap2.block.N.png",
        merq_block_stats_1 = ASM_QC + "/merqury/{id}_merqury_trio.{id}_hap1.100_20000.phased_block.stats",
        merq_block_stats_2 = ASM_QC + "/merqury/{id}_merqury_trio.{id}_hap2.100_20000.phased_block.stats",
        # after purge_dups assembly QC
        P_gt_asm_1 = P_ASM_QC + "/assembly_stats/{id}_purged_hap1.AStats.txt",
        P_gt_asm_2 = P_ASM_QC + "/assembly_stats/{id}_purged_hap2.AStats.txt",
        P_busco_1 = P_ASM_QC + "/busco/{id}_purged_hap1/short_summary.specific.eudicots_odb10.{id}_purged_hap1.txt",
        P_busco_2 = P_ASM_QC + "/busco/{id}_purged_hap2/short_summary.specific.eudicots_odb10.{id}_purged_hap2.txt",
        P_kplot_1 = P_ASM_QC + "/katplot/hap1/{id}_purged_hap1.katplot.png",
        P_kplot_2 = P_ASM_QC + "/katplot/hap2/{id}_purged_hap2.katplot.png",
        P_tel_1 = P_ASM_QC + "/telomeres/{id}_hap1_purged_telomeres.txt",
        P_tel_2 = P_ASM_QC + "/telomeres/{id}_hap2_purged_telomeres.txt",
        P_merq_comp = P_ASM_QC + "/merqury/{id}_purge_merqury_trio.completeness.stats",
        P_merq_err = P_ASM_QC + "/merqury/{id}_purge_merqury_trio.qv",
        P_merq_blob = P_ASM_QC + "/merqury/{id}_purge_merqury_trio.hapmers.blob.png",
        P_merq_block_1 = P_ASM_QC + "/merqury/{id}_purge_merqury_trio.{id}_hap1.purged.block.N.png",
        P_merq_block_2 = P_ASM_QC + "/merqury/{id}_purge_merqury_trio.{id}_hap2.purged.block.N.png",
        P_merq_block_stats_1 = P_ASM_QC + "/merqury/{id}_purge_merqury_trio.{id}_hap1.purged.100_20000.phased_block.stats",
        P_merq_block_stats_2 = P_ASM_QC + "/merqury/{id}_purge_merqury_trio.{id}_hap2.purged.100_20000.phased_block.stats",
    output:
        res_path + "/{runid}/report_trio_{id}.html"
    params:
        id = "{id}", # get filename
        mode = get_mode, # get assembly mode
        p1 = get_p1,
        p2 = get_p2,
        run = get_run
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/rmarkdown4.0.3"
    script:
        "../scripts/report_trio.Rmd"


# rule rename_report_trio:
#     input:
#         rules.report_trio.output
#     output:
#         res_path + "/{runid}/report_{id}.html"
#     shell:
#         "mv {input} {output}"