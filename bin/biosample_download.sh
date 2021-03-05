#!/usr/bin/env bash

SCRIPTNAME=$(basename -- "$0")


###############
##  Modules  ##
###############

usage()
  {
    echo "Downloader for MIC-information from NCBI-Biosample."
    echo " "
    echo "Usage:    $SCRIPTNAME [-i biosample_nr ] [-k ncbi_api_key] [-h help]"
    echo "Inputs:"
    echo -e "          [-i]    Biosample_Nr of the isolate"
    echo -e "          [-k]    NCBI API-key"
    echo -e "          [-h]    Help"
    exit;
  }

biosample_download() {
    esearch -db biosample -query "${BIOSAMPLE_NR}" </dev/null 2>/dev/null \
    | esummary 2>/dev/null >"${BIOSAMPLE_NR}".md
    while ! [ "${BIOSAMPLE_NR}".md ]; do
        esearch -db biosample -query "${BIOSAMPLE_NR}" </dev/null 2>/dev/null \
        | esummary 2>/dev/null >"${BIOSAMPLE_NR}".md
    done
}

biosample_csv_parser() {
    cat "${BIOSAMPLE_NR}".md | sed -e 's/<[^>]*>//g' | grep -i Antibiogram \
    | sed 's/\b\s\b/_/g' | sed 's/Testing_standard/Testing_standard\n/' \
    | sed 's/Antibiotic/\nAntibiotic/' | sed 's/&gt;/>/g' | sed 's/&lt;/</g' \
    | tail -n +2 | sed "s/^[ \t]*//" | sed "s/ \{11\}/&,/g" | tr -d " " \
    | sed "s/^,*\b//g;s/,/\n/10;P;D" | head -n -1 > "${BIOSAMPLE_NR}".csv

    rm "${BIOSAMPLE_NR}".md
}


#############################
###   Start of script    ####
#############################

if [[ $# -eq 0 ]]; then
    usage
    exit 0
fi

while getopts 'i:k:h' flag; do
    case "${flag}" in
      i) BIOSAMPLE_NR="${OPTARG}" ;;
      k) NCBI_API_KEY="${OPTARG}" ;;
      h) usage;;
      *) usage
         exit 1 ;;
    esac
done

export NCBI_API_KEY

biosample_download; biosample_csv_parser