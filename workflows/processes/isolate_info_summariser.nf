process isolate_info_summariser {
	input:
		val(data)
	output:
		path("*.csv")
	script:
    	"""
    	bash isolate_info_combiner.sh -i "${data}"
    	"""
}