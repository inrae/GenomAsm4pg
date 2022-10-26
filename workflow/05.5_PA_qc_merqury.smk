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

######### MERQURY TRIO
rule cp_purge_trio:
    input:
        meryl_db = rules.meryl.output,
        p1 = rules.merqury_trio.output.p1_hapmer,
        p2 = rules.merqury_trio.output.p2_hapmer
    output:
        meryl_db = temp(directory("{resdir}/{runid}/02_genome_assembly/02_after_purge_dups_assembly/01_assembly_QC/merqury/{id}_reads-db_k21.meryl")),
        p1 = temp(directory("{resdir}/{runid}/02_genome_assembly/02_after_purge_dups_assembly/01_assembly_QC/merqury/{id}_P1_reads-db_k21.hapmer.meryl")),
        p2 = temp(directory("{resdir}/{runid}/02_genome_assembly/02_after_purge_dups_assembly/01_assembly_QC/merqury/{id}_P2_reads-db_k21.hapmer.meryl"))
    params:
        path = "{resdir}/{runid}/02_genome_assembly/02_after_purge_dups_assembly/01_assembly_QC/merqury",
    shell:
        "cp -r {input.meryl_db} {params.path} && "
        "ln -s {input.p1} {output.p1} && "
        "ln -s {input.p2} {output.p2}"

rule cp_hap_trio:
    input:
        hap1 = "{resdir}/{runid}/02_genome_assembly/02_after_purge_dups_assembly/00_assembly/{id}_hap1/{id}_hap1.purged.fa",
        hap2 = "{resdir}/{runid}/02_genome_assembly/02_after_purge_dups_assembly/00_assembly/{id}_hap2/{id}_hap2.purged.fa",
    output:
        hap1 = temp("{resdir}/{runid}/02_genome_assembly/02_after_purge_dups_assembly/01_assembly_QC/merqury/{id}_hap1.purged.fasta"),
        hap2 = temp("{resdir}/{runid}/02_genome_assembly/02_after_purge_dups_assembly/01_assembly_QC/merqury/{id}_hap2.purged.fasta"),
    params:
        path = "{resdir}/{runid}/02_genome_assembly/02_after_purge_dups_assembly/01_assembly_QC/merqury"
    shell:
        "cp {input.hap1} {output.hap1} && "
        "cp {input.hap2} {output.hap2}"

rule purge_merqury_trio:
    input:
        p1 = rules.cp_purge_trio.output.p1,
        p2 = rules.cp_purge_trio.output.p2,
        read_db = rules.cp_purge_trio.output.meryl_db,
        hap1 = rules.cp_hap_trio.output.hap1,
        hap2 = rules.cp_hap_trio.output.hap2
    output:
        "{resdir}/{runid}/02_genome_assembly/02_after_purge_dups_assembly/01_assembly_QC/merqury/{id}_purge_merqury_trio.{id}_hap1.purged.100_20000.phased_block.stats",
        "{resdir}/{runid}/02_genome_assembly/02_after_purge_dups_assembly/01_assembly_QC/merqury/{id}_purge_merqury_trio.{id}_hap2.purged.100_20000.phased_block.stats",
        "{resdir}/{runid}/02_genome_assembly/02_after_purge_dups_assembly/01_assembly_QC/merqury/{id}_purge_merqury_trio.{id}_hap1.purged.block.N.png",
        "{resdir}/{runid}/02_genome_assembly/02_after_purge_dups_assembly/01_assembly_QC/merqury/{id}_purge_merqury_trio.{id}_hap2.purged.block.N.png",
        "{resdir}/{runid}/02_genome_assembly/02_after_purge_dups_assembly/01_assembly_QC/merqury/{id}_purge_merqury_trio.qv",
        "{resdir}/{runid}/02_genome_assembly/02_after_purge_dups_assembly/01_assembly_QC/merqury/{id}_purge_merqury_trio.completeness.stats",
        "{resdir}/{runid}/02_genome_assembly/02_after_purge_dups_assembly/01_assembly_QC/merqury/{id}_purge_merqury_trio.hapmers.blob.png"
    params:
        path = "{resdir}/{runid}/02_genome_assembly/02_after_purge_dups_assembly/01_assembly_QC/merqury",
        prefix = "{id}_purge_merqury_trio"
    threads: 20
    resources:
        mem_mb=60000
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/merqury1.3"
    shell:
        "cd {params.path} && "
        "export MERQURY=/usr/local/share/merqury && "
        "merqury.sh {input.read_db} {input.p1} {input.p2} {input.hap1} {input.hap2} {params.prefix}"