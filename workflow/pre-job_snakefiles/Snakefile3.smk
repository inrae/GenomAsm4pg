configfile: ".config/masterconfig.yaml"

######################## Python functions ########################
import os
# fastq without fasta filename
def get_fastq_name(dirpath):
    IDS = []
    for file in os.listdir(dirpath):
        splitResult = file.split(".")
        ext = splitResult[-1]
        if ext == "gz":
            if splitResult[-2] == "fastq":
                filename= ".".join(splitResult[:-2])
                fasta_filename = dirpath + "/" + filename + ".fasta.gz"
                if not os.path.exists(fasta_filename):
                    IDS.append(filename)
    return(IDS)

######################## Snakemake ########################
###### results path ######
res_path=config["root"] + "/" + config["resdir"]

### get filenames
IDS = get_fastq_name(config["root"] + "/" + config["resdir"] + "/" + config["fastxdir"])

### target files
rule all:
    input:
        expand(config["root"] + "/" + config["resdir"] + "/" + config["fastxdir"] + "/{id}.fasta.gz", id=IDS)

### rules
# if only fastq : convert to fasta with seqtk + zip
rule convert_to_fasta:
    input:
        config["root"] + "/" + config["resdir"] + "/" + config["fastxdir"] + "/{id}.fastq.gz"
    output:
        config["root"] + "/" + config["resdir"] + "/" + config["fastxdir"] + "/{id}.fasta.gz"
    params:
        path=config["root"] + "/" + config["resdir"] + "/" + config["fastxdir"]
    threads: 10
    container:
        "docker://nanozoo/seqtk:1.3--dc0d16b"
    shell:
        "seqtk seq -a {input} | gzip > {output}"