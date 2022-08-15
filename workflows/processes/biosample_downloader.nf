process biosample_downloader {
    maxForks = "${params.fork_max}"
    label 'entrez_downloader'
    publishDir "${params.output}/biosample_data/", mode: 'copy'
	input:
		tuple val(biosample_nr), val(second_id)
	output:
		tuple val(biosample_nr), val(second_id), path("*.csv")
	shell:
		if ( !params.rename ) {
			output_file_name = biosample_nr
		}
		else {
			output_file_name = second_id
		}
		"""
		NCBI_API_KEY="${params.api_key}"
		export NCBI_API_KEY

		esearch -db biosample -query "${biosample_nr}" </dev/null 2>/dev/null \
			| esummary 2>/dev/null > "${output_file_name}".md
		while ! [ "${output_file_name}".md ]; do
			esearch -db biosample -query "${biosample_nr}" </dev/null 2>/dev/null \
			| esummary 2>/dev/null > "${output_file_name}".md
		done

		cat "${output_file_name}".md \
			| sed -e 's/<[^>]*>//g' \
			| grep -i Antibiogram \
			| sed 's/\\b\\s\\b/_/g' \
			| sed 's/Testing_standard/Testing_standard\\n/' \
			| sed 's/Antibiotic/\\nAntibiotic/' \
			| sed 's/&gt;/>/g' | sed 's/&lt;/</g' \
			| tail -n +2 | sed "s/^[ \\t]*//" \
			| sed "s/ \\{11\\}/&,/g" \
			| tr -d " " \
			| sed "s/^,*\\b//g;s/,/\\n/10;P;D" \
			| head -n -1 \
		> "${output_file_name}".csv

		rm "${output_file_name}".md
		"""
}