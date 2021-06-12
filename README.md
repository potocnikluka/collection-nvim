# Collection-nvim

A simple plugin, focusing mainly on utilising some of Neovim's best features, such as 
asynchronous job control.

## Prerequisites
* neovim v0.5

## Configuration

Install with your favourite package manager.

* Intallation with [vim-plug](https://github.com/junegunn/vim-plug):
```
	Plug 'potocnikluka/collection-nvim'
```
See `:h collection-nvim` for details on configurations, 
or read [collection-nvim-help](doc/collection-nvim.txt).

## Features 

* Snippets managing.
* Asynchronous program running.
* Code formatting.
* Setting up filetype-specific interpreters, compilers, formaters,...
* Adding options to `.config.vim`, 
which allows different configurations for different projects.

## example init.vim config

```
let g:collection_python_interpreter='python3 %:p'
let g:collection_python_formater='autopep8 %'

let g:collection_c_compiler='gcc %:p -o %:p:r -std=c99 -Wall -pedantic'
let g:collection_c_execute='%:p:r'
"etc..."

"------------------------------------------------------------------ RUN PROGRAM
" Run program with :R, autocomplete filenames for arguments
command! -complete=file -nargs=* R call Run_program(<q-args>)
" toggle errorlist with leader + e
map <silent><leader>e <cmd>call Toggle_errorlist()<CR>

"--------------------------------------------------------------------- TERMINAL
" toggle terminal with F4
nnoremap <silent><F4> <cmd>call Term_toggle()<CR>
tnoremap <silent><F4> <C-\><C-n> <cmd>call Term_toggle()<CR>
" leave terminal insert mode with escape
tnoremap <Esc> <C-\><C-n>

"----------------------------------------------------------------------- FORMAT
" format the file with leader f
nnoremap <silent><leader>f <cmd>call Format()<CR>

""--------------------------------------------------------------------- SNIPPETS
"Open snippets window with leader + q, load snippets with leader + l
"Create new snippet with :Sn(ippets) name.filetype
command! -nargs=* Snippets call Snippets(<q-args>)
nnoremap <leader>q <cmd>call Snippets('')<CR>
nnoremap <leader>l <cmd>call Snippets('load')<CR>

"Auto load snippets on enter
let g:collection_load_snippets=1

"interpreters, compilers, formaters,... need to be installed on your computer
"interpreter, compiler, formater,... format should start with it's name
"and then path and additional arguments, where path should be given unexpanded
"see `:h expand`
```
** same settings can be added to  `.config.vim`
