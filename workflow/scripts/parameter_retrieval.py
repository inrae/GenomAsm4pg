from snakemake.io import expand
# Used to retrive the parameters for rules

# Fetch the purge level for hifiasm
def get_purge_force(wildcards):
    try :
        force = config["samples"][wildcards.sample]["assembly_purge_force"]
    except KeyError:
        print('No "assembly_purge_force" specified, using l3 by default')
        return '3'
    return force

def get_mode(wildcards):
    try :
        mode = config["samples"][wildcards.sample]["mode"]
    except KeyError:
        print('No "mode" specified, using default')
        return 'default'
    return mode

def get_run(wildcards, run:int):
    try :
        run= config["samples"][wildcards.sample][f"r{run}"]
    except KeyError:
        return 'None'
    return run