### assembly stats with genometools
# input haplotypes
HAP_FA_GZ = config["root"] + "/" + config["resdir"] + "/{id}/{run}/" + config["assembdir"] + "/" + config["asm_raw"] + "/" + config["asm"] + "/{id}_hap{n}.fa.gz"

use rule genometools_on_raw_data as genometools_on_assembly with:
    input:
        HAP_FA_GZ
    output:
        "{resdir}/{id}/{run}/{stepdir}/{asmdir}/{subdir}/assembly_stats/{id}_hap{n}.AStats.txt"

