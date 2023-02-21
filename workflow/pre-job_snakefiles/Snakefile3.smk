configfile: ".config/masterconfig.yaml"

include: "../scripts/path_helper.py"

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

### root path
if config["root"] == ".":
    abs_root_path = get_abs_root_path()
    res_path = get_res_path()
else:
    abs_root_path = config["root"]
    res_path = abs_root_path + "/" + config["resdir"]

### get filenames
IDS = get_fastq_name(abs_root_path + "/" + config["resdir"] + "/" + config["fastxdir"])

### target files
rule all:
    input:
        expand(abs_root_path + "/" + config["resdir"] + "/" + config["fastxdir"] + "/{id}.fasta.gz", id=IDS)

### rules
# if only fastq : convert to fasta with seqtk + zip
rule convert_to_fasta:
    input:
        abs_root_path + "/" + config["resdir"] + "/" + config["fastxdir"] + "/{id}.fastq.gz"
    output:
        abs_root_path + "/" + config["resdir"] + "/" + config["fastxdir"] + "/{id}.fasta.gz"
    params:
        path= abs_root_path + "/" + config["resdir"] + "/" + config["fastxdir"]
    threads: 10
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/seqtk1.3"
    shell:
        "seqtk seq -a {input} | gzip > {output}"