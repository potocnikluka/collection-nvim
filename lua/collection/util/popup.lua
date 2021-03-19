local M = {}

function M.createPopup(name, x, onCreation)
	local height = math.floor((vim.api.nvim_win_get_height(0) - 2) * 0.7)
	local width = math.floor(vim.api.nvim_win_get_width(0) * 0.4)
	local row = math.floor((vim.api.nvim_win_get_height(0) - height) / 2)
	local col = math.floor((vim.api.nvim_win_get_width(0) - width) / 2)
	local border_opts = {
		relative = 'editor',
		row = row - 1,
		col = col - 2,
		width = width + 4,
		height = height + 2,
		style = 'minimal'
	}
	local opts = {
		relative = 'editor',
		row = row,
		col = col,
		width = width,
		height = height,
		style = 'minimal'
	}
	local half1 = math.floor((width - string.len(name)) / 2)
	local half2 = width - string.len(name) - half1
	local top = "╭"..string.rep("─", half1).." "
	..name.." "..string.rep("─", half2).."╮"
	local mid = "│"..string.rep(" ", width + 2).."│"
	local bot = "╰"..string.rep("─", width + 2).."╯"
	local lines = {top}
	for i=2, height + 1 do
		lines[i] = mid
	end
	lines[height + 2] = bot
	local borderBuf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(borderBuf, 0, -1, true, lines)
	local borderWin = vim.api.nvim_open_win(
	borderBuf, true, border_opts
	)
	vim.bo.bufhidden="wipe"
	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(
	buf, true, opts
	)
	vim.cmd[[highlight FloatWinBorder guifg=#87bb7c]]
	vim.fn.setwinvar(borderWin, '&winhl', 'Normal:FloatWinBorder')
	vim.fn.setwinvar(win, '&winhl', 'Normal:Normal')

	if x == 'snippets' then
		vim.g.snipWin = win
		vim.g.snipBuf = buf
		vim.g.snipBordBuf = borderBuf
		vim.g.snipBordWin = borderWin
	end
	if onCreation ~= '' then
		onCreation()
	end
end

return M
