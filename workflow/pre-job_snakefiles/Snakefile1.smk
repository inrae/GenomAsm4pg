configfile: ".config/masterconfig.yaml"

######################## Python functions ########################
import os, re
# tar & tar.gz filename
def get_tar_name(dirpath):
    IDS = []
    for file in os.listdir(dirpath):
        splitResult = file.split(".")
        ext = splitResult[-1]
        if ext == "tar":
            filename= ".".join(splitResult[:-1])
            IDS.append(filename)
        elif ext == "gz":
            if splitResult[-2] == "tar":
                filename= ".".join(splitResult[:-2])
                IDS.append(filename)
    return(IDS)

# file extension
def data_ext(dir, id):
    for filename in os.listdir(dir):
        if re.match(id, filename):
            splitResult = filename.split(".")
            ext = splitResult[-1]
            if ext == "tar":
                return(str(config["data"] + "/{id}.tar"))
            else:
                return(str(config["data"] + "/{id}.tar.gz"))

######################## Snakemake ########################

### paths
if config["root"].startswith("."):
    abs_root_path = get_abs_root_path()
    res_path = get_res_path()
else:
    abs_root_path = config["root"]
    res_path = abs_root_path + "/" + config["resdir"]

### get filenames for workflow
if config["get_all_tar_filename"]:
    IDS=get_tar_name(config["data"])
else:
    IDS=config["tarIDS"]

###### results path ######

### target files
rule all:
    input:
        expand("{resdir}/{stepdir}/extract/{id}", resdir=res_path, stepdir=config["rawdir"], id=IDS),

### rules
# extract & rename files from .tar containing .bam files
rule extract_targz_data:
    input:
        lambda wildcards: data_ext(config["data"], wildcards.id),
    output:
        directory("{resdir}/{stepdir}/extract/{id}")
    priority: 10
    shell:
        "mkdir -p {output} && "
        "tar -xf {input} -C {output} && "
        "cd {output} && "
        "find . -name ""ccs.bam"" -exec mv '{{}}' {wildcards.id}.bam \;"
    
# move bam and fasta + fastq files
rule move_files:
    params:
        root=abs_root_path,
        bam_path=abs_root_path + "/" + config["resdir"] + "/" + config["bamdir"],
        fastx_path=abs_root_path + "/" + config["resdir"] + "/" + config["fastxdir"],
    shell:
        "cd {params.root} && "
        "mkdir -p {params.bam_path} {params.fastx_path} && "
        "find . -path ""*/extract/*"" -name ""*.bam"" -exec mv ""{{}}"" {params.bam_path} \; && "
        "find . -path ""*/extract/*"" -name ""*.fast*"" -exec mv ""{{}}"" {params.fastx_path} \;"