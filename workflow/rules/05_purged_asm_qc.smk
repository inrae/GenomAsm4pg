### stats on purged haplotypes
# only the input, output and params have been modified, 
# commands are the same as the ones in corresponding rule (dir : workflow/rules)

# reuse busco rule from 03_asm_qc.smk
use rule busco as purge_busco with:
    input:
        rules.purge_dups.output.purge
    output:
        res_path + "/{runid}/02_genome_assembly/02_after_purge_dups_assembly/01_assembly_QC/busco/{id}_purged_hap{n}/short_summary.specific.{lin}.{id}_purged_hap{n}.txt",
    params:
        prefix=res_path + "/{runid}/02_genome_assembly/02_after_purge_dups_assembly/01_assembly_QC/busco",
        lineage=get_busco_lin, # get lineage from config
        sample="{id}_purged_hap{n}"
    benchmark:
        res_path + "/{runid}/benchmark/{id}_hap{n}_{lin}_busco_purged.txt"

# reuse genometools rule from 03_asm_qc.smk
use rule genometools_on_raw_data as purge_genometools with:
    input:
        rules.purge_dups.output.purge
    output:
        res_path + "/{runid}/02_genome_assembly/02_after_purge_dups_assembly/01_assembly_QC/assembly_stats/{id}_purged_hap{n}.AStats.txt"

# reuse kat rule from 03_asm_qc.smk
use rule kat as purge_kat with:
    input:
        hap = rules.purge_dups.output.purge,
        jellyfish = res_path + "/{runid}/01_raw_data_QC/04_kmer/{id}.jf"
    output:
        res_path + "/{runid}/02_genome_assembly/02_after_purge_dups_assembly/01_assembly_QC/katplot/hap{n}/{id}_purged_hap{n}.katplot.png"
    params:
        km_size = config["km_size"],
        prefix="{id}_hap{n}",
        path= res_path + "/{runid}/02_genome_assembly/02_after_purge_dups_assembly/01_assembly_QC/katplot/hap{n}/{id}_purged_hap{n}"

rule purge_find_telomeres:
    input:
        rules.purge_dups.output.purge
    output:
        res_path + "/{runid}/02_genome_assembly/02_after_purge_dups_assembly/01_assembly_QC/telomeres/{id}_hap{n}_purged_telomeres.txt"
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/biopython1.75"
    shell:
        "python3 workflow/scripts/FindTelomeres.py {input} > {output}"