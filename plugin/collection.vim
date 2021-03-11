if exists('g:loaded_collection') | finish | endif

if !exists('g:collection_toggle_terminal')
	let g:collection_toggle_terminal='<F4>'
endif
if !exists('g:collection_terminal_size')
	let g:collection_terminal_size=50
endif
if !exists('g:collection_terminal_type')
	let g:collection_terminal_type=0
endif
if !exists('g:collection_toggle_errorlist')
	let g:collection_toggle_errorlist='<S-E>'
endif
if !exists('g:collection_errorlist_size')
	let g:collection_errorlist_size=50
endif
if !exists('g:collection_errorlist_type')
	let g:collection_errorlist_type=0
endif
if !exists('g:collection_run_program')
	let g:collection_run_program='R'
endif
if !exists('g:collection_format_ignore')
	let g:collection_format_ignore='text,netrw,markdown'
endif
if !exists('g:collection_format_save')
	let g:collection_format_save=1
endif
if !exists('g:collection_format_file')
	let g:collection_format_file='<Space>f'
endif

"-------------------------------------------------------------------- terminal
augroup Terminal
	execute 'nnoremap <silent>'.g:collection_toggle_terminal.'
				\ <cmd>lua require"collection".
				\toggleTerminal()<CR>'
	execute 'tnoremap <silent>'.g:collection_toggle_terminal.'
				\ <C-\><C-n><cmd>lua require"collection".
				\toggleTerminal()<CR>'
augroup END

"------------------------------------------------------------- running program
augroup Program
	call collection#filetypes_settings()
	execute 'nnoremap <silent>'.g:collection_toggle_errorlist.' 
				\<cmd>lua require"collection".toggleErrorlist()<CR>'
	execute 'command! -nargs=* '.g:collection_run_program.'
				\ lua require"collection"
				\.runProgram(<q-args>)'
augroup END

augroup Format
	execute 'noremap <silent>'.g:collection_format_file.' <cmd>lua require"collection"
				\.format()<CR>'
augroup END

let g:loaded_collection = 1
