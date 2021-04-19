local util = require 'collection.util'
local M = {}
local snips = {}

local function validSnippet(snip)
	local function readFile()
		return vim.fn.readfile(vim.fn.stdpath('config')..'/snippets/'..snip)
	end
	local r, content = pcall(readFile)
	if not r or content[3] == nil then return false end
	if string.find(content[1], 'Key binding:') ~= nil and
		(string.find(content[2], 'Code:') ~= nil or
		string.find(content[3], 'Code:') ~= nil) then
		snips[snip] = content
		return true
	end
end

local function onPopupCreation()
	vim.bo.bufhidden="wipe"
	vim.bo.autoindent=false
	vim.bo.smartindent=false
	vim.wo.cursorline=true
	vim.cmd[[syntax match Info '^► .*']]
	vim.cmd[[syntax match Info '^▼ .*']]
	vim.cmd[[syntax match Paste 'PASTE']]
	vim.cmd[[highlight def link Paste Function]]
	vim.cmd[[highlight def link Info Constant]]
	vim.api.nvim_buf_set_keymap(
	vim.g.snipBuf, "", "<CR>",
	":lua require'collection'.snippetSelect()<CR>", {silent=true})
	vim.api.nvim_buf_set_keymap(
	vim.g.snipBuf, "", "<Esc>",
	":lua require'collection'.closeSnipWin()<CR>", {silent=true})
	vim.api.nvim_buf_set_keymap(
	vim.g.snipBordBuf, "", "<Esc>",
	":lua require'collection'.closeSnipWin()<CR>", {silent=true})
end

local function showSnippets()
	util.createPopup('SNIPPETS', 'snippets', onPopupCreation)
	vim.bo.readonly=false
	local text = vim.fn.globpath(',', vim.fn.stdpath('config')..'/snippets/*')
	for _,i in pairs(vim.split(text, '\n')) do
		i = i:gsub(vim.fn.stdpath('config')..'/snippets/', '')
		if validSnippet(i) then
			vim.fn.execute("normal o►  "..i)
		end
	end
	vim.cmd[[normal gg0]]
	vim.bo.readonly=true
end

function M.closeSnipWin()
	if vim.fn.exists('g:snipBuf') == 1 then
		vim.fn.execute("silent! bwipeout! "..vim.g.snipBuf)
	end
	if vim.fn.exists('g:snipBordBuf') == 1 then
		vim.fn.execute("silent! bwipeout! "..vim.g.snipBordBuf)
	end
end

function M.pasteSnippet(snippet)
	vim.bo.readonly=false
	local content = snips[snippet]
	local move = true
	local k = 3
	if content[2] == 'Move cursor:' or content[2] == 'Move cursor: ' then
		move = false
	end
	M.closeSnipWin()
	if not vim.bo.modifiable then
		print("Could not paste")
		return
	end
	local pasteContent = {}
	local i = 1
	for j,v in pairs(snips[snippet]) do
		if j > k then
			pasteContent[i] = v
			i = i + 1
		end
	end
	vim.api.nvim_put(pasteContent, 'c', true, false)
	if move then
		local x = 'Move cursor:'
		if string.find(snips[snippet][2], 'Move cursor: ') ~= nil then
			x = 'Move cursor: '
		end
		local m = vim.split(snips[snippet][2], x)
		if m[2] == nil then
			return
		end
		vim.fn.execute("normal "..m[2])
	end
end

local function loadSnippets()
	local text = vim.fn.globpath(',', vim.fn.stdpath('config')..'/snippets/*')
	for _,i in pairs(vim.split(text, '\n')) do
		i = i:gsub(vim.fn.stdpath('config')..'/snippets/', '')
		if validSnippet(i) then
			local x = snips[i][1]
			if string.find(x, "Key binding: ") ~= nil then
				x = vim.split(x, "Key binding: ")[2]
			else
				x = vim.split(x, "Key binding:")[2]
			end
			local cmd = "nnoremap "..x.." :lua require'collection'.pasteSnippet('"..i.."')<CR>"
			vim.fn.execute("silent! "..cmd)
		end
	end
end

