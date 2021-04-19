if exists('g:loaded_collection') | finish | endif

if !exists('g:collection_terminal_size')
	let g:collection_terminal_size=50
endif
if !exists('g:collection_terminal_type')
	let g:collection_terminal_type=0
endif
if !exists('g:collection_errorlist_size')
	let g:collection_errorlist_size=50
endif
if !exists('g:collection_errorlist_type')
	let g:collection_errorlist_type=0
endif
if !exists('g:collection_format_ignore')
	let g:collection_format_ignore='fileexplorer,text,netrw,markdown'
endif
if !exists('g:collection_format_save')
	let g:collection_format_save=1
endif
if !exists('g:collection_additional_config')
	let g:collection_additional_config=1
endif
if !exists('g:collection_config_file')
	let g:collection_config_file='.config.vim'
endif

let g:configPath = stdpath('config')
let g:termwin = 0
let g:termbuf = 0
let g:progwin = 0
let g:progbuf = 0
if g:collection_additional_config
	call collection#filetypes_settings(g:collection_config_file)
endif
let g:loaded_collection = 1
