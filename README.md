# <A HREF="https://forgemia.inra.fr/asm4pg/GenomAsm4pg"> asm4pg </A>
An automatic and reproducible genome assembly workflow for pangenomic applications using PacBio HiFi data.

This workflow uses [Snakemake](https://snakemake.readthedocs.io/en/stable/) to quickly assemble genomes with a HTML report summarizing obtained assembly stats.

A first script (```prejob.sh```) prepares the data until *fasta.gz* files are obtained. A second script (```job.sh```) runs the genome assembly and stats.

doc: [Gitlab pages](https://asm4pg.pages.mia.inra.fr/GenomAsm4pg/)

![workflow DAG](workflow/doc/fig/rule_dag.svg)

## Table of contents
# Summary

* [Introduction](README.md)
* [Documentation summary](workflow/documentation.md)
    * [Requirements](workflow/documentation.md#asm4pg-requirements)
    * [Tutorials](workflow/documentation.md#tutorials)
        * [Quick start](workflow/doc/Quick-start.md)
        * [Hi-C mode](workflow/doc/Assembly-Mode/Hi-C-tutorial.md)
        * [Trio mode](workflow/doc/Assembly-Mode/Trio-tutorial.md)
    * [Outputs](workflow/documentation.md#outputs)
        * [Workflow output](workflow/doc/Outputs.md)
    * [Optional data preparation](workflow/documentation.md#optional-data-preparation)
        * [if your data is in a tarball archive](workflow/doc/Tar-data-preparation.md)
    * [Going further](workflow/doc/Going-further.md)
    * [Troubleshooting](workflow/documentation.md#known-errors)
        * [known errors](workflow/doc/Known-errors.md)
    * [Software Dependencies](workflow/documentation.md#programs)
        * [Programs listing](workflow/doc/Programs.md)
* [Gitlab pages using honkit](honkit.md)

## Repo directory structure

```
├── README.md
├── job.sh
├── prejob.sh
├── workflow
│   ├── rules
│   ├── scripts
│   ├── pre-job_snakefiles
|   └── Snakefile
└──  .config
    ├── snakemake_profile
    |  └── slurm
    |       ├── cluster_config.yml
    |       ├── config.yaml
    |       ├── CookieCutter.py
    |       ├── settings.json
    |       ├── slurm_utils.py
    |       ├── slurm-jobscript.sh
    |       ├── slurm-status.py
    |       └── slurm-submit.py
    └── masterconfig.yaml
```

## Requirements
- snakemake >= 6.5.1
- singularity

## How to run the workflow
[wiki](https://forgemia.inra.fr/asm4pg/GenomAsm4pg/-/wikis/home)

## How to cite asm4pg? ##

We are currently writing a publication about asm4pg. Meanwhile, if you use the pipeline, please cite it using the address of this repository. 

## License ##

The content of this repository is licensed under <A HREF="https://choosealicense.com/licenses/gpl-3.0/">(GNU GPLv3)</A> 

## Contacts ##
For any troubleshouting, issue or feature suggestion, please use the issue tab of this repository.
For any other question or if you want to help in developing asm4pg, please contact Ludovic Duvaux at ludovic.duvaux@inrae.fr
