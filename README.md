# Collection-nvim

A collection of configurations to implement some of neovim's 
useful features.

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

"command for managing snippets
command! -nargs=* Snippets lua require('collection').snippets(<q-args>)
"toggle snippets list with <leader> q
nnoremap <leader>q :Snippets<CR>

"Toggle terminal
nnoremap <silent><F4> :lua require('collection').toggleTerminal()<CR>
tnoremap <silent><F4> <c-\><c-n>:lua require('collection').toggleTerminal()<CR>

"Format with <leader>f
nnoremap <leader>f :lua require('collection').format()<CR>

"Toggle errorlist with shift-e
nnoremap <S-e> :lua require('collection').toggleErrorlist()<CR>

"Auto load snippets on enter
"autocmd VimEnter * lua require('collection').snippets('load')
```
