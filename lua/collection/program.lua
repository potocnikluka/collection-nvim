local M = {}

-- Add arguments from interpreter, compiler or execute to command
local function addToCommand(command, args)
	local function manipulateCommand()
		--split arguments and expand those starting with % (path)
		for _,argument in pairs(vim.split(args, " ")) do
			if string.sub(argument, 1, 1) == '%' then

				--if unexpanded path includes '.', replace extension
				if string.find(argument, '%.') ~= nil then
					local s = ''
					local x = string.gmatch(argument, "[^%.]+")
					for i in x do
						if string.sub(i, 1, 1) == '%' then
							i = vim.fn.expand(i)
							s = s..i
						else
							s = s.."."..i
						end
					end
					command = command.." "..s
				else
					argument = vim.fn.expand(argument)
					command = command.." "..argument
				end
			else
				command = command.." "..argument
			end
		end
	end
	if pcall(manipulateCommand) then
		return command
	end
	return ''
end

-- Build command from info in filetypes
local function buildCommand(interpreter, compiler, execute, arguments)
	local command = ''
	local function tryToBuild()
		if interpreter ~= nil then
			command = addToCommand(command, interpreter)
		elseif compiler ~= nil then
			command = addToCommand(command, compiler)
		end
		for _,i in pairs(vim.split(arguments, " ")) do
			if string.sub(i, 1, 1) == '-' then
				command = command.." "..i
			end
		end
		--if execute is added, run the prog. after compiling
		if execute ~= nil  then
			command = command.."  && "
			command = addToCommand(command, execute)
		end
		for _,i in pairs(vim.split(arguments, " ")) do
			if string.sub(i, 1, 1) ~= '-' then
				command = command.." "..i
			end
		end
	end
	--if error occured when building a command
	if pcall(tryToBuild) then
		return command
	end
	return ''
end
--Check if compilers, interpreters... are executable
local function checkIfExecutable(args)
	if string.sub(args, 1, 1) == '%' then
		return 1
	end
	local nm = args:match("[^%s]+")
	if vim.fn.executable(nm) == 0 then
		print("Cannot execute "..nm)
		return 0
	else
		return 1
	end
end

function M.run(args)
	if vim.g.collection_errorlist_type ~= 0 and
		vim.g.collection_errorlist_type ~= 1  then
		return print('Invalid g:collection_errorlist_type value.')
	end
	local errorlistSize = tonumber(vim.g.collection_errorlist_size)
	if errorlistSize == nil or errorlistSize < 1 or errorlistSize > 200 then
		return print('Invalid g:collection_errorlist_size value.')
	end
	vim.fn.execute("silent! bwipeout! "..vim.g.progbuf)
	local filetype = vim.bo.filetype
	local curWin = vim.fn.winnr()
	local interpreter = nil
	local compiler = nil
	local execute = nil
	--check for existing interpreters, compilers, executes
	if vim.fn.exists(
		'g:collection_'..filetype..'_interpreter'
		) == 1 then
		interpreter = vim.g['collection_'..filetype..'_interpreter']
		if checkIfExecutable(interpreter) == 0 then
			return
		end
	elseif vim.fn.exists(
		'g:collection_'..filetype..'_compiler'
		) == 1 then
		compiler = vim.g['collection_'..filetype..'_compiler']
		if checkIfExecutable(compiler) == 0 then
			return
		end
	else
		return print('This command is not set for this filetype.')
	end
	if vim.fn.exists(
		'g:collection_'..filetype..'_execute'
		) == 1  then
		execute = vim.g['collection_'..filetype..'_execute']
		if checkIfExecutable(execute) == 0 then
			return
		end
	end
	local command = buildCommand(interpreter, compiler, execute, args)
	if command == '' then
		print('Could not run the program.')
		return
	end
	local errorlistType = 'vertical new errorlist | vertical resize'
	if vim.g.collection_errorlist_type == 1 then
		errorlistType = 'new errorlist | resize'
	end
	vim.cmd[[silent! w]]
	vim.fn.execute(errorlistType.." "..errorlistSize)
	vim.fn.execute(
	"call termopen('"..command.."', {'detach': 0})"
	)
	vim.bo.filetype="errorlist"
	vim.cmd[[file errorlist]]
	vim.cmd[[set winfixwidth | normal G]]
	vim.g.progbuf = vim.fn.bufnr("")
	vim.g.progwin = vim.fn.win_getid()
	vim.fn.execute(curWin.." wincmd p")
	local txt = ''
	for _,i in pairs(vim.split(command, " ")) do
		if string.len(i) > 20 and string.find(i, "%/") then
			local last = ''
			for j in string.gmatch(i, "[^%/]+") do
				last = j
			end
			txt = txt.." .../"..last
		elseif i ~= "" then
			txt = txt.." "..i
		end
	end
	print(txt)
end

--Toggle the errorlist
function M.toggle()
	if vim.g.collection_errorlist_type ~= 0 and
		vim.g.collection_errorlist_type ~= 1  then
		return print('Invalid g:collection_errorlist_type value.')
	end
	local errorlistSize = tonumber(vim.g.collection_errorlist_size)
	if errorlistSize == nil or errorlistSize < 1 or errorlistSize > 200 then
		return print('Invalid g:collection_errorlist_size value.')
	end
	local curWin = vim.fn.winnr()
	if vim.fn.win_gotoid(vim.g.progwin) == 1 then
		vim.bo.bufhidden=""
		vim.cmd [[hide]]
		vim.fn.execute(curWin.." wincmd p")
	else
		--try to open hidden errorlist buffer
		--catch err if it does not exist
		local function tryReopen()
			local errorlistType = 'vertical new errorlist | vertical resize'
			if vim.g.collection_errorlist_type == 1 then
				errorlistType = 'new errorlist | resize'
			end
			vim.fn.execute(errorlistType.." "..errorlistSize)
			vim.fn.execute("buffer "..vim.g.progbuf)
			vim.g.progbuf = vim.fn.bufnr("")
			vim.g.progwin = vim.fn.win_getid()
			vim.cmd[[file errorlist]]
			vim.cmd [[set winfixwidth | normal G]]
			vim.fn.execute(curWin.." wincmd p")
		end
		local x= pcall(tryReopen)
		if not x then
			vim.cmd[[q!]]
			print("Nothing is running")
		end
	end
end

return M
