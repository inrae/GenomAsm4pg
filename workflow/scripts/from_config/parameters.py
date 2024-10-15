from snakemake.io import expand

########### GET PARAMETERS FROM CONFIG ###########
#### BUSCO LINEAGE
def get_busco_lin(wildcards):
    id_name = wildcards.id
    lineage = config[f'{id_name}']["busco_lineage"]
    return(lineage)

#### PLOIDY
def get_ploidy(wildcards):
    id_name = wildcards.id
    ploidy = config[f'{id_name}']["ploidy"]
    return(ploidy)

#### RUN NAME
def get_run(wildcards):
    id_name = wildcards.id
    run = config[f'{id_name}']["run"]
    return(run)

#### FASTA
def get_fasta(wildcards):
    id_name = wildcards.id
    fa = config[f'{id_name}']["fasta"]
    return(fa)

#### FASTQ
def get_fastq(wildcards):
    id_name = wildcards.Fid
    fq = config[f'{id_name}']["fastq"]
    return(fq)

#### BAM
def get_bam(wildcards):
    id_name = wildcards.Bid
    fq = config[f'{id_name}']["bam"]
    return(fq)

# Fetch the purge mode, return a boolean from config file
def get_purge(wildcards):
    id_name = wildcards.id
    purge_bool = config[f'{id_name}']["purge_dups"]
    return purge_bool

# Fetch the purge level for hifiasm, return a boolean from config file
def get_purge(wildcards):
    id_name = wildcards.id
    force = config[f'{id_name}']["assembly_purge_force"]
    return force