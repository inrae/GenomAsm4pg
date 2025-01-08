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


