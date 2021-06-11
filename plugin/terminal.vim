"==============================================================================
"------------------------------------------------------------------------------
"                                                                      TERMINAL
"==============================================================================
"______________________________________________________________ TOGGLE TERMINAL

let g:term_buf = 0
let g:term_win = 0
function! Term_toggle()
	if g:collection_terminal_type != 1 && g:collection_terminal_type != 0
		echo "Invalid g:collection_terminal_type value"
		return
	endif
	let size = str2nr(g:collection_terminal_size)
	if size < 1 || size > 200
		echo "Invalid g:collection_terminal_size value"
		return 0
	endif
	if win_gotoid(g:term_win)
		hide
	else
		if g:collection_terminal_type == 1
			new
			execute "resize ".g:collection_terminal_size
		else
			vertical new
			execute "vertical resize ".g:collection_terminal_size
		endif
		try
			exec "buffer " . g:term_buf
		catch
			call termopen($SHELL, {"detach": 0})
		endtry
		startinsert!
		let g:term_buf = bufnr("")
		let g:term_win = win_getid()
	endif
endfunction
