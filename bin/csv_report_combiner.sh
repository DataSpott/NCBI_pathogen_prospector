#!/bin/bash

SCRIPTNAME=$(basename -- "$0")


###############
##  Modules  ##
###############

usage()
  {
    echo "Parser script to insert location & phenotype data from the isolates tsv-file to NCBI-prospector report.csv."
    echo " "
    echo "Usage:    ${SCRIPTNAME} [-i Input isolates tsv-file] [-r Input report csv-file]  [-h help]"
    echo "Inputs:"
    echo -e "          [-i]    Input isolates csv-file"
    echo -e "          [-r]    Input report csv-file"
    echo -e "          [-h]    Show help"
    exit;
  }

header_parser() {
    REPORT_HEADER_ONE=$(head -n 1 "${REPORT_FILE}" | cut -f 1-5 -d ",")
    REPORT_HEADER_TWO=$(head -n 1 "${REPORT_FILE}" | cut -f 6-9 -d ",")
    REPORT_HEADER_THREE=$(head -n 1 "${REPORT_FILE}" | cut -f 10- -d ",")
    ISOLATE_HEADER_LOCATION=$(head -n 1 "${ISOLATE_FILE}" | cut -f 7 -d$'\t' | tr -d ",")
    ISOLATE_HEADER_PHENOTYPE=$(head -n 1 "${ISOLATE_FILE}" | cut -f 2 -d$'\t' | tr -d ",")
    echo "${REPORT_HEADER_ONE},${ISOLATE_HEADER_LOCATION},${REPORT_HEADER_TWO},${ISOLATE_HEADER_PHENOTYPE},${REPORT_HEADER_THREE}" > general_report.csv
}

grep_combiner() {
    while read LINE; do
        ASSEMBLY_NR=$(echo "${LINE}" | cut -f 1 -d ",")
        REPORT_LINE_ONE=$(echo "${LINE}" | cut -f 1-5 -d ",")
        REPORT_LINE_TWO=$(echo "${LINE}" | cut -f 6-9 -d ",")
        REPORT_LINE_THREE=$(echo "${LINE}" | cut -f 10- -d ",")
        ISOLATE_LINE_LOCATION=$(grep "${ASSEMBLY_NR}" "${ISOLATE_FILE}" | cut -f 7 -d$'\t' | tr -d ",")
        ISOLATE_LINE_PHENOTYPE=$(grep "${ASSEMBLY_NR}" "${ISOLATE_FILE}" | cut -f 2 -d$'\t' | tr -d ",")
        echo "${REPORT_LINE_ONE},${ISOLATE_LINE_LOCATION},${REPORT_LINE_TWO},${ISOLATE_LINE_PHENOTYPE},${REPORT_LINE_THREE}" >> general_report.csv
    done <<< $(tail -n +2 "${REPORT_FILE}")
}


#############################
###   Start of script    ####
#############################

if [[ $# -eq 0 ]]; then
    usage
    exit 0
fi

while getopts 'i:r:h' flag; do
    case "${flag}" in
      i) ISOLATE_FILE="${OPTARG}" ;;
      r) REPORT_FILE="${OPTARG}" ;;
      h) usage;;
      *) usage
         exit 1 ;;
    esac
done

header_parser; grep_combiner
