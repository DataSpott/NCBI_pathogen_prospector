process fasta_downloader {
    maxForks = "${params.fork_max}"
    label 'entrez_downloader'
    publishDir "${params.output}/fasta_files/", mode: 'copy', pattern: '*.fasta'
    errorStrategy 'retry'
      maxRetries 5
    
  input:
    val(name)
  output:
    tuple val(name), path("*.fasta"), emit: fasta_ch
    tuple val(name), path("*.csv"), emit: info_csv_ch 
  script:
    """
    bash fasta_download.sh -i ${name} -k ${params.api_key}
    """
}