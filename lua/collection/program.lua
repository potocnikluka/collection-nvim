local M = {}

-- Add arguments from interpreter, compiler or execute to command
local function addToCommand(command, args)
	local function manipulateCommand()
		--split arguments and expand those starting with % (path)
		for argument in string.gmatch(args, "[^%s]+") do
			if string.sub(argument, 1, 1) == '%' then

				--if unexpanded path includes '.', replace extension
				if string.find(argument, '%.') then
					local s = ''
					local x = string.gmatch(argument, "[^%.]+")
					for i in x do
						if string.sub(i, 1, 1) == '%' then
							i = vim.fn.expand(i)
							s = string.format("%s%s", s, i)
						else
							s = string.format("%s.%s", s, i)
						end
					end
					command = string.format("%s %s", command, s)
				else
					argument = vim.fn.expand(argument)
					command = string.format("%s %s", command, argument)
				end
			else
				command = string.format("%s %s", command, argument)
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
		for i in string.gmatch(arguments, "[^%s]+") do
			if string.sub(i, 1, 1) == '-' then
				command = string.format("%s %s", command, i)
			end
		end
		--if execute is added, run the prog. after compiling
		if execute ~= nil  then
			command = string.format("%s  && ", command)
			command = addToCommand(command, execute)
		end
		for i in string.gmatch(arguments, "[^%s]+") do
			if string.sub(i, 1, 1) ~= '-' then
				command = string.format("%s %s", command, i)
			end
		end
	end
	--if error occured when building a command
	if pcall(tryToBuild) then
		return command
	end
	return ''

end
local function checkIfExecutable(args)
	if string.sub(args, 1, 1) == '%' then
		return 1
	end
	local nm = args:match("[^%s]+")
	if vim.fn.executable(nm) == 0 then
		print(string.format('Cannot execute %s.', nm))
		return 0
	else
		return 1
	end
end
function M.run(args, progInfo)
	if vim.g['collection_errorlist_type'] ~= 0 and
		vim.g['collection_errorlist_type'] ~= 1  then
		return print('Invalid g:collection_errorlist_type value.')
	end
	local errorlistSize = tonumber(vim.g['collection_errorlist_size'])
	if errorlistSize == nil or errorlistSize < 1 or errorlistSize > 200 then
		return print('Invalid g:collection_errorlist_size value.')
	end
	vim.fn.execute(string.format("silent! bwipeout! %d", progInfo['progBuf']))
	local filetype = vim.bo.filetype
	local curWin = vim.fn.winnr()
	local interpreter = nil
	local compiler = nil
	local execute = nil
	if vim.fn.exists(
		string.format('g:collection_%s_interpreter', filetype)
		) == 1 and vim.g[
		string.format('collection_%s_interpreter', filetype)
		] ~= 0 then
		interpreter = vim.g[string.format(
		'collection_%s_interpreter', filetype
		)]
		if checkIfExecutable(interpreter) == 0 then
			return
		end
	elseif vim.fn.exists(
		string.format('g:collection_%s_compiler', filetype)
		) == 1 and vim.g[
		string.format('collection_%s_compiler', filetype)
		] ~= 0 then
		compiler = vim.g[string.format(
		'collection_%s_compiler', filetype
		)]
		if checkIfExecutable(compiler) == 0 then
			return
		end
	else
		return print('This command is not set for this filetype.')
	end
	if vim.fn.exists(
		string.format('g:collection_%s_execute', filetype)
		) == 1 and vim.g[
		string.format('collection_%s_execute', filetype)
		] ~= 0 then
		execute = vim.g[string.format('collection_%s_execute', filetype)]
		if checkIfExecutable(execute) == 0 then
			return
		end
	end
	local command = buildCommand(interpreter, compiler, execute, args)
	if command == '' then
		return print('Could not run the program.')
	end
	local errorlistType = 'vertical new errorlist | vertical resize'
	if vim.g['collection_errorlist_type'] == 1 then
		errorlistType = 'new errorlist | resize'
	end
	vim.cmd[[silent! save]]
	vim.fn.execute(string.format("%s %d", errorlistType, errorlistSize))
	vim.fn.execute(string.format(
	"call termopen('%s', {'detach': 0})", command
	))
	vim.cmd[[set filetype=errorlist | set winfixwidth | normal G]]
	progInfo['progBuf'] = vim.fn.bufnr("")
	progInfo['progWin'] = vim.fn.win_getid()
	vim.fn.execute(string.format("%d wincmd p", curWin))
	local txt = ''
	for i in string.gmatch(command, "[^%s]+") do
		if string.len(i) > 20 and string.find(i, "%/") then
			local last = ''
			for j in string.gmatch(i, "[^%/]+") do
				last = j
			end
			txt = string.format("%s .../%s", txt, last)
		else
			txt = string.format("%s %s", txt, i)
		end
	end
	print(txt)
end

--Toggle the errorlist
function M.toggle(progInfo)
	if vim.g['collection_errorlist_type'] ~= 0 and
		vim.g['collection_errorlist_type'] ~= 1  then
		return print('Invalid g:collection_errorlist_type value.')
	end
	local errorlistSize = tonumber(vim.g['collection_errorlist_size'])
	if errorlistSize == nil or errorlistSize < 1 or errorlistSize > 200 then
		return print('Invalid g:collection_errorlist_size value.')
	end
	local curWin = vim.fn.winnr()
	if vim.fn.win_gotoid(progInfo['progWin']) == 1 then
		vim.cmd [[hide]]
		vim.fn.execute(string.format("%d wincmd p", curWin))
	else
		local function tryReopen()
			local errorlistType = 'vertical new errorlist | vertical resize'
			if vim.g['collection_errorlist_type'] == 1 then
				errorlistType = 'new errorlist | resize'
			end
			vim.fn.execute(string.format("%s %d", errorlistType, errorlistSize))
			vim.fn.execute(string.format('buffer %d', progInfo['progBuf']))
			progInfo['progBuf'] = vim.fn.bufnr("")
			progInfo['progWin'] = vim.fn.win_getid()
			vim.cmd [[set winfixwidth | normal G]]
			vim.fn.execute(string.format("%d wincmd p", curWin))
		end
		if not pcall(tryReopen) then
			vim.cmd [[q!]]
			print('Nothing running.')
		end
	end
end

return M
