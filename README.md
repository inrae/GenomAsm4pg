# <A HREF="https://forgemia.inra.fr/asm4pg/GenomAsm4pg"> asm4pg </A>
This is an automatic and reproducible genome assembly workflow for pangenomic applications using PacBio HiFi data.

This workflow uses [Snakemake](https://snakemake.readthedocs.io/en/stable/) to quickly assemble genomes with a HTML report summarizing obtained assembly stats.

![workflow DAG](doc/dag.svg)

## Repo directory structure

```
├── README.md
├── job.sh
├── local_run.sh
├── doc
├── workflow
│   ├── scripts
|   └── Snakefile
└──  .config
    ├── snakemake_profile
    └── masterconfig.yaml
```

## Requirements
Miniforge (Snakemake), Singularity/Apptainer
## How to Use
### 1. Set up
Clone the Git repository
```bash
git clone https://forgemia.inra.fr/asm4pg/GenomAsm4pg.git && cd GenomAsm4pg
```
> All other tools will be run in Singularity/Apptainer images automatically downloaded by Snakemake. Total size of the images is ~5.5G
### 2. Configure the pipeline
- Edit the `masterconfig` file in the `.config/` directory with your sample information. 

### 3. Run the workflow 

#### <ins>A. On a HPC</ins>
- Edit `job.sh` with path to the modules `Singularity/Apptainer`, `Miniforge`
- Provide and environment with `Snakemake` and `snakemake-executor-plugin-slurmin` in `job.sh`, under `source activate wf_env`, you can create it like this : 
```bash
conda create -n wf_env -c conda-forge -c bioconda snakemake=8.4.7 snakemake-executor-plugin-slurm
```  
> Use Miniforge with the conda-forge channel, see why [here](https://science-ouverte.inrae.fr/fr/offre-service/fiches-pratiques-et-recommandations/quelles-alternatives-aux-fonctionnalites-payantes-danaconda) (french)
- Add the log directory for SLURM 
```bash
mkdir slurm_logs
```
- Run the workflow :
```bash
sbatch job.sh dry # Check for warnings
sbatch job.sh run # Then
```
> **Nb 1:** If your account name can't be automatically determined, add it in the `.config/snakemake/profiles/slurm/config.yaml` file.
#### <ins>B. Locally</ins>
- Make sure you have Snakemake and Singularity/Apptainer installed
- Run the workflow :
```bash
./local_run dry # Check for warnings
./local_run job.sh run # Then
```

## Using the full potential of the workflow :
Asm4pg has many options. If you wish to modify the default values and know more about the workflow, please refer to the [documentation](doc/documentation.md)

## How to cite asm4pg?

We are currently writing a publication about asm4pg. Meanwhile, if you use the pipeline, please cite it using the address of this repository. 

## License
The content of this repository is licensed under <A HREF="https://choosealicense.com/licenses/gpl-3.0/">(GNU GPLv3)</A> 

## Contacts
For any troubleshooting, issue or feature suggestion, please use the issue tab of this repository.
For any other question or if you want to help in developing asm4pg, please contact Ludovic Duvaux at ludovic.duvaux@inrae.fr
