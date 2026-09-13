from snakemake.io import expand
import sys

# Written by Lucien Piat at INRAe
# Used to retrieve the parameters for rules
# Date: 13/09/2026

# Avoid spamming the user with each lambda call of snakemake. 
_WARNED = set()
def warn_once(message: str) -> None:
    if message not in _WARNED:
        _WARNED.add(message)
        print(message, file=sys.stderr)

# rule all and generate_report must know which optional steps are on BEFORE any wildcard exists.
class _Sample:
    def __init__(self, sample):
        self.sample = sample

def samples_with(getter, samples) -> list:
    return [s for s in samples if getter(_Sample(s)) not in (False, 'None')]

# Fetch the purge level for hifiasm
def get_purge_force(wildcards) -> str:
    try:
        force = config["samples"][wildcards.sample]["assembly_purge_force"]
    except KeyError:
        warn_once(f'Asm4pg -> "assembly_purge_force" unspecified for {wildcards.sample}, using l3 by default')
        return '3'
    return force

# Fetch the mode for hifiasm
def get_mode(wildcards) -> str:
    try:
        mode = config["samples"][wildcards.sample]["mode"]
        if mode == "Trio":
            mode = "trio"
    except KeyError:
        warn_once(f'Asm4pg -> "mode" unspecified for {wildcards.sample}, using default assembly mode for hifiasm')
        return 'default'
    return mode

# Fetch r1/r2 fasta file for hi-c
def get_run(wildcards, run: int) -> str:
    try:
        # Try to get the value with lowercase (r1 or r2)
        run = config["samples"][wildcards.sample][f"r{run}"]
    except KeyError:
        try:
            # If the lowercase key doesn't work, try uppercase (R1 or R2)
            run = config["samples"][wildcards.sample][f"R{run}"]
        except KeyError:
            # If both fail, return 'None'
            return 'None'
    return run

# Fetch the purge mode, return a boolean from config file
def get_purge_bool(wildcards) -> bool:
    try: 
        purge_bool = config["samples"][wildcards.sample]["run_purge_dups"]
    except KeyError:
        warn_once(f'Asm4pg -> "run_purge_dups" unspecified for {wildcards.sample}, using "False" by default')
        return False
    return purge_bool

# Fetch the BUSCO lineage
def get_busco_lin(wildcards) -> str:
    try:
        lin = config["samples"][wildcards.sample]["busco_lineage"]
    except KeyError:
        warn_once(f'Asm4pg -> "busco_lineage" unspecified for {wildcards.sample}, using "eukaryota_odb10" by default')
        return "eukaryota_odb10"
    return lin

# compleasm takes the lineage name and the OrthoDB as separate arguments,
def split_lineage(lineage: str):
    if "_odb" in lineage:
        name, odb = lineage.split("_odb", 1)
        return name, "odb" + odb
    return lineage, "odb10"

# Fetch the genome ploidy
def get_ploidy(wildcards) -> int:
    try:
        ploidy = config["samples"][wildcards.sample]["ploidy"]
    except KeyError:
        warn_once(f'Asm4pg -> "ploidy" unspecified for {wildcards.sample}, using 2 by default')
        return 2
    return ploidy

# Fetch the k-mer size
def get_kmer_size(wildcards) -> int:
    try:
        size = config["samples"][wildcards.sample]["kmer_size"]
    except KeyError:
        warn_once(f'Asm4pg -> "kmer_size" unspecified for {wildcards.sample}, using 21 by default')
        return 21
    return size

# Fetch the reference mito genome (list of two files)
def get_mito_reference(wildcards) -> list:
    try:
        ref = config["samples"][wildcards.sample]["reference_mitochondrial_genome"]
    except KeyError:
        return 'None'
    return ref

# Fetch the reference chloroplast genome. 
def get_chloro_reference(wildcards) -> str:
    try:
        return config["samples"][wildcards.sample]["reference_chloroplast_genome"]
    except KeyError:
        return 'None'

# Fetch the reference  genome
def get_reference(wildcards) -> str:
    try:
        reference_genome = config["samples"][wildcards.sample]["reference_genome"]
    except KeyError:
        return 'None'
    return reference_genome

# Fetch whether to run RagTag
def get_ragtag_bool(wildcards) -> bool:
    try:
        ragtag_bool = config["samples"][wildcards.sample]["run_ragtag"]
    except KeyError:
        warn_once(f'Asm4pg -> "run_ragtag" unspecified for {wildcards.sample}, using "False" by default')
        return False
    return ragtag_bool

# Fetch whether to run QUAST
def get_quast_bool(wildcards) -> bool:
    try:
        quast_bool = config["samples"][wildcards.sample]["run_quast"]
        if quast_bool=="true":
            quast_bool = True
    except KeyError:
        warn_once(f'Asm4pg -> "run_quast" unspecified for {wildcards.sample}, using "False" by default')
        return False
    return quast_bool


# Fetch whether to run downsampling
def get_downsampling_bool(wildcards) -> bool:
    try:
        run_ds = config["samples"][wildcards.sample]["run_downsampling"]
        if run_ds == "true":
            run_ds = True
    except KeyError:
        warn_once(f'Asm4pg -> "run_downsampling" unspecified for {wildcards.sample}, using "False" by default')
        return False
    return run_ds

def get_target_coverage(wildcards) -> int:
    try:
        cov = config["samples"][wildcards.sample]["target_coverage"]
    except KeyError:
        warn_once(f'Asm4pg -> "target_coverage" unspecified for {wildcards.sample}, using 50 by default')
        return 50
    return cov
