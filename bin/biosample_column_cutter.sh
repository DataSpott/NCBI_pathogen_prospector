#!/bin/bash
#Info: Cuts the column with accession-nrs from a given .xls/.csv/.tsv-file & removes the header.

COUNTER=1
for COLUMN_NAME in $(head file -n 1); do
    if [ "$COLUMN_NAME" == "BioSample" ] ; then
        break ;
    else
        counter=$(($COUNTER+1))
    fi
done <<< $(cat $IN_FILE)                        #export "IN_FILE" in process-script
cut -f "$COUNTER" "$IN_FILE" > biosample_list.csv