#!/bin/bash -l 
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


