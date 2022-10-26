# similar to 03.5
## copy reads db created with meryl
rule purge_cp_meryl:
    input:
        rules.meryl.output
    output:
        temp(directory("{resdir}/{runid}/02_genome_assembly/02_after_purge_dups_assembly/01_assembly_QC/merqury/{id}_reads-db_k21.meryl"))
    params:
        path="{resdir}/{runid}/02_genome_assembly/02_after_purge_dups_assembly/01_assembly_QC/merqury"
    shell:
        "cp -r {input} {params.path}"

# reuse rules from 03.5
use rule cp_hap as purge_cp with:
    input:
        hap1="{resdir}/{runid}/02_genome_assembly/02_after_purge_dups_assembly/00_assembly/{id}_hap1/{id}_hap1.purged.fa",
        hap2="{resdir}/{runid}/02_genome_assembly/02_after_purge_dups_assembly/00_assembly/{id}_hap2/{id}_hap2.purged.fa"
    output:
        hap1=temp("{resdir}/{runid}/02_genome_assembly/02_after_purge_dups_assembly/01_assembly_QC/merqury/{id}_hap1.purged.fa"),
        hap2=temp("{resdir}/{runid}/02_genome_assembly/02_after_purge_dups_assembly/01_assembly_QC/merqury/{id}_hap2.purged.fa")
    params:
        path="{resdir}/{runid}/02_genome_assembly/02_after_purge_dups_assembly/01_assembly_QC/merqury"

use rule merqury as purge_merqury with:
    input:
        read_db = rules.purge_cp_meryl.output,
        hap1 = rules.purge_cp.output.hap1,
        hap2 = rules.purge_cp.output.hap2
    output:
        qv = "{resdir}/{runid}/02_genome_assembly/02_after_purge_dups_assembly/01_assembly_QC/merqury/{id}_purge_merqury.qv",
        stat = "{resdir}/{runid}/02_genome_assembly/02_after_purge_dups_assembly/01_assembly_QC/merqury/{id}_purge_merqury.completeness.stats"
    params:
        prefix = "{id}_purge_merqury",
        path = "{resdir}/{runid}/02_genome_assembly/02_after_purge_dups_assembly/01_assembly_QC/merqury"