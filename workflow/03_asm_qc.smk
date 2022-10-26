# input haplotypes
HAP_FA_GZ = config["root"] + "/" + config["resdir"] + "/{runid}/02_genome_assembly/01_raw_assembly/00_assembly/{id}_hap{n}.fa.gz"

# unzip fasta
rule unzip_hap_fasta:
    input:
        HAP_FA_GZ
    output:
        temp("{resdir}/{id}/{run}/{stepdir}/{asmdir}/" + config["asm"] + "/{id}_hap{n}.fa")
    shell:
        "unpigz -k -p 1 {input}"

### assembly stats with genometools
use rule genometools_on_raw_data as genometools_on_assembly with:
    input:
        HAP_FA_GZ
    output:
        "{resdir}/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/assembly_stats/{id}_hap{n}.AStats.txt"

### BUSCO stats on assembly
rule busco:
    input:
        rules.unzip_hap_fasta.output
    output:
        directory("{resdir}/02_genome_assembly/01_raw_assembly/01_assembly_QC/busco/{id}_hap{n}"),
        "{resdir}/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/busco/{id}_hap{n}/short_summary.specific.eudicots_odb10.{id}_hap{n}.txt",
    params:
        prefix="{resdir}/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/busco",
        lineage=get_busco_lin, # get lineage from config
        sample="{id}_hap{n}"
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
        hap = "{resdir}/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/{id}_hap{n}.fa.gz",
        jellyfish = "{resdir}/{runid}/01_raw_data_QC/04_kmer/{id}.jf"
    output:
        "{resdir}/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/katplot/hap{n}/{id}_hap{n}.katplot.png"
    params:
        prefix="{id}_hap{n}",
        path="{resdir}/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/katplot/hap{n}/{id}_hap{n}"
    threads: 4
    container: 
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/kat2.4.1"
    shell:
        "kat comp -o {params.path} -t {threads} -m 21 --output_type png -v {input.jellyfish} {input.hap} && "
        "kat plot spectra-cn -x 200 -o {params.path}.katplot.png {params.path}-main.mx"

# telomeres
rule find_telomeres:
    input:
        rules.unzip_hap_fasta.output
    output:
        "{resdir}/{runid}/02_genome_assembly/01_raw_assembly/01_assembly_QC/telomeres/{id}_hap{n}_telomeres.txt"
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/biopython1.75"
    shell:
        "python3 workflow/scripts/FindTelomeres.py {input} > {output}"