### to purge haplotigs in hifiasm assembly
# input haplotypes
HAP_FA_GZ = config["root"] + "/" + config["resdir"] + "/{id}/{run}/" + config["assembdir"] + "/" + config["asm_raw"] + "/" + config["asm"] + "/{id}_hap{n}.fa.gz"

rule purge_dups_cutoffs:
    input:
        assembly = HAP_FA_GZ,
        reads = config["root"] + "/" + config["resdir"] + "/" + config["fastxdir"] + "/{id}.fasta.gz"
    output:
        paf = "{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm"] + "/hap{n}/{id}_hap{n}.paf.gz",
        calcuts = "{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm"] + "/hap{n}/calcuts.log",
        cutoffs = "{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm"] + "/hap{n}/cutoffs"
    params:
        dir="{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm"] + "/hap{n}"
    threads: 20
    resources:
        mem_mb=100000
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/purge_dups1.2.5"
    shell:
        # generate paf file
        "minimap2 -xasm20 {input.assembly} {input.reads} | gzip -c - > {output.paf} && "
        "pbcstat {params.dir}/*.paf.gz -O {params.dir} && "
        "calcuts {params.dir}/PB.stat > {output.cutoffs} 2>{output.calcuts}"

rule purge_dups:
    input:
        assembly = HAP_FA_GZ,
        cutoffs = rules.purge_dups_cutoffs.output.cutoffs
    output:
        purge = "{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm"] + "/hap{n}/{id}_hap{n}.purged.fa",
        split = "{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm"] + "/hap{n}/{id}_hap{n}.split",
        self_paf = "{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm"] + "/hap{n}/{id}_hap{n}.split.self.paf.gz",
        bed = "{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm"] + "/hap{n}/dups.bed",
        log = "{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm"] + "/hap{n}/purge_dups.log"
    params:
        dir="{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm"] + "/hap{n}"
    threads: 20
    resources:
        mem_mb=100000
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/purge_dups1.2.5"
    shell:
        # split assembly & self-self alignment
        "split_fa {input.assembly} > {output.split} && "
        "minimap2 -xasm5 -DP {output.split} {output.split} | gzip -c - > {output.split}.self.paf.gz && "
        # purge haplotigs & overlaps
        "purge_dups -2 -T cutoffs -c {params.dir}/PB.base.cov {output.self_paf} > {output.bed} 2> {output.log} && "
        # get purged primary and haplotig sequences from draft assembly
        "get_seqs -e {output.bed} {input.assembly} -p {params.dir}/{wildcards.id}_hap{wildcards.n}"

### make purge_dups cutoffs graph
rule cutoffs_eval:
    input:
        rules.purge_dups_cutoffs.output.cutoffs
    output:
        "{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm"] + "/hap{n}/cutoffs_graph_hap{n}.png"
    params:
        dir="{resdir}/{id}/{run}/{stepdir}/" + config["asm_purged"] + "/" + config["asm"] + "/hap{n}",
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/matplotlib0.11.5"
    shell:
        "python3 workflow/scripts/hist_plot.py -c {input} {params.dir}/PB.stat {output}"