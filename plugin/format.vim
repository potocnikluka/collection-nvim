"==============================================================================
"------------------------------------------------------------------------------
"                                                                        FORMAT
"==============================================================================
"______________________________________________________________ format the file

function! Format()
	if !Check_format_options() | return | endif
	if g:collection_format_save | silent! w | endif
	silent! normal mz
	let formater = ''
	if !exists('g:collection_' . &filetype . '_formater')
		echo "No formater specified, using default indenting."
		silent! normal gg=Gg'z
		if g:collection_format_save | silent! w | endif
		return
	else
		execute('let formater = g:collection_' . &filetype . '_formater')
	endif
	let name = split(formater, ' ')[0]
	if !executable(name)
		echo "Cannot execute " . name . ", using default indenting."
		silent! normal gg=Gg'z
		if g:collection_format_save | silent! w | endif
		return
	endif
	let formater = join(split(formater, ' '), '\ ')
	try
		execute('set equalprg=' . formater)
		silent normal G=gg
		set equalprg=""
		if stridx(getline('.'), 'error') != -1 ||
					\stridx(getline('.'), '/bin/bash') != -1
			let er = getline('.')
			silent! undo
			echo er
		else
			echo "Formated with " . name
		endif
	catch er
		try
			echo er
			set equalprg=""
			silent normal G=gg
			echo 'Could not format with ' . name . ', using default indenting.'
		catch error
			echo error
		endtry
	endtry
	silent! normal g'z
	if g:collection_format_save | silent! w | endif
endfunction

"------------------------------------------------------- check if valid options
function! Check_format_options()
	if matchstr(g:collection_format_ignore, &filetype) != ''
		echo 'Cannot format this filetype'
		return 0
	endif
	if g:collection_format_save != 1 && g:collection_format_ignore != 0
		echo 'Invalid g:collection_format_save value'
		return 0
	endif
	return 1
endfunction
