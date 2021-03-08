#!/usr/bin/env bash

SCRIPTNAME=$(basename -- "$0")


###############
##  Modules  ##
###############

usage()
  {
    echo "Summary-parser for Abricate result-files."
    echo " "
    echo "Usage:    $SCRIPTNAME [-i Carbapenemase-genes txt-file] [-h help]"
    echo "Inputs:"
    echo -e "          [-i]    txt-file with carbapenemase-genes"
    echo -e "          [-h]    Help"
    exit;
  }

res_gene_summariser() {
    declare -a CARB_GENE_ARRAY=$(cat "${CARB_GENES_FILE}")

    for FILENAME in "${PWD}"/*.tsv; do
        SIMPLE_NAME=$(basename "${FILENAME}" | sed "s/.tsv//")
        DATA=$(cat "${FILENAME}" | cut -f 6 | sort | uniq | grep -v "GENE" | tr "\n" ";" | sed "s/;$//")
        FOUND_CARBS_ARRAY=()
        for IDX in "${!CARB_GENE_ARRAY[@]}"; do
            if grep -q "${CARB_GENE_ARRAY[${IDX}]}"; then 
                FOUND_CARBS_ARRAY+=("${CARB_GENE_ARRAY[${IDX}]}")
            fi <<< $(echo "${DATA}")
        done <<< $("${CARB_GENE_ARRAY[@]}") #needs to be given as process substitution, because otherwise the process would run in a subshell & it´s results wouldn´t be transferred to the main process -> array wouldn´t get filled
        RESULT_ARRAY=$(echo "${FOUND_CARBS_ARRAY[@]}" | tr " " ";" | tr -d "(" | tr -d ")")
        echo "Assembly,Res_genes,found carbapenemase-genes" > "${SIMPLE_NAME}"_resistance_genes.csv
        echo "${SIMPLE_NAME},${DATA},${RESULT_ARRAY}" >> "${SIMPLE_NAME}"_resistance_genes.csv
        unset FOUND_CARBS_ARRAY
    done
}


#############################
###   Start of script    ####
#############################

if [[ $# -eq 0 ]]; then
    usage
    exit 0
fi

while getopts 'i:h' flag; do
    case "${flag}" in
      i) CARB_GENES_FILE="${OPTARG}" ;;
      h) usage;;
      *) usage
         exit 1 ;;
    esac
done

res_gene_summariser