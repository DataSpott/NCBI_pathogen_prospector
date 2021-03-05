process report_parsing {
  publishDir "${params.output}", mode: 'copy'
  
  input:
    path(dir)
  output:
    path("*.csv")
  script:
    """
    sed '/^,*\$/d' ${dir} > report.csv
    """
}