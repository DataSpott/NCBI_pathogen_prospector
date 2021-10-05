# NCBI_pathogen_prospector

## What is NCBI_pathogen_prospector?

The NCBI_pathogen_prospector is an tool for the automated download and subsequent analysis of fasta-files from NCBI pathogen using the assembly accession-numbers. The analysing-steps include ABRicate (https://github.com/tseemann/abricate) and a filtering for carbapenemases-genes. 
As separate function included is the automated download of MIC-data from NCBI biosample via the biosample accession-numbers.

## Dependencies

NCBI_pathogen_prospector requires the following programs on your system to run:
* nextflow

## Installation

* install *nextflow* to your system (https://www.nextflow.io/)
* clone this git-repository to your computer using the command:
```bash
git clone https://github.com/DataSpott/NCBI_pathogen_prospector.git
```

## Usage

* use the following command to show the help-message:
```bash
path/to/NCBI_pathogen_prospector/main.nf --help
```
* create a list of assembly accenssion-numbers & save it to a file (no header, one number per line)
* hand the list-file to the *assembly_nrs*-flag:
```bash
path/to/NCBI_pathogen_prospector/main.nf --assembly_nrs path/to/assmebly_nr_list.file
```

* due to limitations in the download-rate from NCBI the maximum amount of processes at the same time is limited to two for the fasta-download-process.
* If you posses an NCBI API-key you can use the *api_key*-flag to increase the amount of simultaneous fasta-downloads to 5:
```bash
path/to7NCBI_pathogen_prospector/main.nf --assembly_nrs path/to/assmebly_nr_list.file --api_key "your_api_key"
```
