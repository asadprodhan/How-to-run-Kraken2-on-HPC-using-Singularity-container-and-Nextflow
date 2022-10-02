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
