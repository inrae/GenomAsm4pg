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
    container:
        "docker://registry.forgemia.inra.fr/asm4pg/genomasm4pg/genomescope2.0"
    shell:
        "genomescope.R -k 21 -i {input} -o {output[0]} -p {params.ploidy}"