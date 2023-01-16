# <A HREF="https://forgemia.inra.fr/asm4pg/GenomAsm4pg"> asm4pg </A>

Asm4pg is an automatic and reproducible genome assembly workflow for pangenomic applications using PacBio HiFi data.

[TOC]

![workflow DAG](doc/fig/rule_dag.svg)

## Asm4pg Requirements
- snakemake >= 6.5.1
- singularity

The workflow does not work with HPC that does not allow a job to run other jobs.

## Tutorials
The three assembly modes from hifiasm are available.
- [Quick start (default mode)](Quick-start)
- [Hi-C mode](doc/Assembly-Mode/Hi-C-tutorial)
- [Trio mode](doc/Assembly-Mode/Trio-tutorial)

## Outputs
[Workflow outputs](doc/Outputs)

## Optional Data Preparation
If your [data is in a tarball](doc/Tar-data-preparation)

## Known errors
You may run into [these errors](doc/Known-errors)

## Softwares
[Softwares used in the workflow](doc/Programs)
