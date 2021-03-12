local M = {}

function M.format()
	local filetype = vim.bo.filetype
	if string.find(vim.g['collection_format_ignore'], filetype) ~= nil then
		return
	end
	if vim.g['collection_format_save'] ~= 1 and
		vim.g['collection_format_save'] ~= 0 then
		return print('Invalid g:collection_format_save value.')
	end
	if vim.g['collection_format_save'] == 1 then
		vim.cmd[[silent! w]]
	end
	vim.cmd [[silent! normal mz]]
	local formater = ''
	if vim.fn.exists(
		string.format('g:collection_%s_formater', filetype)
		) == 0 or vim.g[
		string.format('collection_%s_formater', filetype)
		] == 0 then
		vim.cmd[[silent! normal gg=Gg'zw]]
		return print(
		'No formater specified, using default indenting.'
		)
	else
		formater = vim.g[string.format('collection_%s_formater', filetype)]
	end
	local words = {}
	local formaterName = formater:gmatch("[^%s]+")()
	if vim.fn.executable(formaterName) == 0 then
		vim.cmd[[silent! normal gg=Gg'zw]]
		return print(string.format(
		'Cannot execute %s, using default indenting.', formaterName)
		)
	end
	local command = ''
	local function editCommand()
		for i in string.gmatch(formater, "[^%s]+") do
			if command == '' then
				command = string.format("%s%s", command, i)
			else
				command = string.format("%s\\ %s", command, i)
			end
		end
	end
	if not pcall(editCommand) then
		return print('Could not format.')
	end
	local function tryFormating()
		vim.fn.execute(string.format(
		'setlocal equalprg=%s', command
		))
		vim.cmd[[silent normal G=gg]]
		vim.cmd[[setlocal equalprg=""]]
		if string.find(vim.fn.getline('.'), 'error') ~= nil then
			local err = vim.fn.getline('.')
			vim.cmd[[silent! undo]]
			print(err)
		else
			print(string.format('Formated with %s.', formaterName))
		end
	end
	if not pcall(tryFormating) then
		local function tryNormal()
			vim.cmd[[setlocal equalprg=""]]
			vim.cmd[[silent normal G=gg]]
			print(string.format(
			'Could not format with %s, using default indenting.',
			words[1]
			))
			print(command)
		end
		if not pcall(tryNormal) then
			print('Could not format.')
		end
	end
	vim.cmd[[silent! normal g'z]]
	if vim.g['collection_format_save'] == 1 then
		vim.cmd[[silent! w]]
	end
end

return M
