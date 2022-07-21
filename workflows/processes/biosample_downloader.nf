process biosample_downloader {
    //maxForks = "${params.fork_max}"
    label 'entrez_downloader'
    publishDir "${params.output}/biosample_data/", mode: 'copy'
	input:
		val(biosample_nr)
	output:
		tuple val(biosample_nr), path("*.csv")
	shell:
		"""
		bash biosample_download.sh -i "${biosample_nr}" -k "${params.api_key}"
		"""
}