function! FindFile(lookFor)
	let pathMaker = '%:p:h'
	while len(expand(pathMaker)) > 1
		if filereadable((expand(pathMaker)).'/'.a:lookFor)
			return expand(pathMaker).'/'.a:lookFor
		endif
		let pathMaker = pathMaker.':h'
	endwhile
	return ''
endfunction

function! collection#filetypes_settings(file) abort
	try
		let config_file = FindFile(a:file)
		if config_file == '' | return | endif
		execute('source '.config_file)
	catch error
		echo error
	endtry
endfunction
