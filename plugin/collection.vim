if exists('g:loaded_collection') | finish | endif
"----------------------------------------------------------- Terminal variables
if !exists('g:collection_terminal_size')
	let g:collection_terminal_size=50
endif
if !exists('g:collection_terminal_type')
	let g:collection_terminal_type=0
endif
"---------------------------------------------------- Running-program variables
if !exists('g:collection_errorlist_size')
	let g:collection_errorlist_size=50
endif
if !exists('g:collection_errorlist_type')
	let g:collection_errorlist_type=0
endif
if !exists('g:collection_run_ignore')
	let g:collection_run_ignore='netrw,markdown,text,vim'
endif
if !exists('g:collection_errorlist_save')
	let g:collection_errorlist_save=1
endif
"---------------------------------------------------------- Formating variables
if !exists('g:collection_format_ignore')
	let g:collection_format_ignore='text,netrw,markdown'
endif
if !exists('g:collection_format_save')
	let g:collection_format_save=1
endif
"----------------------------------------------------------- snippets variables
if !exists('g:collection_load_snippets')
	let g:collection_load_snippets=0
	"1 -> load snippets on start, 0 -> don't load
	"If snippets are not loaded they can be pasted only from 'call Snippets()'
	"command and not with a key binding.
	"They can be manually loaded with 'call Snippets('load')'
endif
"------------------------------------------------------- additional config file
if !exists('g:collection_additional_config')
	let g:collection_additional_config=1
	"1 -> look for additional config file, 0-> don't
endif
if !exists('g:collection_config_file')
	let g:collection_config_file='.config.vim'
	"default name of a file for project-specific settings
endif

let g:config_path = stdpath('config')

"---------------------------------load project specific config from .config.vim
if g:collection_additional_config
	call collection#get_settings(g:collection_config_file)
endif
"------------------------------- load snippets to be availible with keybindings
let g:snippets_loaded = 1
if g:collection_load_snippets
	call Snippets('load')
	let g:snippets_loaded = 1
endif

let g:loaded_collection = 1
