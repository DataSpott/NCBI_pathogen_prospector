declare -a ARRAY=$(echo ${DATA})
echo "Assembly,Res_genes" > resistance_genes_summary.csv

for FILENAME in "${ARRAY[@]}"; do
    SIMPLE_NAME=$(basename "${FILENAME}" | sed "s/.tsv//")
    DATA=$(cat ${FILENAME} | cut -f 6 | sort | uniq | grep -v "GENE" | tr "\n" ";" | sed "s/;$//")
    echo "${SIMPLE_NAME}"",""${DATA}" >> resistance_genes_summary.csv
done


#Filter for Carbapenemases-genes:

in_file=$(tail -n +2 resistance_genes_summary.csv)
CARB_GENES=$(cat ${CARB_GENES_FILE})
declare -a CARB_GENE_ARRAY="${CARB_GENES}"
echo "Assembly,found carbapenemase-genes" > carbapenemase_filtered_report.csv

while read LINE; do
    FOUND_CARBS_ARRAY=()
    ISOLATE=$(echo ${LINE} | cut -f 1 -d ",")
    for IDX in "${!CARB_GENE_ARRAY[@]}"; do
        if grep -q "${CARB_GENE_ARRAY[$IDX]}"; then 
            FOUND_CARBS_ARRAY+=("${CARB_GENE_ARRAY[$IDX]}")
        fi <<< $(echo ${LINE}) #needs to be given as process substitution, because otherwise the process would run in a subshell & it´s results wouldn´t be transferred to the main process -> array wouldn´t get filled
    done
    RESULT_ARRAY=$(echo "${FOUND_CARBS_ARRAY[@]}" | tr " " ";" | tr -d "(" | tr -d ")")
    echo ${RESULT_ARRAY}
    echo "${ISOLATE}"",""${RESULT_ARRAY}" >> carbapenemase_filtered_report.csv
    unset FOUND_CARBS_ARRAY
done <<< ${IN_FILE}


#Create general report-file & remove other generated files:

echo "Assembly,Res_genes,found carbapenemase-genes" > resistance_genes_report.csv

while read LINE; do
    ISOLATE=$(echo ${LINE} | cut -f 1 -d ",")
    CARB_GENES=$(cat carbapenemase_filtered_report.csv | grep "${ISOLATE}" | cut -f 2 -d ",")
    echo "${LINE}"",""${CARB_GENES}" >> resistance_genes_report.csv
done <<< ${IN_FILE}

rm resistance_genes_summary.csv carbapenemase_filtered_report.csv