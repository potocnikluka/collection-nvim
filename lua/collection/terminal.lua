local M = {}
function M.toggle(termInfo)
	if vim.g['collection_terminal_type'] ~= 0 and
		vim.g['collection_terminal_type'] ~= 1  then
		return print('Invalid g:collection_terminal_type value.')
	end
	local termSize = tonumber(vim.g['collection_terminal_size'])
	if termSize == nil or termSize < 1 or termSize > 200 then
		return print('Invalid g:collection_terminal_size value.')
	end
	if vim.fn.win_gotoid(termInfo['termWin']) == 1 then
		vim.cmd [[hide]]
		return
	end
	local termType = 'vertical '
	if vim.g['collection_terminal_type'] == 1 then
		termType = ''
	end
	vim.fn.execute(string.format(
	'%snew | %sresize %d | set winfixwidth', termType, termType, termSize
	))

	local function reopenTerm()
		vim.fn.execute(string.format("buffer %d", termInfo['termBuf']))
	end
	if not pcall(reopenTerm) then
		vim.cmd [[call termopen($SHELL, {'detach': 0})]]
	end
	vim.cmd [[startinsert]]
	termInfo['termBuf'] = vim.fn.bufnr("")
	termInfo['termWin'] = vim.fn.win_getid()
end

return M
