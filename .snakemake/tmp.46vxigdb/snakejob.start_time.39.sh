#!/bin/bash
# properties = {"type": "single", "rule": "start_time", "local": false, "input": [], "output": ["/mnt/cbib/pangenoak_trials/GenomAsm4pg/tutorial_output/results/toy_dataset_bug/toy_test_run/runtime.txt"], "wildcards": {"runid": "toy_dataset_bug/toy_test_run"}, "params": {}, "log": [], "threads": 1, "resources": {"tmpdir": "/tmp"}, "jobid": 39, "cluster": {"job-name": "start_time", "time": "96:00:00", "ntasks": 1, "cpus-per-task": 4, "mem": "60G", "nodes": 1, "ntasks-per-node": 1, "output": "slurm_logs/start_time.%N.%j.out", "error": "slurm_logs/start_time.%N.%j.err", "mail-type": "END,FAIL", "mail-user": "lucien.piat@inrae.fr"}}
 cd /isilon/cbib/pangenoak_trials/GenomAsm4pg && \
/module/apps/snakemake/5.8.1/bin/python \
-m snakemake /mnt/cbib/pangenoak_trials/GenomAsm4pg/tutorial_output/results/toy_dataset_bug/toy_test_run/runtime.txt --snakefile /isilon/cbib/pangenoak_trials/GenomAsm4pg/workflow/Snakefile \
--force --cores all --keep-target-files --keep-remote --max-inventory-time 0 \
--wait-for-files /isilon/cbib/pangenoak_trials/GenomAsm4pg/.snakemake/tmp.46vxigdb --latency-wait 60 \
 --attempt 1 --force-use-threads --scheduler greedy \
--wrapper-prefix https://github.com/snakemake/snakemake-wrappers/raw/ \
   --allowed-rules start_time --nocolor --notemp --no-hooks --nolock --scheduler-solver-path /module/apps/snakemake/5.8.1/bin \
--mode 2  --use-singularity  --singularity-args "-B /mnt/cbib/pangenoak_trials/GenomAsm4pg/" --default-resources "tmpdir=system_tmpdir"  && exit 0 || exit 1

