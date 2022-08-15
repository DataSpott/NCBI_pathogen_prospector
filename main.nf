#!/usr/bin/env nextflow
nextflow.enable.dsl=2

println "\u001B[32mProfile: $workflow.profile\033[0m"
println "\033[2mCurrent User: $workflow.userName"
println "Workdir location:"
println "  $workflow.workDir"
println "CPUs to use: $params.cores"
println "Output dir: $params.output\u001B[0m"
if (params.api_key == '' ) {
    params.fork_max = 2 
    println "\033[2mNo API-Key given: setting maxForks to 2\u001B[0m"
} 
else { params.fork_max = 5 
    println "\033[2mAPI-Key given: setting maxForks to 5\u001B[0m"
}
println ""

// help
def helpMSG() {
    log.info """
    Usage:
    nextflow run main.nf --input /Accession_list-file
    --input         a (.txt/.csv/.tsv/...-) file with NCBI-Assembly & -Biosample accession-numbers
    --assembly_nrs  a (.txt/.csv/.tsv/...-) file with NCBI-Assembly accession-numbers, one accession number per line, no headers
    --biosample_nrs a (.txt/.csv/.tsv/...-) file with NCBI-Biosample accession-numbers, one accession number per line, no headers
    
    Options:
    --api_key       NCBI-API-Key
    --cores         max cores [default: $params.cores]
    --output        directory where results are stored [default: $params.output]
    """.stripIndent()
}

if ( params.help ) { exit 0, helpMSG() }

if ( params.profile ) { exit 1, "--profile is WRONG use -profile" }

if ( params.input == '' && params.assembly_nrs == '' && params.biosample_nrs == '' ) {
    exit 1, ">> A input is required, see --help <<"
}


//xxxxxxxxxxxxxx//
//***inputs***//
//xxxxxxxxxxxxx//

if ( params.input ) {println '>> Still working here :) <<'}

if ( params.assembly_nrs ) {
    assembly_nrs_ch = Channel
        .fromPath(params.assembly_nrs)
        .splitCsv()
        .unique()
        .map { it -> it[0] }
}



if ( params.biosample_nrs ) {
    biosample_nrs_file_ch = Channel.fromPath(params.biosample_nrs, checkIfExists: true)

    if ( params.no_header ) { skip_line = 0 }
    else { skip_line = 1 }

    if ( params.rename ) {
        rename_ids_exist_test = biosample_nrs_file_ch
            .splitCsv(header: ['Biosample_Nr', 'Other_Id'], skip: skip_line, sep: '\t')
            .map { column -> "${column.Other_Id}" }
            .filter { !it == null }
            .view()
        
        if ( rename_ids_exist_test == null ) { println "empty value"}
    }

    biosample_nrs_ch = biosample_nrs_file_ch
        .splitCsv(header: ['Biosample_Nr', 'Other_Id'], skip: skip_line, sep: '\t')
        .map { row -> tuple ("${row.Biosample_Nr}", "${row.Other_Id}") }
        //.view()
}

carbapenemase_gene_file_ch = Channel.fromPath( workflow.projectDir + "/data/carbapenemase_genes.txt", checkIfExists: true)


//xxxxxxxxxxxxxx//
//***Modules***//
//xxxxxxxxxxxxxx//

include { abricate_wf } from './workflows/abricate_wf.nf'
include { biosample_download_wf } from './workflows/file_download_wf.nf'
include { fasta_download_wf } from './workflows/file_download_wf.nf'
include { isolate_info_summary_wf} from './/workflows/summary_wf.nf'
include { report_parsing_wf} from './workflows/summary_wf.nf'

//xxxxxxxxxxxxxx//
//***main Workflow***//
//xxxxxxxxxxxxx//

workflow {
    if (params.input) {println ">> WIP <<"}
    
    if (params.assembly_nrs) { 
        fasta_download_wf(assembly_nrs_ch)
        abricate_wf(fasta_download_wf.out.fasta_ch.combine(carbapenemase_gene_file_ch))
        isolate_info_summary_wf(fasta_download_wf.out.info_csv_ch.join(abricate_wf.out.abricate_csv_ch))
        report_parsing_wf(isolate_info_summary_wf.out.info_summary_ch.collectFile(name: 'pre_report.csv', keepHeader: true, skip: 1 ))
        }
    
    if (params.biosample_nrs) { biosample_download_wf(biosample_nrs_ch) }
}