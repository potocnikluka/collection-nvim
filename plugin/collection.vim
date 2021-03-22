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

let g:configPath = stdpath('config')
let g:termwin = 0
let g:termbuf = 0
let g:progwin = 0
let g:progbuf = 0
call collection#filetypes_settings()
let g:snipInfo = {'buf': 0, 'win': 0, 'border_buf': 0, 'border_win': 0}
augroup Snippets
	autocmd BufEnter * if exists('g:snipWin') && exists('g:snipBordBuf') &&
				\ bufnr("") == g:snipBordBuf |
				\ if !win_gotoid(g:snipWin) |
				\ silent! execute("bwipeout! " . g:snipBordBuf) |
				\ else | wincmd p | wincmd w | endif | endif
augroup END
let g:loaded_collection = 1
