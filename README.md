# **How to run Kraken2 on HPC using Singularity container and Nextflow?** <br />
Kraken2 is a widely used tool in metagenomic studies. It classifies metagenomic sequences into taxonomic ranks such as Species, Genus, Family etc.


## How does it work?

Kraken2 builds a database consisting of a k-mer and all the genomes that contain this k-mer. The metagenomic sequences are broken down into k-mers, and each k-mer is queried against the Kraken2-built k-mer database to classify the metagenomic sequences. Metagenomic sequences that have no matched k-mer in the database are labelled as unclassified (Wood et al., 2019; Wood and Salzberg, 2014). 

## How to run Kraken2 on HPC cluster using Singularity container and Nextflow?

Generally, the HPC providers do not allow their users to install softwares on the HPC. Singularity containers are a great alternative to physically installing softwares, and even does not require ‘sudo’ privilege. Keeping record of the used containers and their versions facilitates reproducibility of the workflow. On the other hand, Nextflow is a bioinformatics workflow manager allowing the usage of containers.

However, executing Kraken2 (or any job) on HPC using Singularity container and Nextflow requires a set of three scripts as follows:

> Job Script: a job script written in nextflow (.nf) to do the actual job

> Config Script: a config script to provide with the container’s link and computing resource allocations. By default, the name of this script is ‘nextflow.config’. If it is named differently, then it needs to be specified in the ‘nextflow run’ command in the following job scheduler script as follows: "nextflow -C XXXXXX.config run <other arguments as required>"  
  
> Job Scheduler Script: a bash script to schedule the job through the job scheduler ‘SLURM’
  
  
  
 The scripts set for running Kraken2 on HPC provided by the Pawsey Supercomputer Centre (https://pawsey.org.au/) is presented below.
  
  
  #### Job Script:
  
  
  ``` #!/usr/bin/env nextflow

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
```
 
 
  #### Notes: 
  
    
  * The above database can be downloaded and built from scratch following the Kraken2 manual (https://github.com/DerrickWood/kraken2) 
  
  * Or, the available pre-built databases can be downloaded and used (https://benlangmead.github.io/aws-indexes/k2) 
  
      - create and 'cd' into a directory in your Linux computer to download the kraken2 pre-built databases in
      
	    - go to the above pre-built databases website 
      
	    - go to the HTTPS URL column of the collection table
      
	    - right click on the tar.gz file of the corresponding collection
      
	    - copy link address
      
	    - run the following command
      
      
		    ```
        wget link_address
        ```
        
        
	    - extract the tar zipped database as follows:
      
      ```
		  tar -zxvf downloaded_database
      ```
      
	    - now, you need to refer this directory as you kraken 2 database in the kraken2 script
      
  
  
  * When running Kraken2, the database needs to be in the same computer where the command will be run (for example, in Zeus or Magnus at Pawsey). Preferably, in the same directory
  
  * Full path of the database needs to be given in the kraken2 command even if the database is in the same directory
  
  
  * At least 100 GB free disk space and 50 GB RAM are required. Kraken2 loads the database in the local RAM and use it from there. Lack of sufficient disk or memory space will result in an error "Error reading the hash table"
  
  
  * "Error reading the hash table" may stem from somehow corrupted files in the database. This might happen during transferring the unzipped database across computers. This problem can be resolved by re-extracting the zipped file of the downloaded Kraken2 database

<br />
  
  #### Config Script:
  
  
  ``` resume = true
trace {
  fields = 'name,hash,status,exit,realtime,submit'
}
profiles {
zeus {
  workDir = "$PWD/work"
  process {
    cache = 'lenient'
    stageInMode = 'symlink'
  }

process {
        withName:taxonomy { container = 'quay.io/biocontainers/kraken2:2.1.2--pl5262h7d875b9_0' }
    }

singularity {
 enabled = true
 autoMounts = true
 //runOptions = '-e TERM=xterm-256color'
 envWhitelist = 'TERM'
}
params.slurm_account = 'XXXXX'
  process {
    executor = 'slurm'
    clusterOptions = "--account=${params.slurm_account}"
    queue = 'workq'
    cpus = 1
    time = '1h'
    memory = '10GB'
        
    withName: 'taxonomy' {
      cpus = 28
      time = '24h'
    }     
}
}
}
```
  
  
  
  #### Job Scheduler Script:
  
  
 ``` #!/bin/bash -l 
#SBATCH --job-name=nxf-master 
#SBATCH --account=XXXX 
#SBATCH --partition=workq 
#SBATCH --time=1-00:00:00
#SBATCH --no-requeue 
#SBATCH --export=none 
#SBATCH --nodes=1

unset SBATCH_EXPORT 

module load singularity 
module load nextflow 

nextflow run nanopore_nextflow.nf -profile zeus -name nxf-${SLURM_JOB_ID} -resume --with-report
  ```


## How to run Kraken2 on a local Linux computer?

*	Install Kraken2 

*	Add the Kraken2 path to the PATH environmental variable

*	Download the appropriate Kraken2 database. To download the database, see the above notes

*	Make a directory for Kraken2 analysis

*	Keep the sequencing reads, the database, and the following script in the ‘Kraken2’ directory

*	Make a ‘results’ directory with in the ‘Kraken2’ directory to collect the results

*	Run the script as follows: 

```
./kraken2.sh
```


#### The 'kraken2.sh' Script:


```
#!/usr/bin/env bash

#textFormating
Red="$(tput setaf 1)"
Green="$(tput setaf 2)"
reset=`tput sgr0` # turns off all atribute
Bold=$(tput bold)
#
for F in *.fastq
do

    baseName=$(basename $F .fastq)
    echo "${Red}${Bold} Processing ${reset}: "${baseName}""
    kraken2 --db $PWD/kraken2_database --threads 64 --output $PWD/results/"${baseName}_taxo.out" --report $PWD/results/"${baseName}_taxo.tsv" $F 
    echo ""
    echo "${Green}${Bold} Processed and saved as${reset} "${baseName}""
done

```

  
## Output
  
  kraken2 output file is tab delimited. A hypothetical example: 
  
  
  ``` 
  
  75	250	160	S	211044		Influenza A virus
  
  ```
  
  
  #### The columns from left-to-right are as follows:
  
  
* Column 1: Percentage of reads covered by the clade rooted at this taxon
  
* Column 2: Number of reads covered by the clade rooted at this taxon
  
* Column 3: Number of reads assigned directly to this taxon
  
* Column 4: A rank code, indicating (U)nclassified, (D)omain, (K)ingdom, (P)hylum, (C)lass, (O)rder, (F)amily, (G)enus, or (S)pecies. All other ranks are simply “-“.
  
* Column 5: NCBI Taxonomy ID
  
* Column 6: The scientific name

   
  <br />

  
  
### References
  
  Wood, D.E., Lu, J., Langmead, B., 2019. Improved metagenomic analysis with Kraken 2. Genome Biol. 20, 257. https://doi.org/10.1186/s13059-019-1891-0
  
  Wood, D.E., Salzberg, S.L., 2014. Kraken: ultrafast metagenomic sequence classification using exact alignments. Genome Biol. 15, R46. https://doi.org/10.1186/gb-2014-15-3-r46

  

