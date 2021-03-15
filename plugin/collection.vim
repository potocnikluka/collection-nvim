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
"-------------------------------------------------------------------- terminal
let g:termwin = 0
let g:termbuf = 0
augroup Terminal
	command! CTerminal call Collection("togTerm")
augroup END
"------------------------------------------------------------- running program
let g:progwin = 0
let g:progbuf = 0
augroup Program
	call collection#filetypes_settings()
	command! Errorlist call Collection("togErlist")
	command! -nargs=* CRun call Collection("runProg", <q-args>)
augroup END
"-------------------------------------------------------------------- formating
augroup Format
	command! CFormat call Collection("format")
augroup END

augroup Snippets
	command! -nargs=* Snippets call Collection("snippets", <q-args>)
	nnoremap <Space>q :Snippets<CR>
augroup END

function! Collection(type, ...)
	"reload package
	lua for k in pairs(package.loaded) do
				\ if k:match("collection") then
				\ package.loaded[k] = nil end end
	"optional argument
	let t:arg = ''
	if a:0 > 0
		let t:arg = a:1
	endif
	if a:type == 'runProg'
		lua require'collection'.runProgram(vim.t.arg)
	elseif a:type == 'togErlist'
		lua require'collection'.toggleErrorlist()
	elseif a:type == 'togTerm'
		lua require'collection'.toggleTerminal()
	elseif a:type == 'format'
		lua require'collection'.format()
	elseif a:type == 'snippets'
		lua require'collection'.showSnippets(vim.t.arg)
	endif
endfunction
let g:loaded_collection = 1
