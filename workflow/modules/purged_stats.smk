### stats on purged haplotypes
# only the input, output and params have been modified, 
# commands are the same as the ones in corresponding rule (dir : workflow/rules)

# same command as busco.smk
use rule busco as purge_busco with:
    input:
        rules.purge_dups.output.purge
    output:
        directory("{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm_qc"] + "/busco/{id}_purged_hap{n}"),
        "{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm_qc"] + "/busco/{id}_purged_hap{n}/short_summary.specific.eudicots_odb10.{id}_purged_hap{n}.txt",
    params:
        prefix="{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm_qc"] + "/busco",
        lineage=config["busco"]["lineage"],
        sample="{id}_purged_hap{n}"

# same command as genometools_assembly.smk
use rule genometools_on_raw_data as purge_genometools with:
    input:
        rules.purge_dups.output.purge
    output:
        "{resdir}/{id}/{run}/{stepdir}/{asmdir}/{subdir}/assembly_stats/{id}_purged_hap{n}.AStats.txt"

# same command as kat.smk
use rule kat as purge_kat with:
    input:
        hap = rules.purge_dups.output.purge,
        jellyfish = "{resdir}/{id}/{run}/" + config["qcdir"] + "/" + config["kmer"] + "/{id}.jf"
    output:
        "{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm_qc"] + "/katplot/hap{n}/{id}_purged_hap{n}.katplot.png"
    params:
        prefix="{id}_hap{n}",
        path= "{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm_qc"] + "/katplot//hap{n}/{id}_purged_hap{n}"