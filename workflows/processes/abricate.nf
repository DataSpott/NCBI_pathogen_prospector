process abricate {
    label 'abricate'
    publishDir "${params.output}/resistance_gene_data/", mode: 'copy', pattern: '*.tsv'
    errorStrategy 'retry'
    	maxRetries 5
    input:
		tuple val(name), path(dir), path(carb_gene_list)
    output:
		tuple val(name), path("*.tsv"), emit: abricate_tsv_ch
		tuple val(name), path("*.csv"), emit: abricate_csv_ch
    script:
		"""
		abricate ${dir} --nopath --quiet --mincov 80 --db ncbi >> "${name}".tsv
		abricate ${dir} --nopath --quiet --mincov 80 --db card >> "${name}".tsv
		abricate ${dir} --nopath --quiet --mincov 80 --db vfdb >> "${name}".tsv
		abricate ${dir} --nopath --quiet --mincov 80 --db ecoh >> "${name}".tsv

		bash resistance_gene_summariser.sh -i "${carb_gene_list}"
		"""
}