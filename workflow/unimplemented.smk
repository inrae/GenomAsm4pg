
rule meryl_trio:
    input:
        p1 = get_p1,
        p2 = get_p2
    output:
        p1 = directory(res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury/{id}_P1_reads-db_k21.meryl"),
        p2 = directory(res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury/{id}_P2_reads-db_k21.meryl")
    benchmark:
        res_path + "/{runid}/benchmark/{id}_meryl_trio.txt"
    threads: 10
    resources:
        mem_mb=60000
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/merqury1.3"
    shell:
        "meryl k=21 count {input.p1} output {output.p1} && "
        "meryl k=21 count {input.p2} output {output.p2}"

rule merqury_trio:
    input:
        p1 = rules.meryl_trio.output.p1,
        p2 = rules.meryl_trio.output.p2,
        read_db = rules.meryl.output,
        hap1 = rules.unzip.output.hap1,
        hap2 = rules.unzip.output.hap2
    output:
        res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury/{id}_merqury_trio.qv",
        res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury/{id}_merqury_trio.completeness.stats",
        res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury/{id}_merqury_trio.{id}_hap1.block.N.png",
        res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury/{id}_merqury_trio.{id}_hap2.block.N.png",
        res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury/{id}_merqury_trio.{id}_hap1.100_20000.phased_block.stats",
        res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury/{id}_merqury_trio.{id}_hap2.100_20000.phased_block.stats",
        res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury/{id}_merqury_trio.hapmers.blob.png",
        p1_hapmer = directory(res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury/{id}_P1_reads-db_k21.hapmer.meryl"),
        p2_hapmer = directory(res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury/{id}_P2_reads-db_k21.hapmer.meryl")
    params:
        path = res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/merqury",
        prefix = "{id}_merqury_trio"
    benchmark:
        res_path + "/{runid}/benchmark/{id}_merqury_trio.txt"
    threads: 20
    resources:
        mem_mb=60000
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/merqury1.3"
    shell:
        "cd {params.path} && "
        "export MERQURY=/usr/local/share/merqury && "
        "$MERQURY/trio/hapmers.sh {input.p1} {input.p2} {input.read_db} && "
        "merqury.sh {input.read_db} {output.p1_hapmer} {output.p2_hapmer} {input.hap1} {input.hap2} {params.prefix}"

rule no_purge_report_trio:
    input:
        # Reads QC
        genomescope=RAW_QC + "/04_kmer/{id}_genomescope/linear_plot.png",
        gt_reads=RAW_QC + "/03_genometools/{id}.RawStat.txt",
        # Hifiasm assembly QC
        gt_asm_1=ASM_QC + "/assembly_stats/{id}_hap1.AStats.txt",
        gt_asm_2=ASM_QC + "/assembly_stats/{id}_hap2.AStats.txt",
        busco_1=ASM_QC + "/busco/{id}_hap1/short_summary.specific.{lin}.{id}_hap1.txt",
        busco_2=ASM_QC + "/busco/{id}_hap2/short_summary.specific.{lin}.{id}_hap2.txt",
        kplot_1=ASM_QC + "/katplot/hap1/{id}_hap1.katplot.png",
        kplot_2=ASM_QC + "/katplot/hap2/{id}_hap2.katplot.png",
        tel_1=ASM_QC + "/telomeres/{id}_hap1_telomeres.txt",
        tel_2=ASM_QC + "/telomeres/{id}_hap2_telomeres.txt",
        merq_comp=ASM_QC + "/merqury/{id}_merqury_trio.completeness.stats",
        merq_err=ASM_QC + "/merqury/{id}_merqury_trio.qv",
        merq_blob=ASM_QC + "/merqury/{id}_merqury_trio.hapmers.blob.png",
        merq_block_1=ASM_QC + "/merqury/{id}_merqury_trio.{id}_hap1.block.N.png",
        merq_block_2=ASM_QC + "/merqury/{id}_merqury_trio.{id}_hap2.block.N.png",
        merq_block_stats_1=ASM_QC + "/merqury/{id}_merqury_trio.{id}_hap1.100_20000.phased_block.stats",
        merq_block_stats_2=ASM_QC + "/merqury/{id}_merqury_trio.{id}_hap2.100_20000.phased_block.stats"
    output:
        res_path + "/{runid}/{id}/{lin}/report_trio.html"
    params:
        id="{id}",  # get filename
        mode=get_mode,  # get assembly mode
        p1=get_p1,
        p2=get_p2,
        run=get_run,
        purge=get_purge,
        purge_force = get_purge_force
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/rmarkdown4.0.3"
    script:
        "../scripts/report_trio.Rmd"