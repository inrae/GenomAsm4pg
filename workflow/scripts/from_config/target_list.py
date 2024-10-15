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

# Create a list of purge datasets
def for_purge(id_list, trio =False):
    NAME = []
    for i in id_list:
        mode = config[i]["mode"]
        if mode == "trio" and trio and config[i]["run_purge_dups"]:
            NAME.append(i)
        elif trio == False and config[i]["run_purge_dups"]:
            NAME.append(i)
    return(NAME)

# Create a list of not_purged datasets
def for_report(id_list, trio =False):
    NAME = []
    for i in id_list:
        mode = config[i]["mode"]
        if mode == "trio" and trio and config[i]["run_purge_dups"]==False:
            NAME.append(i)
        elif trio == False and config[i]["run_purge_dups"]==False:
            NAME.append(i)
    return(NAME)

#### BUSCO LINEAGE
def busco_lin(id_list):
    lineage_list = []
    for i in id_list:
        lineage = config[i]["busco_lineage"]
        lineage_list.append(lineage)
    return(lineage_list)

########### CHECK IF BAM AND FASTQ ARE AVAILABLE ###########
#### BAM
def check_bam(id_list):
    IDS = []
    for i in id_list:
        if "bam" in config[i]:
            IDS.append(i)
    return(IDS)

#### FASTQ
def check_fastq(id_list):
    IDS = []
    for i in id_list:
        if "fastq" in config[i]:
            IDS.append(i)
    return(IDS)
