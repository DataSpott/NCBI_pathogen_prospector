include { isolate_info_summariser } from './processes/isolate_info_summariser.nf'
include { report_parsing } from './processes/report_parsing.nf'

workflow isolate_info_summary_wf {
    take: 
        data //val(data)
    main:
        isolate_info_summariser(data)
        info_summary_ch = isolate_info_summariser.out
    emit:
        info_summary_ch //path(csv-file)
}

workflow report_parsing_wf {
    take: 
        dir //path(dir)
    main:
        report_parsing(dir)
        report_ch = report_parsing.out
    emit:
        report_ch //path(csv-file)
}