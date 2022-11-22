### QC on .bam files with LongQC
rule longqc:
    input:
        config["root"] + "/" + config["resdir"] + "/" + config["bamdir"] + "/{Bid}.bam"
    output:
        directory(res_path + "/{Bid}/{run}/01_raw_data_QC/02_longQC")
    benchmark:
        res_path + "/{Bid}/{run}/benchmark/longqc.txt"
    priority: 1
    threads: 8
    resources:
        mem_mb=60000
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/longqc1.2.0c"
    shell:
        "longQC sampleqc -x pb-hifi -o {output} {input}"

### QC on .fastq.gz files with FastQC
rule fastqc:
    input:
        config["root"] + "/" + config["resdir"] + "/" + config["fastxdir"] + "/{Fid}.fastq.gz"
    output:
        multiext(res_path + "/{Fid}/{run}/01_raw_data_QC/01_fastQC/{Fid}_fastqc", ".html", ".zip")
    params:
        output_path=res_path + "/{Fid}/{run}//01_raw_data_QC/01_fastQC/"
    benchmark:
        res_path + "/{Fid}/{run}/benchmark/fastqc.txt"
    priority: 1
    threads: 4
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/fastqc0.11.5"
    shell:
        "fastqc -o {params.output_path} {input}"

        ### read stats

rule genometools_on_raw_data:
    input:
        config["root"] + "/" + config["resdir"] + "/" + config["fastxdir"] + "/{id}.fasta.gz"
    output:
        res_path + "/{runid}/01_raw_data_QC/03_genometools/{id}.RawStat.txt"
    priority: 1
    threads: 4
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/genometools1.5.9"
    shell:
        "gt seqstat {input} > {output}"

### kmer stats
### kmer stats : jellyfish .histo used by genomescope
### assembly stats : jellyfish .jf used by KAT

rule jellyfish:
    input:
        config["root"] + "/" + config["resdir"] + "/" + config["fastxdir"] + "/{id}.fasta.gz"
    output:
        jf = res_path + "/{runid}/01_raw_data_QC/04_kmer/{id}.jf",
        histo = res_path + "/{runid}/01_raw_data_QC/04_kmer/{id}.histo"
    priority: 1
    threads: 4
    resources:
        mem_mb=40000
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/jellyfish2.3.0"
    shell:
        "jellyfish count -m 21 -s 100M -t 10 -o {output[0]} -C <(zcat {input}) && "
        "jellyfish histo -h 1000000 -t 10 {output[0]} > {output[1]}"

rule genomescope:
    input:
        rules.jellyfish.output.histo
    output:
        d = directory(res_path + "/{runid}/01_raw_data_QC/04_kmer/{id}_genomescope"),
        png = res_path + "/{runid}/01_raw_data_QC/04_kmer/{id}_genomescope/linear_plot.png"
    params:
        ploidy = get_ploidy
    priority: 1
    threads: 4
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/genomescope2.0"
    shell:
        "genomescope.R -k 21 -i {input} -o {output.d} -p {params.ploidy}"