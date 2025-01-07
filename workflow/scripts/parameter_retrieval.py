from snakemake.io import expand
# Used to retrive the parameters for rules

# Fetch the purge level for hifiasm
def get_purge_force(wildcards):
    try :
        force = config["samples"][wildcards.sample]["assembly_purge_force"]
    except KeyError:
        print('Asm4pg -> No "assembly_purge_force" specified, using l3 by default')
        return '3'
    return force

# Fetch the mode for hifiasm
def get_mode(wildcards):
    try :
        mode = config["samples"][wildcards.sample]["mode"]
    except KeyError:
        print('Asm4pg -> No "mode" specified, using default assembly mode for hifiasm')
        return 'default'
    return mode

# Fetch r1/r2 fasta file for hi-c
def get_run(wildcards, run:int):
    try :
        run= config["samples"][wildcards.sample][f"r{run}"]
    except KeyError:
        return 'None'
    return run

# Fetch the purge mode, return a boolean from config file
def get_purge_bool(wildcards):
    try : 
        purge_bool = config["samples"][wildcards.sample]["run_purge_dups"]
    except KeyError:
        print('Asm4pg -> "run_purge_dups" unspecified, using "False" by default')
        return False
    return purge_bool
