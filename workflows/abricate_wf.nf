include { abricate } from './processes/abricate.nf'

workflow abricate_wf {
    take: 
        fasta_input //tuple val(assembly_nr) path(fasta-file)
    main:
        abricate(fasta_input)
        abricate_csv_ch = abricate.out.abricate_csv_ch
        abricate_tsv_ch = abricate.out.abricate_tsv_ch
    emit:
        abricate_csv_ch
        abricate_tsv_ch
}