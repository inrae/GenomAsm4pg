from snakemake.io import expand

### which hifiasm mode
def get_mode_hap1(wildcards):
    id_name = wildcards.id
    mode = config[f'{id_name}']["mode"]
    if mode == "hi-c":
        return(str(rules.hifiasm_hic.output.hap1))
    elif mode == "trio":
        return(str(rules.hifiasm_trio.output.hap1))
    elif mode == "default":
        return(str(rules.hifiasm.output.hap1))

def get_mode_hap2(wildcards):
    id_name = wildcards.id
    mode = config[f'{id_name}']["mode"]
    if mode == "hi-c":
        return(str(rules.hifiasm_hic.output.hap2))
    elif mode == "trio":
        return(str(rules.hifiasm_trio.output.hap2))
    elif mode == "default":
        return(str(rules.hifiasm.output.hap2))

######################################
### get params from config
# BUSCO
def get_busco_lin(wildcards):
    id_name = wildcards.id
    lineage = config[f'{id_name}']["busco_lineage"]
    return(lineage)

# ploidy, genomescope
def get_ploidy(wildcards):
    id_name = wildcards.id
    ploidy = config[f'{id_name}']["ploidy"]
    return(ploidy)

def get_run(wildcards):
    id_name = wildcards.id
    run = config[f'{id_name}']["run"]
    return(run)

######################################
# give IDS as list
def run_id(id_list):
    run_list = []
    for i in id_list:
        run = config[i]["run"]
        run_list.append(i + "/" + run)
    RUNID = expand("{runid}", runid = run_list)
    return(RUNID)

######################################
## reads hi-c
def get_r1(wildcards):
    id = wildcards.id
    r1 = config[f'{id}']["r1"]
    return r1

def get_r2(wildcards):
    id = wildcards.id
    r2 = config[f'{id}']["r2"]
    return r2

### get .yak from both parents
def get_p1(wildcards):
    id = wildcards.id
    p1 = config[f'{id}']["p1"]
    return p1

def get_p2(wildcards):
    id = wildcards.id
    p2 = config[f'{id}']["p2"]
    return p2