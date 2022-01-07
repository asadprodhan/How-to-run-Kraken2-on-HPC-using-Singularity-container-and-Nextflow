#!/usr/bin/env nextflow

//data_location

params.in = "$PWD/*.fasta"
params.outdir = './results'
datasets = Channel
                .fromPath(params.in)
                .map { file -> tuple(file.simpleName, file) }


// taxonomy

process taxonomy {
    tag "$z"
    publishDir "${params.outdir}", mode:'copy'

    input:
    set datasetID, file(z) from datasets

    output:
    file "${z.baseName}_taxo.tsv" into taxonomy_ch
        
    script:
    """
    kraken2 --db path/to/the/DB --output ${z.baseName}_taxo.out --report ${z.baseName}_taxo.tsv $z --threads 28
    
    """
}

