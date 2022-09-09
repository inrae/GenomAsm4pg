configfile: ".config/masterconfig.yaml"

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
###### results path ######
res_path=config["root"] + "/" + config["resdir"]

### get filenames
IDS=get_bams_name(config["root"] + "/" + config["resdir"] + "/" + config["bamdir"])

### target files
rule all:
    input:
        expand(config["root"] + "/" + config["resdir"] + "/" + config["fastxdir"] + "/{id}.fastq.gz", id=IDS),
        expand(config["root"] + "/" + config["resdir"] + "/" + config["fastxdir"] + "/{id}.fasta.gz", id=IDS)

### rules
## PacBio .bam conversion with smrtlink
# .bam.pbi needed for bam_to_ conversion rules
rule smrtlink_index:
    input:
        config["root"] + "/" + config["resdir"] + "/" + config["bamdir"] + "/{id}.bam"
    output:
        config["root"] + "/" + config["resdir"] + "/" + config["bamdir"] + "/{id}.bam.pbi"
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/smrtlink9.0"
    shell:
        "pbindex {input}"

# convert .bam to .fastq.gz
rule smrtlink_bam_to_fastq:
    input:
        bam = config["root"] + "/" + config["resdir"] + "/" + config["bamdir"] + "/{id}.bam",
        bam_pbi = rules.smrtlink_index.output
    output:
        config["root"] + "/" + config["resdir"] + "/" + config["fastxdir"] + "/{id}.fastq.gz"
    params:
        prefix=config["root"] + "/" + config["resdir"] + "/" + config["fastxdir"] + "/{id}"
    priority: 2
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/smrtlink9.0"
    shell:
        "bam2fastq -o {params.prefix} {input.bam}"

# convert .bam to .fasta.gz
rule smrtlink_bam_to_fasta:
    input:
        bam = config["root"] + "/" + config["resdir"] + "/" + config["bamdir"] + "/{id}.bam",
        bam_pbi = rules.smrtlink_index.output
    output:
        config["root"] + "/" + config["resdir"] + "/" + config["fastxdir"] + "/{id}.fasta.gz"
    params:
        prefix=config["root"] + "/" + config["resdir"] + "/" + config["fastxdir"] + "/{id}"
    priority: 2
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/smrtlink9.0"
    shell:
        "bam2fasta -o {params.prefix} {input.bam}"