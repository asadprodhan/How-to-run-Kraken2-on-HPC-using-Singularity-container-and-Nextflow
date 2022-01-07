# **How to run Kraken2 on HPC using Singularity container and Nextflow?** <br />
Kraken2 is a widely used tool in metagenomic studies. It classifies metagenomic sequences into taxonomic ranks such as Species, Genus, Family etc.


## How does it work?

Kraken2 builds a database consisting of a k-mer and all the genomes that contain this k-mer. The metagenomic sequences are broken down into k-mers, and each k-mer is queried against the Kraken2-built k-mer database to classify the metagenomic sequences. Metagenomic sequences that have no matched k-mer in the database are labelled as unclassified (Wood et al., 2019; Wood and Salzberg, 2014). 

## How to run on HPC?

Generally, the HPC providers do not allow their users to install softwares on the HPC. Singularity containers are a great alternative to physically installing softwares, and even does not require ‘sudo’ privilege. Keeping record of the used containers and their versions facilitates reproducibility of the workflow. On the other hand, Nextflow is a bioinformatics workflow manager allowing the usage of containers.

However, executing Kraken2 (or any job) on HPC using Singularity container and Nextflow requires a set of three scripts as follows:

> Job Script: a job script written in nextflow (.nf) to do the actual job

> Config Script: a config script to provide with the container’s link and computing resource allocations. By default, the name of this script is ‘nextflow.config’. If it is named differently, then it needs to be specified in the ‘nextflow run’ command in the following job scheduler script as follows: "nextflow -C XXXXXX.config run <other arguments as required>"  
  
> Job Scheduler Script: a bash script to schedule the job through the job scheduler ‘SLURM’
 The script set for running Kraken2 on HPC provided by the Pawsey Supercomputer Centre (https://pawsey.org.au/) is presented below.
  
  

