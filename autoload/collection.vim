"==============================================================================
"------------------------------------------------------------------------------
"                                       READ FILETYPE SETTINGS FROM CONFIG FILE 
"==============================================================================
" On open look for an additional config file that allows project specific
" configurations.
"_____________________________________________________________________________

function! Find_file(lookFor)
	let path_maker = '%:p:h'
	try
		while len(expand(path_maker)) > len(expand('~'))
			if filereadable((expand(path_maker)).'/'.a:lookFor)
				return expand(path_maker).'/'.a:lookFor
			endif
			let path_maker = path_maker.':h'
		endwhile
		return ''
	catch error
		echo error
		return ''
	endtry
endfunction

function! collection#get_settings(additional_config_file)
	try
		let config_file = Find_file(a:additional_config_file)
		if config_file == '' | return | endif
		execute('source '.config_file)
	catch error
		echo error
	endtry
endfunction


"==============================================================================
"------------------------------------------------------------------------------
"                                                                 LOAD SNIPPETS
"==============================================================================
"------------------------------- load the snippets for pasting with key binding

function! collection#load_snippets()
	let text = globpath(',', g:config_path . '/snippets/*')
	for i in split(text, '\n')
		let i = split(i, '/')[-1]
		if Valid_snippet(i)
			let x = g:snips[i][0]
			if matchstr(x, "Key binding: ") != ''
				let x = split(x, "Key binding: ")[0]
			else
				let x = split(x, "Key binding:")[0]
			endif
			let cmd = "nnoremap  " . x . " :call Paste_snippet('".i."')<CR>"
			silent! execute(cmd)
		endif
	endfor
endfunction

