# Collection-nvim

A collection of configurations for a comfortable neovim experience.

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
* Code formating.
* Setting up filetype-specific interpreters, compilers, formaters,...
* Adding options to `.vim.json`, 
which allows different configurations for different projects.

##example init.vim config


```
let g:collection_python_interpreter='python3 %:p'
let g:collection_python_formater='autopep8 %'

let g:collection_c_compiler='gcc %:p -o %:p:r -std=c99 -Wall -pedantic'
let g:collection_c_execute='%:p:r'


"Toggle snippet list with <leader>q
nnoremap <leader>q :Snippets<CR>
"Toggle snippet terminal
nnoremap <silent><F4> :CTerm<CR>
tnoremap <silent><F4> <c-\><c-n>:CTerm<CR>
nnoremap <silent><leader>f :CFormat<CR>
"Format with <leader>f
command! R :CollectionRunProg
"Toggle errorlist with shift-e
nnoremap <silent><S-e> :Errorlist<CR>

"Auto load snippets on enter
"autocmd VimEnter * :Snippets load
```
