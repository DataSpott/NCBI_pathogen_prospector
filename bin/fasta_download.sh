#!/usr/bin/env bash

SCRIPTNAME=$(basename -- "$0")


###############
##  Modules  ##
###############

usage()
  {
    echo "Downloader for NCBI-fastas from NCBI-Assembly."
    echo " "
    echo "Usage:    $SCRIPTNAME [-i assembly_nr ] [-k ncbi_api_key] [-h help]"
    echo "Inputs:"
    echo -e "          [-i]    Assembly_Nr of the isolate"
    echo -e "          [-k]    NCBI API-key"
    echo -e "          [-h]    Help"
    exit;
  }

fasta_download() {
  echo "Assembly|Refseq_Acc_Nr|Bioproject_Acc_Nr|Organism|Strain|Submitter_Org|Genbank_Release_Date|synonymous_IDs|Genbank_Ftp_URL" > "${ASSEMBLY_NR}".csv
  esearch -db assembly -query "${ASSEMBLY_NR}" </dev/null 2>/dev/null \
    | esummary 2>/dev/null \
    | xtract -pattern DocumentSummary -sep " " -tab "|" -def "not found" -element Genbank RefSeq BioprojectAccn Organism Sub_value SubmitterOrganization AsmReleaseDate_GenBank Synonym FtpPath_GenBank >> "${ASSEMBLY_NR}".csv
  URL=$(grep -o "ftp:[^ ]*" *.csv)
  FNAME=$(echo "${URL}" | grep -o 'GCA_.*' | sed 's/$/_genomic.fna.gz/')
  wget "${URL}/${FNAME}" 2>/dev/null
  zcat *.gz > "${ASSEMBLY_NR}".fasta
  while ! [ "${ASSEMBLY_NR}".fasta ]; do
    esearch -db assembly -query "${ASSEMBLY_NR}" </dev/null 2>/dev/null \
      | esummary 2>/dev/null \
      | xtract -pattern DocumentSummary -sep " " -tab "|" -def "not found" -element Genbank RefSeq BioprojectAccn Organism Sub_value SubmitterOrganization AsmReleaseDate_GenBank Synonym FtpPath_GenBank >> "${ASSEMBLY_NR}".csv
    URL=$(grep -o "ftp:[^ ]*" *.csv)
    FNAME=$(echo "${URL}" | grep -o 'GCA_.*' | sed 's/$/_genomic.fna.gz/')
    wget "${URL}/${FNAME}" 2>/dev/null
    zcat *.gz > "${ASSEMBLY_NR}".fasta
    sleep 1
  done
}

csv_parser() {
  for FILENAME in "$PWD"/*.csv; do
    sed -i "s/,/_/g" "${FILENAME}"
    sed -i "s/|/,/g" "${FILENAME}"
  done
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
      i) ASSEMBLY_NR="${OPTARG}" ;;
      k) NCBI_API_KEY="${OPTARG}" ;;
      h) usage;;
      *) usage
         exit 1 ;;
    esac
done

export NCBI_API_KEY

fasta_download; csv_parser