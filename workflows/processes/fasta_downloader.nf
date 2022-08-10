process fasta_downloader {
    maxForks = "${params.fork_max}"
    label 'entrez_downloader'
    publishDir "${params.output}/fasta_files/", mode: 'copy', pattern: '*.fasta'
    errorStrategy 'retry'
    	maxRetries 5
	input:
		val(assembly_nr)
	output:
		tuple val(assembly_nr), path("*.fasta"), emit: fasta
		tuple val(assembly_nr), path("*.csv"), emit: info_csv
	script:
		"""
		bash fasta_download.sh -i ${assembly_nr} -k ${params.api_key}
		"""
}