from snakemake.io import expand
import os

########### FOR TARGET RULE ###########
#### CREATE RUN+ID LIST
def run_id(id_list):
    run_list = []
    for i in id_list:
        run = config[i]["run"]
        run_list.append(i + "/" + run)
    RUNID = expand("{runid}", runid = run_list)
    return(RUNID)

def run_BFid(id_list):
    run_list = []
    for i in id_list:
        run = config[i]["run"]
        run_list.append(run)
    RUNID = expand("{runid}", runid = run_list)
    return(RUNID)

#### REPORT
def for_report(id_list):
    NAME = []
    for i in id_list:
        mode = config[i]["mode"]
        if mode != "trio":
            NAME.append(i)
    return(NAME)

#### REPORT TRIO
def for_report_trio(id_list):
    NAME = []
    for i in id_list:
        mode = config[i]["mode"]
        if mode == "trio":
            NAME.append(i)
    return(NAME)

########### CHECK IF BAM AND FASTQ ARE AVAILABLE ###########
#### BAM
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

#### FASTQ
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