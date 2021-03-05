process biosample_downloader {
    maxForks = "${params.fork_max}"
    label 'entrez_downloader'
    publishDir "${params.output}/biosample_data/", mode: 'copy'
    
  input:
    val(name)
  output:
    tuple val(name), path("*.csv")
  shell:
    """
    bash biosample_download.sh -i "${name}" -k "${params.api_key}"
    """
}