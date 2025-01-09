from snakemake.io import expand
# Used to retrive the parameters for rules

# Fetch the purge level for hifiasm
def get_purge_force(wildcards):
    try :
        force = config["samples"][wildcards.sample]["assembly_purge_force"]
    except KeyError:
        print('Asm4pg -> "assembly_purge_force" unspecified for ' + wildcards.sample + ', using l3 by default')
        return '3'
    return force

# Fetch the mode for hifiasm
def get_mode(wildcards):
    try :
        mode = config["samples"][wildcards.sample]["mode"]
    except KeyError:
        print('Asm4pg -> "mode" unspecified for ' + wildcards.sample + ', using default assembly mode for hifiasm')
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
        print('Asm4pg -> "run_purge_dups" unspecified for ' + wildcards.sample + ', using "False" by default')
        return False
    return purge_bool

def get_busco_lin(wildcards) -> str:
    try : 
        lin = config["samples"][wildcards.sample]["busco_lineage"]
    except KeyError:
        print('Asm4pg -> "busco_lineage" unspecified for ' + wildcards.sample + ', using "eukaryota_odb10" by default')
        return "eukaryota_odb10"
    return lin

def get_ploidy(wildcards) -> int:
    try : 
        ploidy = config["samples"][wildcards.sample]["ploidy"]
    except KeyError:
        print('Asm4pg -> "ploidy" unspecified for ' + wildcards.sample + ', using 2 by default')
        return 2
    return ploidy

def get_kmer_size(wildcards) -> int:
    try : 
        size = config["samples"][wildcards.sample]["kmer_size"]
    except KeyError:
        print('Asm4pg -> "kmer_size" unspecified for ' + wildcards.sample + ', using 21 by default')
        return 21
    return size