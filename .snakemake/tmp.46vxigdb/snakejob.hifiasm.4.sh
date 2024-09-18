#!/bin/bash
# properties = {"type": "single", "rule": "hifiasm", "local": false, "input": ["/mnt/cbib/pangenoak_trials/GenomAsm4pg/lady_bug_data.fasta.gz"], "output": ["/mnt/cbib/pangenoak_trials/GenomAsm4pg/tutorial_output/results/toy_dataset_bug/toy_test_run/02_genome_assembly/01_raw_assembly/00_assembly/toy_dataset_bug.bp.hap1.p_ctg.gfa", "/mnt/cbib/pangenoak_trials/GenomAsm4pg/tutorial_output/results/toy_dataset_bug/toy_test_run/02_genome_assembly/01_raw_assembly/00_assembly/toy_dataset_bug.bp.hap2.p_ctg.gfa"], "wildcards": {"runid": "toy_dataset_bug/toy_test_run", "id": "toy_dataset_bug"}, "params": {"prefix": "/mnt/cbib/pangenoak_trials/GenomAsm4pg/tutorial_output/results/toy_dataset_bug/toy_test_run/02_genome_assembly/01_raw_assembly/00_assembly/toy_dataset_bug"}, "log": [], "threads": 20, "resources": {"tmpdir": "/tmp", "mem_mb": 250000}, "jobid": 4, "cluster": {"job-name": "hifiasm", "time": "96:00:00", "ntasks": 1, "cpus-per-task": 20, "mem": "250G", "nodes": 1, "ntasks-per-node": 1, "output": "slurm_logs/hifiasm.%N.%j.out", "error": "slurm_logs/hifiasm.%N.%j.err", "mail-type": "END,FAIL", "mail-user": "lucien.piat@inrae.fr"}}
 cd /isilon/cbib/pangenoak_trials/GenomAsm4pg && \
/module/apps/snakemake/5.8.1/bin/python \
-m snakemake /mnt/cbib/pangenoak_trials/GenomAsm4pg/tutorial_output/results/toy_dataset_bug/toy_test_run/02_genome_assembly/01_raw_assembly/00_assembly/toy_dataset_bug.bp.hap1.p_ctg.gfa --snakefile /isilon/cbib/pangenoak_trials/GenomAsm4pg/workflow/Snakefile \
--force --cores all --keep-target-files --keep-remote --max-inventory-time 0 \
--wait-for-files /isilon/cbib/pangenoak_trials/GenomAsm4pg/.snakemake/tmp.46vxigdb /mnt/cbib/pangenoak_trials/GenomAsm4pg/lady_bug_data.fasta.gz --latency-wait 60 \
 --attempt 1 --force-use-threads --scheduler greedy \
--wrapper-prefix https://github.com/snakemake/snakemake-wrappers/raw/ \
   --allowed-rules hifiasm --nocolor --notemp --no-hooks --nolock --scheduler-solver-path /module/apps/snakemake/5.8.1/bin \
--mode 2  --use-singularity  --singularity-args "-B /mnt/cbib/pangenoak_trials/GenomAsm4pg/" --default-resources "tmpdir=system_tmpdir"  && exit 0 || exit 1

