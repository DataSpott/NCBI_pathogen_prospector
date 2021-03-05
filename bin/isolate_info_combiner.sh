#!/usr/bin/env bash

SCRIPTNAME=$(basename -- "$0")


###############
##  Modules  ##
###############

usage()
  {
    echo "Combiner for isolate-information csv-files."
    echo " "
    echo "Usage:    $SCRIPTNAME [-i collected csv-files ] [-h help]"
    echo "Inputs:"
    echo -e "          [-i]    csv-file-paths from collection channel"
    echo -e "          [-h]    Help"
    exit;
  }

csv_parser() {
  declare -a ARRAY=$(echo "${DATA}"| tr "[" "(" | tr "]" ")" | tr -d "," | tr -d "'")
  GENERAL_HEADER=$(head -n 1 "${ARRAY[1]}")
  GENERAL_INFO=$(tail -n +2 "${ARRAY[1]}")
  GENE_INFO_HEADER=$(head -n 1 "${ARRAY[2]}" | cut -f 2,3 -d ",")
  GENE_INFO=$(tail -n +2 "${ARRAY[2]}" | cut -f 2,3 -d ",")
  echo "${GENERAL_HEADER},${GENE_INFO_HEADER}" > "${ARRAY[0]}".csv
  echo "${GENERAL_INFO},${GENE_INFO}" >> "${ARRAY[0]}".csv
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
      i) DATA="${OPTARG}" ;;
      h) usage;;
      *) usage
         exit 1 ;;
    esac
done

csv_parser