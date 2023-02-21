configfile: ".config/masterconfig.yaml"

include: "../scripts/path_helper.py"

######################## Python functions ########################
import os
# bam filename
def get_bams_name(dirpath):
    IDS = []
    for file in os.listdir(dirpath):
        splitResult = file.split(".")
        ext = splitResult[-1]
        if ext == "bam":
            filename= ".".join(splitResult[:-1])
            IDS.append(filename)
    return(IDS)

######################## Snakemake ########################

### root path
if config["root"] == ".":
    abs_root_path = get_abs_root_path()
    res_path = get_res_path()
else:
    abs_root_path = config["root"]
    res_path = abs_root_path + "/" + config["resdir"]

### get filenames
IDS=get_bams_name(abs_root_path + "/" + config["resdir"] + "/" + config["bamdir"])

### target files
rule all:
    input:
        expand(abs_root_path + "/" + config["resdir"] + "/" + config["fastxdir"] + "/{id}.fastq.gz", id=IDS),
        expand(abs_root_path + "/" + config["resdir"] + "/" + config["fastxdir"] + "/{id}.fasta.gz", id=IDS)

### rules
## PacBio .bam conversion with smrtlink
# .bam.pbi needed for bam_to_ conversion rules
rule smrtlink_index:
    input:
        abs_root_path + "/" + config["resdir"] + "/" + config["bamdir"] + "/{id}.bam"
    output:
        abs_root_path + "/" + config["resdir"] + "/" + config["bamdir"] + "/{id}.bam.pbi"
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/smrtlink9.0"
    shell:
        "pbindex {input}"

# convert .bam to .fastq.gz
rule smrtlink_bam_to_fastq:
    input:
        bam = abs_root_path + "/" + config["resdir"] + "/" + config["bamdir"] + "/{id}.bam",
        bam_pbi = rules.smrtlink_index.output
    output:
        abs_root_path + "/" + config["resdir"] + "/" + config["fastxdir"] + "/{id}.fastq.gz"
    params:
        prefix= abs_root_path + "/" + config["resdir"] + "/" + config["fastxdir"] + "/{id}"
    priority: 2
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/smrtlink9.0"
    shell:
        "bam2fastq -o {params.prefix} {input.bam}"

# convert .bam to .fasta.gz
rule smrtlink_bam_to_fasta:
    input:
        bam = abs_root_path + "/" + config["resdir"] + "/" + config["bamdir"] + "/{id}.bam",
        bam_pbi = rules.smrtlink_index.output
    output:
        abs_root_path + "/" + config["resdir"] + "/" + config["fastxdir"] + "/{id}.fasta.gz"
    params:
        prefix= abs_root_path + "/" + config["resdir"] + "/" + config["fastxdir"] + "/{id}"
    priority: 2
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/smrtlink9.0"
    shell:
        "bam2fasta -o {params.prefix} {input.bam}"