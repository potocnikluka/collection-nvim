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

function! collection#filetypes_settings() abort
	let jsonFile = FindFile('.vim.json')
	if jsonFile == '' | return | endif
	try
		let jsonData = readfile(expand(jsonFile))
		if len(jsonData) == 0  | return | endif
		let jsonData = json_decode(jsonData)
		for [key, value] in items(jsonData)
			for i in ['compiler', 'formater', 'interpreter', 'execute']
				if exists('g:collection_'.key.'_'.i.'')
					execute 'unlet g:collection_'.key.'_'.i.''
				endif
			endfor
			for [k, v] in items(value)
				execute 'let g:collection_'.key.'_'.k.'="'.v.'"'
			endfor
		endfor
	catch error
		echo error
	endtry
endfunction
