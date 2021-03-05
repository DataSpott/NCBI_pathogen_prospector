export NCBI_API_KEY=9032af6194e7b92eab44dab40580485c6508
cat assm_accs.txt | while read -r acc; do
    printf $acc
    url=$(esearch -db assembly -query $acc </dev/null \
        | esummary \
        | xtract -pattern DocumentSummary -element FtpPath_GenBank)
    echo $url > url.txt
    fname=$(echo $url | grep -o 'GCA_.*' | sed 's/$/_genomic.fna.gz/')
    wget "$url/$fname"
    zcat ./*.gz > $acc.fasta
done