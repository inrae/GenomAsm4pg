### create report at the end of the workflow
# path variables
ASM_QC = "{resdir}/{id}/{run}/" + config["assembdir"] + "/" + config["asm_raw"] + "/" + config["asm_qc"]
P_ASM_QC = "{resdir}/{id}/{run}/" + config["assembdir"] + "/" + config["asm_purged"] + "/" + config["asm_qc"]

# functions to get parents
def get_p1(wildcards):
    id = wildcards.id
    p1 = config[f'{id}']["p1"]
    return p1

def get_p2(wildcards):
    id = wildcards.id
    p2 = config[f'{id}']["p2"]
    return p2

rule report:
    input:
        ### collect files to include in report
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
        merq_comp = ASM_QC + "/merqury/merqury_trio.completeness.stats",
        merq_err = ASM_QC + "/merqury/merqury_trio.qv",
        merq_blob = ASM_QC + "/merqury/merqury_trio.hapmers.blob.png",
        merq_block_1 = ASM_QC + "/merqury/merqury_trio.{id}_hap1.block.N.png",
        merq_block_2 = ASM_QC + "/merqury/merqury_trio.{id}_hap2.block.N.png",
        merq_block_stats_1 = ASM_QC + "/merqury/merqury_trio.{id}_hap1.100_20000.phased_block.stats",
        merq_block_stats_2 = ASM_QC + "/merqury/merqury_trio.{id}_hap2.100_20000.phased_block.stats",
        # after purge_dups assembly QC
        P_gt_asm_1 = P_ASM_QC + "/assembly_stats/{id}_purged_hap1.AStats.txt",
        P_gt_asm_2 = P_ASM_QC + "/assembly_stats/{id}_purged_hap2.AStats.txt",
        P_busco_1 = P_ASM_QC + "/busco/{id}_purged_hap1/short_summary.specific.eudicots_odb10.{id}_purged_hap1.txt",
        P_busco_2 = P_ASM_QC + "/busco/{id}_purged_hap2/short_summary.specific.eudicots_odb10.{id}_purged_hap2.txt",
        P_kplot_1 = P_ASM_QC + "/katplot/hap1/{id}_purged_hap1.katplot.png",
        P_kplot_2 = P_ASM_QC + "/katplot/hap2/{id}_purged_hap2.katplot.png",
        P_tel_1 = P_ASM_QC + "/telomeres/{id}_hap1_purged_telomeres.txt",
        P_tel_2 = P_ASM_QC + "/telomeres/{id}_hap2_purged_telomeres.txt",
        P_merq_comp = P_ASM_QC + "/merqury/purge_merqury_trio.completeness.stats",
        P_merq_err = P_ASM_QC + "/merqury/purge_merqury_trio.qv",
        P_merq_blob = P_ASM_QC + "/merqury/purge_merqury_trio.hapmers.blob.png",
        P_merq_block_1 = P_ASM_QC + "/merqury/purge_merqury_trio.{id}_hap1.purged.block.N.png",
        P_merq_block_2 = P_ASM_QC + "/merqury/purge_merqury_trio.{id}_hap2.purged.block.N.png",
        P_merq_block_stats_1 = P_ASM_QC + "/merqury/purge_merqury_trio.{id}_hap1.purged.100_20000.phased_block.stats",
        P_merq_block_stats_2 = P_ASM_QC + "/merqury/purge_merqury_trio.{id}_hap2.purged.100_20000.phased_block.stats",
    output:
        "{resdir}/{id}/{run}/report.html"
    params:
        id = "{id}", # get filename
        mode = config["mode"], # get assembly mode
        p1 = get_p1,
        p2 = get_p2
    container:
        "docker://reslp/rmarkdown:4.0.3"
    script:
        "../scripts/report_trio.Rmd"


rule rename_report:
    input:
        rules.report.output
    output:
        "{resdir}/{id}/{run}/report_{id}_{run}.html"
    shell:
        "mv {input} {output}"