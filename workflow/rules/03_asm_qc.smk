# input haplotypes
HAP_FA_GZ = abs_root_path + "/" + config["resdir"] + "/{runid}/02_genome_assembly/01_raw_assembly/00_assembly/{id}_hap{n}.fa.gz"

# unzip fasta
rule unzip_hap_fasta:
    input:
        HAP_FA_GZ
    output:
        res_path + "/{runid}/02_genome_assembly/01_raw_assembly/00_assembly/{id}_hap{n}.fa"
    shell:
        "unpigz -k -p 1 {input}"

### assembly stats with genometools
use rule genometools_on_raw_data as genometools_on_assembly with:
    input:
        HAP_FA_GZ
    output:
        res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/assembly_stats/{id}_hap{n}.AStats.txt"

### BUSCO stats on assembly
rule busco:
    input:
        rules.unzip_hap_fasta.output
    output:
        res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/busco/{id}_hap{n}/short_summary.specific.{lin}.{id}_hap{n}.txt"
    params:
        prefix=res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/busco",
        lineage=get_busco_lin, # get lineage from config
        sample="{id}_hap{n}"
    benchmark:
        res_path + "/{runid}/benchmark/{id}_hap{n}_{lin}_busco.txt"
    threads: 20
    resources:
        mem_mb=100000
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/busco5.3.1"
    shell:
        "busco -f -i {input[0]} -l {params.lineage} --out_path {params.prefix} -o {params.sample} -m genome -c {threads}"

### assembly stats
# jellyfish .jf output file directory

rule kat:
    input:
        hap = res_path + "/{runid}/02_genome_assembly/01_raw_assembly/00_assembly/{id}_hap{n}.fa.gz",
        jellyfish = res_path + "/{runid}/01_raw_data_QC/04_kmer/{id}.jf"
    output:
        res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/katplot/hap{n}/{id}_hap{n}.katplot.png"
    params:
        prefix="{id}_hap{n}",
        path=res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/katplot/hap{n}/{id}_hap{n}",
        km_size = config["km_size"]
    threads: 4
    container: 
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/kat2.4.1"
    shell:
        "kat comp -o {params.path} -t {threads} -m {params.km_size} --output_type png -v {input.jellyfish} {input.hap} && "
        "kat plot spectra-cn -x 200 -o {params.path}.katplot.png {params.path}-main.mx"

# telomeres
rule find_telomeres:
    input:
        rules.unzip_hap_fasta.output
    output:
        res_path + "/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/telomeres/{id}_hap{n}_telomeres.txt"
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/biopython1.75"
    shell:
        "python3 workflow/scripts/FindTelomeres.py {input} > {output}"