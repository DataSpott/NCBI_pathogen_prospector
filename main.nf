#!/usr/bin/env nextflow
nextflow.preview.dsl=2

println "\u001B[32mProfile: $workflow.profile\033[0m"
println "\033[2mCurrent User: $workflow.userName"
println "Workdir location:"
println "  $workflow.workDir"
println "CPUs to use: $params.cores"
println "Output dir: $params.output\u001B[0m"
if (params.api_key == '' ) { params.fork_max = 2 
    println "\033[2mNo API-Key given: setting maxForks to 2\u001B[0m"} 
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

if (params.help) { exit 0, helpMSG() }
if (params.input == '' && params.assembly_nrs == '' && params.biosample_nrs == '') {
    exit 1, ">> A input is required, see --help <<"}


//xxxxxxxxxxxxxx//
//***inputs***//
//xxxxxxxxxxxxx//

if (params.input) {println '>> Still working here :) <<'}

if (params.assembly_nrs) {assem_access_list = Channel
        .fromPath(params.assembly_nrs)
        .splitCsv()
        .unique()
        .map { it -> it[0] }
}

if (params.biosample_nrs) {biosam_access_list = Channel
        .fromPath(params.biosample_nrs)
        .splitCsv()
        .unique()
        .map { it -> it[0] }
}

carbapenemase_genes_file = Channel.value( workflow.projectDir + "/data/carbapenemase_genes.txt")


//xxxxxxxxxxxxxx//
//***Modules***//
//xxxxxxxxxxxxxx//

include { abricate } from './processes/abricate'
include { biosample_downloader} from './processes/biosample_downloader'
include { fasta_downloader } from './processes/fasta_downloader'
include { isolate_info_summariser} from './processes/isolate_info_summariser'
include { report_parsing} from './processes/report_parsing'

//xxxxxxxxxxxxxx//
//***main Workflow***//
//xxxxxxxxxxxxx//

workflow {
    if (params.input) {println ">> WIP <<"}
    
    if (params.assembly_nrs) { 
        fasta_downloader(assem_access_list)
        abricate(fasta_downloader.out.fasta_ch, carbapenemase_genes_file)
        isolate_info_summariser(fasta_downloader.out.info_csv_ch.join(abricate.out.abricate_csv_ch))
        report_parsing(isolate_info_summariser.out.collectFile(name: 'pre_report.csv', keepHeader: true, skip: 1 ))
        }
    
    if (params.biosample_nrs) { biosample_downloader(biosam_access_list) }
}