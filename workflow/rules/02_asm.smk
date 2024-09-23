
### haplotypes assembly
# REGULAR MODE
rule hifiasm:
    input:
        get_fasta
    output:
        hap1 = abs_root_path + "/" + config["resdir"] + "/{runid}/02_genome_assembly/01_raw_assembly/00_assembly/{id}.bp.hap1.p_ctg.gfa",
        hap2 = abs_root_path + "/" + config["resdir"] + "/{runid}/02_genome_assembly/01_raw_assembly/00_assembly/{id}.bp.hap2.p_ctg.gfa"
    params:
        prefix = abs_root_path + "/" + config["resdir"] + "/{runid}/02_genome_assembly/01_raw_assembly/00_assembly/{id}"
    benchmark:
        abs_root_path + "/" + config["resdir"] + "/{runid}/benchmark/{id}_hifiasm_benchmark.txt"
    threads: 20
    resources:
        mem_mb=250000
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/hifiasm:0.19.6"
    shell:
        "hifiasm -l3 -o {params.prefix} -t {threads} {input}"

# HI-C
rule hifiasm_hic:
    input:
        # Hi-C paired-end reads
        r1 = get_r1,
        r2 = get_r2,
        # hifi reads
        hifi = get_fasta
    output:
        hap1 = abs_root_path + "/" + config["resdir"] + "/{runid}/02_genome_assembly/01_raw_assembly/00_assembly/{id}.hic.hap1.p_ctg.gfa",
        hap2 = abs_root_path + "/" + config["resdir"] + "/{runid}/02_genome_assembly/01_raw_assembly/00_assembly/{id}.hic.hap2.p_ctg.gfa"
    params:
        prefix= abs_root_path + "/" + config["resdir"] + "/{runid}/02_genome_assembly/01_raw_assembly/00_assembly/{id}"
    benchmark:
        abs_root_path + "/" + config["resdir"] + "/{runid}/benchmark/{id}_hifiasm_hic_benchmark.txt"
    threads: 20
    resources:
        mem_mb=250000
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/hifiasm:0.19.6"
    shell:
        "hifiasm -l3 -o {params.prefix} -t {threads} --h1 {input.r1} --h2 {input.r2} {input.hifi}"

# TRIO BINNING
rule yak:
    input:
        p1 = get_p1,
        p2 = get_p2
    output:
        p1 = abs_root_path + "/" + config["resdir"] + "/{runid}/02_genome_assembly/01_raw_assembly/00_assembly/yak/{id}_parent1.yak",
        p2 = abs_root_path + "/" + config["resdir"] + "/{runid}/02_genome_assembly/01_raw_assembly/00_assembly/yak/{id}_parent2.yak"
    benchmark:
        abs_root_path + "/" + config["resdir"] + "/{runid}/benchmark/{id}_yak_benchmark.txt"
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/yak:0.1"
    shell:
        "yak count -k31 -b37 -t16 -o {output.p1} {input.p1} && "
        "yak count -k31 -b37 -t16 -o {output.p2} {input.p2}"

### trio binning assembly
rule hifiasm_trio:
    input:
        p1 = rules.yak.output.p1,
        p2 = rules.yak.output.p2,
        child = get_fasta
    output:
        hap1 = abs_root_path + "/" + config["resdir"] + "/{runid}/02_genome_assembly/01_raw_assembly/00_assembly/{id}.dip.hap1.p_ctg.gfa",
        hap2 = abs_root_path + "/" + config["resdir"] + "/{runid}/02_genome_assembly/01_raw_assembly/00_assembly/{id}.dip.hap2.p_ctg.gfa"
    params:
        prefix = abs_root_path + "/" + config["resdir"] + "/{runid}/02_genome_assembly/01_raw_assembly/00_assembly/{id}"
    benchmark:
        abs_root_path + "/" + config["resdir"] + "/{runid}/benchmark/{id}_hifiasm_trio_benchmark.txt"
    threads: 20
    resources:
        mem_mb=250000
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/hifiasm:0.19.6"
    shell:
        "hifiasm -o {params.prefix} -t {threads} -1 {input.p1} -2 {input.p2} {input.child}"

### hifiasm haplotypes .gfa to .fa.gz
# variable for awk command
TO_FA_CMD = r"""/^S/{print ">"$2;print $3}"""

rule hap_gfa_to_fasta:
    input:
        hap1 = get_mode_hap1,
        hap2 = get_mode_hap2
    output:
        hap1_fa =  abs_root_path + "/" + config["resdir"] + "/{runid}/02_genome_assembly/01_raw_assembly/00_assembly/{id}_hap1.fa.gz",
        hap2_fa =  abs_root_path + "/" + config["resdir"] + "/{runid}/02_genome_assembly/01_raw_assembly/00_assembly/{id}_hap2.fa.gz"
    params:
        pigz_p = config["pigz_threads"]
    threads: config["pigz_threads"]
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/pigz"
    shell:
        """awk {TO_FA_CMD:q} {input.hap1} | pigz -p {params.pigz_p} > {output.hap1_fa} &&"""
        """awk {TO_FA_CMD:q} {input.hap2} | pigz -p {params.pigz_p} > {output.hap2_fa}"""