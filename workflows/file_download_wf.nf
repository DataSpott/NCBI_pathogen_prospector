include { biosample_downloader } from './processes/biosample_downloader.nf'
include { fasta_downloader } from './processes/fasta_downloader.nf'

workflow biosample_download_wf {
    take: 
        biosample_nrs_input //val(biosample_nr)
    main:
        biosample_downloader(biosample_nrs_input)
        biosample_result = biosample_downloader.out
    emit:
        biosample_result //tuple val(biosample_nr), path(csv-file)
}

workflow fasta_download_wf {
    take: 
        assembly_nrs_input //val(assembly_nr)
    main:
        fasta_downloader(assembly_nrs_input)
        fasta_ch = fasta_downloader.out.fasta
        info_csv_ch = fasta_downloader.out.info_csv
    emit:
        fasta_ch //tuple val(assembly_nr), path(fasta-file)
        info_csv_ch //tuple val(assembly_nr), path(csv-file)
}