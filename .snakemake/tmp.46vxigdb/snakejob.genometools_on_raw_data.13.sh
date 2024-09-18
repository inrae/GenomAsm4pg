#!/bin/bash
# properties = {"type": "single", "rule": "genometools_on_raw_data", "local": false, "input": ["/mnt/cbib/pangenoak_trials/GenomAsm4pg/lady_bug_data.fasta.gz"], "output": ["/mnt/cbib/pangenoak_trials/GenomAsm4pg/tutorial_output/results/toy_dataset_bug/toy_test_run/01_raw_data_QC/03_genometools/toy_dataset_bug.RawStat.txt"], "wildcards": {"runid": "toy_dataset_bug/toy_test_run", "id": "toy_dataset_bug"}, "params": {}, "log": [], "threads": 4, "resources": {"tmpdir": "/tmp"}, "jobid": 13, "cluster": {"job-name": "genometools_on_raw_data", "time": "96:00:00", "ntasks": 1, "cpus-per-task": 4, "mem": "60G", "nodes": 1, "ntasks-per-node": 1, "output": "slurm_logs/genometools_on_raw_data.%N.%j.out", "error": "slurm_logs/genometools_on_raw_data.%N.%j.err", "mail-type": "END,FAIL", "mail-user": "lucien.piat@inrae.fr"}}
 cd /isilon/cbib/pangenoak_trials/GenomAsm4pg && \
/module/apps/snakemake/5.8.1/bin/python \
-m snakemake /mnt/cbib/pangenoak_trials/GenomAsm4pg/tutorial_output/results/toy_dataset_bug/toy_test_run/01_raw_data_QC/03_genometools/toy_dataset_bug.RawStat.txt --snakefile /isilon/cbib/pangenoak_trials/GenomAsm4pg/workflow/Snakefile \
--force --cores all --keep-target-files --keep-remote --max-inventory-time 0 \
--wait-for-files /isilon/cbib/pangenoak_trials/GenomAsm4pg/.snakemake/tmp.46vxigdb /mnt/cbib/pangenoak_trials/GenomAsm4pg/lady_bug_data.fasta.gz --latency-wait 60 \
 --attempt 1 --force-use-threads --scheduler greedy \
--wrapper-prefix https://github.com/snakemake/snakemake-wrappers/raw/ \
   --allowed-rules genometools_on_raw_data --nocolor --notemp --no-hooks --nolock --scheduler-solver-path /module/apps/snakemake/5.8.1/bin \
--mode 2  --use-singularity  --singularity-args "-B /mnt/cbib/pangenoak_trials/GenomAsm4pg/" --default-resources "tmpdir=system_tmpdir"  && exit 0 || exit 1

