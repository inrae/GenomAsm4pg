### get filenames as IDS list
# called in Snakefile, before Snakemake starts the workflow
import os

## get fasta filename
def get_files_id(dirpath):
    IDS = []
    for file in os.listdir(dirpath):
        splitResult = file.split(".")
        ext = splitResult[-1]
        if ext == "gz":
            if splitResult[-2] == "fasta":
                filename= ".".join(splitResult[:-2])
                IDS.append(filename)
    return(IDS)

## get bam filename
def check_bam(dirpath, IDlist):
    IDS = []
    for file in os.listdir(dirpath):
        splitResult = file.split(".")
        if splitResult[0] in IDlist:
            ext = splitResult[-1]
            if ext == "bam":
                filename= ".".join(splitResult[:-1])
                IDS.append(filename)
    return(IDS)

# get fastq filenames
def check_fastq(dirpath, IDlist):
    IDS = []
    for file in os.listdir(dirpath):
        splitResult = file.split(".")
        if splitResult[0] in IDlist:
            ext = splitResult[-1]
            if ext == "gz":
                if splitResult[-2] == "fastq":
                    filename= ".".join(splitResult[:-2])
                    IDS.append(filename)
    return(IDS)