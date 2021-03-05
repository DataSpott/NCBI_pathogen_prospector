cat isolates_biosample_test.csv | while read -r acc ; do
    #echo "Strain, Organism, Genbank_Acc_Nr, Refseq_Acc_Nr, Bioproject_Acc_Nr, Submitter_Org, Genbank_Release_Date, synonymous IDs, Genbank_Ftp_URL" > $acc.csv
    esearch -db biosample -query $acc </dev/null \
        | esummary | bash biosample_csv_parser.sh > "$acc"_test_output.csv
done
