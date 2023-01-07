If your data is in a tarball, this companion workflow will extract the data and convert bam files to fastq and fasta if necessary.

[TOC]

# 1. Config file
```bash
cd GenomAsm4pg/.config
```
Modify the the `data` variable in file `.config/masterconfig.yaml` to be the path to the directory containing all input tar files.
This workflow can automatically determine the name of files in the specified `data` directory, or run only on given files :
- `get_all_tar_filename: True` will uncompress all tar files. If you want to choose the the files to uncompress, use `get_all_tar_filename: False` and give the filenames as a list in `tarIDS`

# 2. Run 
Modify the `SNG_BIND` variable in `prejob.sh`, it has to be the same as the variable `root` in `.config/masterconfig.yaml`. Change line 17 to your email adress.
If Singularity is not in the HPC environement, add `module load singularity` under Module loading.

Then run

```bash
sbatch prejob.sh
```

# 3. Outputs
This will create multiple directories to prepare the data for the workflow. You will end up with a `bam_files` directory containing all *bam* files, renamed as the tar filename if your data was named "ccs.bam", and a `fastx_files` directory containing all *fasta* and *fastq* files. The `extract` directory contains all other files that were in the tar ball.

```
workflow_results
└── 00_raw_data
	├── bam_files
	├── extract
	└── fastx_files
```