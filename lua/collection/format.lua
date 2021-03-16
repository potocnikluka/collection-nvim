local M = {}

function M.format()
	local filetype = vim.bo.filetype
	if string.find(vim.g.collection_format_ignore, filetype) ~= nil then
		return
	end
	if vim.g.collection_format_save ~= 1 and
		vim.g.collection_format_save ~= 0 then
		return print('Invalid g:collection_format_save value.')
	end
	if vim.g.collection_format_save == 1 then
		vim.cmd[[silent! w]]
	end
	vim.cmd [[silent! normal mz]]
	local formater = ''
	if vim.fn.exists(
		'g:collection_'..filetype..'_formater'
		) == 0
		then
			vim.cmd[[silent! normal gg=Gg'zw]]
			return print(
			'No formater specified, using default indenting.'
			)
		else
			formater = vim.g['collection_'..filetype..'_formater']
		end
		local words = {}
		local formaterName = formater:gmatch("[^%s]+")()
		if vim.fn.executable(formaterName) == 0 then
			vim.cmd[[silent! normal gg=Gg'zw]]
			return print(
			'Cannot execute '..formaterName..', using default indenting.'
			)
		end
		local function tryFormating()
			vim.o.equalprg=formater
			vim.cmd[[silent normal G=gg]]
			vim.o.equalprg=""
			if string.find(vim.fn.getline('.'), 'error') ~= nil or
				string.find(vim.fn.getline('.'), '/bin/bash:') ~= nil
				then
					local err = vim.fn.getline('.')
					vim.cmd[[silent! undo]]
					print(err)
				else
					print('Formated with '..formaterName)
				end
			end
			if not pcall(tryFormating) then
				local function tryNormal()
					vim.o.equalprg=""
					vim.cmd[[silent normal G=gg]]
					print(
					'Could not format with '..words[1]..', using default indenting.'
					)
				end
				if not pcall(tryNormal) then
					print('Could not format.')
				end
			end
			vim.cmd[[silent! normal g'z]]
			if vim.g.collection_format_save == 1 then
				vim.cmd[[silent! w]]
			end
		end

		return M
