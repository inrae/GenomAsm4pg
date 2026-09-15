#!/bin/bash
# Stands in for `mitofinder` when MitoHiFi calls it: same arguments plus `-t arwen`.
# MitoFinder's default tRNA search (mitfi) takes about 1 h per 300 kb of contig, arwen a minute
/opt/wrappers/mitofinder "$@" -t arwen
rc=$?

prev=""
for a in "$@"; do [[ "$prev" == "-j" ]] && JOB="$a"; prev="$a"; done
if [[ -n "${JOB:-}" && -d "$JOB/${JOB}_MitoFinder_arwen_Final_Results" ]]; then
    ln -sfn "${JOB}_MitoFinder_arwen_Final_Results" "$JOB/${JOB}_MitoFinder_mitfi_Final_Results"
fi
exit $rc
