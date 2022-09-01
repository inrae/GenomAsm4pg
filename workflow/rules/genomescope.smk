### kmer stats

rule genomescope:
    input:
        rules.jellyfish.output.histo
    output:
        directory("{resdir}/{id}/{run}/{stepdir}/{tooldir}/genomescope"),
        "{resdir}/{id}/{run}/{stepdir}/{tooldir}/genomescope/linear_plot.png"
    params:
        ploidy = config["ploidy"]
    priority: 1
    threads: 4
    envmodules:
        "genomescope/1.0.0"
    container:
        "docker://abner12/genomescope:2.0"
    shell:
        "genomescope.R -k 21 -i {input} -o {output[0]} -p {params.ploidy}"
        # "genomescope -k 21 -i {input} -o {output[0]}"