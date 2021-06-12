"==============================================================================
"------------------------------------------------------------------------------
"                                                                   RUN PROGRAM
"==============================================================================
" Asynchronous program running.
"
" Adding arguments to Run_program():
"	 'arg'  -> adds 'arg' when executing
"	 'arg;arg2' -> adds 'arg' when compiling, 'arg2' when executing
"
" Add arguments to the top of the file to avoid typing arguments every time
" you run the program:
"
"	`// compile -> arguments`
"	`// execute -> arguments`
"
"	** '//' can be replaced with any type of comment
" _____________________________________________________________________________

let g:prog_buf = 0
let g:prog_win = 0
"______________________________________________________________ Run the program
"
function! Run_program(args)
	if !Check_run_options() | return | endif
	execute("silent! bwipeout! " . g:prog_buf)
	let win_nr = winnr()
	let interpreter = ''
	let compiler = ''
	let execute = ''
	"Check if compiler, interpreter, execute are set
	if exists('g:collection_' . &filetype . "_interpreter")
		execute("let interpreter = g:collection_" . &filetype . "_interpreter")
		if !Check_if_executable(interpreter) | return | endif
	elseif exists('g:collection_' . &filetype . "_compiler")
		execute("let compiler = g:collection_" . &filetype . "_compiler")
		if !Check_if_executable(compiler) | return | endif
	endif
	if exists('g:collection_' . &filetype . "_execute")
		execute("let execute = g:collection_" . &filetype . "_execute")
		if !Check_if_executable(execute) | return | endif
	endif
	"Build the run command
	let cmd = Build_command(interpreter, compiler, execute, a:args)
	if cmd == ''
		echo "Could not run the program"
		return
	endif
	if g:collection_errorlist_save | silent! w | endif
	let cur_win = winnr()
	let x = Create_window()
	if !x 
		echo "Could not create window."
	endif
	call termopen(''.cmd.'', {'detach': 0})
	set winfixwidth
	normal G
	set filetype=errorlist
	let g:prog_buf = bufnr("")
	let g:prog_win = win_getid()
	execute(win_nr . " wincmd p")
	"echo command text
	let txt = ''
	for i in split(cmd, "")
		if len(i) > 20 && matchstr(i, "/") != ""
			let i = split(i, "/")[-1]
		endif
		if txt == '' && i != ''
			let txt = i
		elseif i != ''
			let txt = txt . " " . i
		endif
	endfor
	echo txt
endfunction

"------------------------------Check if compiler, interpreter,... is executable
function! Check_if_executable(args)
	if a:args[0] =~ '%' 
		return 1 
	endif
	let name = split(a:args, " ")[0]
	if !executable(name)
		echo 'Cannot execute '.name
		return 0
	endif
	return 1
endfunction

"------------------------------Build the command from compiler, interpreter,...
function! Build_command(interpreter, compiler, execute, args)
	let cmd = ''
	try
		if a:interpreter != ''
			let cmd = Add_to_command(cmd, a:interpreter)
		elseif a:compiler != ''
			let cmd = Add_to_command(cmd, a:compiler)
			for i in [1, 2]
				let x = getline(i)
				if x =~ 'compile -> '
					let cmd = cmd . Arg_constants(x)
				endif
			endfor
		endif
		if a:execute != ''
			let cmd = Add_arguments(cmd, a:args, 0)
			let cmd = cmd . '  && ' . Add_to_command('', a:execute)
			let cmd = Add_arguments(cmd, a:args, 1)
		else
			let cmd = Add_arguments(cmd, a:args, 2)
		endif
		if a:execute != '' || a:interpreter != ''
			for i in [1, 2]
				let x = getline(i)
				if x =~ 'execute -> '
					let cmd = cmd . Arg_constants(x)
				endif
			endfor
		endif
	catch
		return ''
	endtry
	return cmd
endfunction

"---------------------------------------------------------Add  parts to command
function! Add_to_command(cmd, args)
	let cmd = a:cmd
	try
		for i in split(a:args, " ")
			if i[0] =~ '%'
				if matchstr(i, '/.') != ''
					let s = ''	
					let x = split(i, '.')
					for j in x
						if j[0] =~ '%'
							let j = expand(j)
						endif
						let s = s . j
					endfor
					let cmd = cmd . " " . s
				else
					let i = expand(i)
				endif
			endif
			let cmd = cmd . " " . i
		endfor
	catch
		return ''
	endtry
	return cmd
endfunction

"---------------------------------------------------- Add  arguments to command
function! Add_arguments(cmd, args, type)
	let cmd = a:cmd
	if len(a:args) < 1
		return cmd
	endif
	let args = split(a:args . ' ', ';')
	if a:type == 0
		if len(args) < 2
			return cmd
		endif
		let cmd = cmd . ' ' . args[0]
	elseif a:type == 1
		if len(args) < 2
			let cmd = cmd . ' ' . args[0]
		else
			let cmd = cmd . ' ' . args[1]
		endif
	else
		let cmd = cmd . ' ' .  a:args
	endif
	return cmd
endfunction

function! Arg_constants(cur_line)
	try
		let x = split(split(a:cur_line, ' -> ')[1], ' ')
		let j = 0
		for i in x
			if i[0] == '.' && i[1] == '/'
				let x[j] =  expand('%:p:h') . '/' .  substitute(i, '\.\/', '', '')
			elseif i[0] == '.' && i[1] == '.' && i[2] == '/'
				let c = count(i, '../')
				let path = '%:p:h' . repeat(':h', c)
				while c > 0
					let i = substitute(i, '\.\.\/', '', '')
					let c = c - 1
				endwhile
				let x[j] = expand(path).'/' . i
			endif
			let j = j + 1
		endfor
		return ' ' . join(x, ' ')
	catch
		return ''
	endtry
endfunction

"--------------------------------------------------------------Toggle errorlist
function! Toggle_errorlist()
	if !Check_run_options() | return | endif
	let cur_win = winnr()
	if win_gotoid(g:prog_win)
		hide
		execute(cur_win . " wincmd p")
		return
	endif
	try
		let x = Create_window()
		if !x 
			echo "Could not create new window."
			return
		endif
		execute("buffer " . g:prog_buf)
		let g:prog_buf = bufnr("")
		let g:prog_win = win_getid()
		setlocal winfixwidth
		normal G
		execute(cur_win . " wincmd p")
	catch
		q!
		echo "Nothing is running"
	endtry
endfunction

"------------------------------------------------------- Check if valid options
function! Check_run_options()
	if matchstr(g:collection_run_ignore, &filetype) != ''
		echo "Cannot run the command for this filetype"
		return 0
	endif
	if g:collection_errorlist_type != 0 && g:collection_errorlist_type != 1
		echo "Invalid g:collection_errorlist_type value"
		return 0
	endif
	let size = str2nr(g:collection_errorlist_size)
	if size < 1 || size > 200
		echo "Invalid g:collection_errorlist_size value"
		return 0
	endif
	return 1
endfunction

"---------------------------------------------------------------- Create window
function! Create_window()
	try
		let type = 'vertical new errorlist | vertical resize '
		if g:collection_errorlist_type == 1
			let type = 'new errorlist | resize '
		endif
		execute(type . g:collection_errorlist_size)
	catch
		return 0
	endtry
	return 1
endfunction