local function addSnippet(name)
	local ft = vim.bo.filetype
	util.createPopup('ADD SNIPPETS', 'snippets', onPopupCreation)
	vim.bo.readonly=false
	vim.bo.bufhidden="wipe"
	if string.find(name, '%.') ~= nil then
		local function tryAddFiletype()
			vim.bo.filetype=util.getFiletype(vim.split(name, '%.')[2])
		end
		if not pcall(tryAddFiletype) then
			vim.bo.filetype=ft
		end
	else
		vim.bo.filetype=ft
	end
	local text = {'Name: '..name, 'Key binding:', 'Move cursor:', 'Code:', ''}
	vim.api.nvim_put(text, 'l', true, true)
end

local function saveSnippet(args)
	if vim.fn.exists("g:snipBuf") == 0 or
		vim.fn.bufnr("") ~= vim.g.snipBuf then return end
	if vim.fn.isdirectory(vim.fn.stdpath('config')..'/snippets') == 0 then
		print('Please create '..vim.fn.stdpath('config')..'/snippets dir.')
		return
	elseif vim.fn.getline(2) == 'Name:' or vim.fn.getline(2) == 'Name: ' then
		print("Please provide a file name!")
		return
	elseif vim.fn.getline(3) == 'Key binding:' or
		vim.fn.getline(3) == 'key binding: ' then
		print("Please provide a key binding!")
		return
	elseif vim.fn.line('$') < 5 or
		vim.fn.line('$') < 6 and vim.fn.line(5) == '' then
		print("Cannot save an empty snippet!")
		return
	end
	local name = vim.split(vim.fn.getline(2), 'Name: ')[2]
	if not string.find(vim.fn.getline(2), 'Name: ') then
		name = vim.split(vim.fn.getline(2), 'Name:')[2]
	end
	if vim.fn.filereadable(vim.fn.stdpath('config')..'/snippets/'..name) == 1 and
		args == 'save' then
		print('File already exists, add ! to override!')
		return
	end

	vim.bo.readonly=false
	vim.cmd[[normal gg2dd]]
	vim.fn.execute("w! "..vim.fn.stdpath('config')..'/snippets/'..name)
	M.closeSnipWin()
end

function M.onSelect()
	vim.bo.readonly=false
	local function trySelect()
		local snippet = vim.fn.getline('.')
		local x = vim.split(snippet, ' ')
		if x[3] ~= nil and x[1] == '▼' then
			vim.cmd[[s/▼/►/I]]
			vim.cmd[[silent! normal mzj3ddg'z0]]
		elseif x[3] ~= nil and x[1] == '►' then
			vim.cmd[[s/►/▼/I]]
			snippet = x[3]
			if snips[snippet] ~= nil and not validSnippet(snippet) then
				vim.bo.readonly=true
				return true
			end
			local content = snips[snippet]
			vim.fn.execute("normal o    "..content[1])
			if not string.find(content[2], 'Move after:') then
				vim.fn.execute("normal o    Move after:")
			else
				vim.fn.execute("normal o    "..content[2])
			end
			vim.cmd[[normal o    PASTE]]
			vim.cmd[[silent normal 3k0]]
		elseif snippet == '    PASTE' then
			snippet = vim.split(vim.fn.getline(vim.fn.line('.') - 3), ' ')[3]
			M.pasteSnippet(snippet)
			return true
		else
			vim.bo.readonly=true
			return true
		end
		return true
	end
	local r, er = trySelect()
	if not r then
		print(er)
		vim.bo.readonly=true
		return
	end
	if vim.bo.filetype == 'snippets' then
		vim.bo.readonly=true
	end
end

function M.snippets(args)
	local wipe = false
	if vim.fn.exists(vim.g.snipWin) == 1 and
		vim.fn.win_gotoid(vim.g.snipWin) == 1 then
		if args ~= 'save' and args ~= 'save!' and args ~= 'load' then
			M.closeSnipWin()
			wipe = true
		end
	end
	if args == '' then
		if wipe then return end
		local r, er = pcall(showSnippets)
		if not r then
			print(er)
		end
	elseif args == 'load' then
		local r, er = pcall(loadSnippets)
		if not r then
			print(er)
		end
	elseif args == 'save' or args == 'save!' then
		local r, er = pcall(saveSnippet, args)
		if not r then
			print(er)
		end
	else
		local r, er = pcall(addSnippet, args)
		if not r then
			print(er)
		end
	end
end
return M
