# [Asm4pg](https://forgemia.inra.fr/asm4pg/GenomAsm4pg)  

**Asm4pg** is an **automatic and reproducible genome assembly workflow** designed for **pangenomic applications** using **PacBio HiFi data**.  

This workflow leverages **[Snakemake](https://snakemake.readthedocs.io/en/stable/)** for efficient genome assembly and generates an **HTML report** summarizing key assembly statistics.  

![Workflow DAG](doc/dag.svg)  

## 📂 Repository Structure  



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

## ✅ Requirements  

- **Miniforge (or Snakemake 8.4.7 localy)**
- **Singularity/Apptainer** (for containerized execution)  

> **Note:** All external tools are automatically managed by Snakemake and will be downloaded as Singularity/Apptainer images (~6GB total).  

---

## 🚀 How to Use  
### 1. Set up
Clone the Git repository
```bash
git clone https://forgemia.inra.fr/asm4pg/GenomAsm4pg.git && cd GenomAsm4pg
```
> All other tools will be run in `Singularity/Apptainer` docker images are automatically downloaded and converted by `Snakemake`. Total size of the images is ~6G
### 2. Configure the pipeline
- Edit the `masterconfig` file in the `.config/` directory with your sample information. 

### 3. Run the workflow 

#### <ins>A. On a HPC (SLURM)</ins>
- Update job.sh with the correct paths to Singularity/Apptainer and Miniforge.
- Provide and environment with `Snakemake` and `snakemake-executor-plugin-slurm` in `job.sh`, under `source activate wf_env`, you can create it like this : 
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
#### <ins>B. Locally (or single node HPC)</ins>
- Make sure you have Snakemake and Singularity/Apptainer installed
- Run the workflow :
```bash
./local_run dry # Check for warnings
./local_run job.sh run # Then
```

## 🔄 Input Conversion
Currently, asm4pg requires `fasta.gz` files. To convert your `fastq` or `bam` files to this format, you can use the following tools:
```bash
./workflow/scripts/input_conversion.sh -i <input_file> -o <output_file>
```
> **Nb :** Uncomment line 13 and 14 if you are on a HPC and update with your paths
## 🔧 Using the full potential of the workflow :
Asm4pg has many options. If you wish to modify the default values and know more about the workflow, please refer to the [documentation](doc/documentation.md)

## 📜 How to cite asm4pg?

We are currently writing a publication about asm4pg. Meanwhile, if you use the pipeline, please cite it using the address of this repository. 

## License
The content of this repository is licensed under <A HREF="https://choosealicense.com/licenses/gpl-3.0/">(GNU GPLv3)</A> 

## ✉️ Contacts
For any troubleshooting, issue or feature suggestion, please use the issue tab of this repository.
For any other question or if you want to help in developing asm4pg, please contact Ludovic Duvaux at ludovic.duvaux@inrae.fr
