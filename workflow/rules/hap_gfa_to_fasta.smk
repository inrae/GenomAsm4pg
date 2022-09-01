### hifiasm haplotypes .gfa to .fa.gz
# variable for awk command
TO_FA_CMD = r"""/^S/{print ">"$2;print $3}"""

rule hap_gfa_to_fasta:
    input:
        hap1 = lambda wildcards: hifiasm_mode_hap1(config["mode"]),
        hap2 = lambda wildcards: hifiasm_mode_hap2(config["mode"])
    output:
        hap1_fa =  config["root"] + "/" + config["resdir"] + "/{id}/{run}/{stepdir}/" + config["asm_raw"] + "/" + config["asm"] + "/{id}_hap1.fa.gz",
        hap2_fa =  config["root"] + "/" + config["resdir"] + "/{id}/{run}/{stepdir}/" + config["asm_raw"] + "/" + config["asm"] + "/{id}_hap2.fa.gz"
    shell:
        """awk {TO_FA_CMD:q} {input.hap1} | pigz -p 1 > {output.hap1_fa} &&"""
        """awk {TO_FA_CMD:q} {input.hap2} | pigz -p 1 > {output.hap2_fa}"""