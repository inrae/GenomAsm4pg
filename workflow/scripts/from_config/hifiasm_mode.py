########### GET THE ASSEMBLY MODE ###########
def get_mode(wildcards):
    id_name = wildcards.id
    mode = config[f'{id_name}']["mode"]
    return(mode)

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

########### GET MODE REQUIRED FILES ###########
#### HI-C MODE
def get_r1(wildcards):
    id = wildcards.id
    r1 = config[f'{id}']["r1"]
    return r1

def get_r2(wildcards):
    id = wildcards.id
    r2 = config[f'{id}']["r2"]
    return r2

#### TRIO MODE
def get_p1(wildcards):
    id = wildcards.id
    p1 = config[f'{id}']["p1"]
    return p1

def get_p2(wildcards):
    id = wildcards.id
    p2 = config[f'{id}']["p2"]
    return p2