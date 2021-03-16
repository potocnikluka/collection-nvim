local M = {}

local function deleteLine()
	vim.cmd[[normal mzGk]]
	if vim.fn.getline('.'):gsub("^│%s*│", "") == "" then
		vim.cmd[[normal dd]]
	end
	vim.cmd[[normal g'z]]
end
local function addLine()
	if vim.fn.line('$') < vim.g.snipHeight then
		vim.cmd[[normal mzG]]
		vim.fn.execute(
		"normal O".."│"..string.rep(
		" ", vim.g.snipWidth - 2).."│"
		)
		vim.cmd[[normal g'z]]
	end
end
local function getFiletype(ft)
	if ft == 'py' then
		return 'python'
	elseif ft == 'js' then
		return 'javascript'
	elseif ft == 'ts' then
		return 'typescript'
	else
		return ft
	end
end


local snips = {}
--Check if it is a valid snippet
local function validSnip(name)
	local content = vim.fn.readfile(vim.g.configPath..'/snippets/'..name)
	if string.find(content[2], "Filetype:") ~= nil and
		string.find(content[3], "Name:") ~= nil and
		string.find(content[4], "Key binding:") ~= nil and
		string.find(content[5], "Move cursor:") ~= nil and
		string.find(content[7], "Code:") ~= nil then
		snips[name]= content
		return true
	end
	return false
end

--Create new snippet
local function newSnippet(args, filetype)
	local name = args
	if string.find(args, "%.") then
		filetype = args:match("%..*$"):gsub("%.", "")
		filetype = getFiletype(filetype)
	end
	vim.fn.execute(
	"normal o│ Filetype: "..filetype.."\n│ Name: "..name..
	"\n│ Key binding:\n│ Move cursor:\n│\n╰ Code:\n")
	vim.bo.filetype=filetype
end

local function saveSnippet()
	if vim.fn.win_getid() ~= vim.g.snipWin then
		return
	elseif vim.fn.getline(2):gsub(".*Filetype:%s*", "") == "" then
		return print("Please provide a filetype.")
	elseif vim.fn.getline(3):gsub(".*Name:%s*", "") == "" then
		return print("Please provide a name.")
	elseif vim.fn.getline(4):gsub(".*Key binding:%s*", "") == "" then
		return print("Please add key bindings.")
	elseif vim.fn.isdirectory(vim.g.configPath.."/snippets") == 0 then
		return print(
		"Please create "..vim.g.configPath.."/snippets directory."
		)
	end
	local name=vim.fn.getline(3):gsub(".*Name:%s*", "")
	if vim.fn.filereadable(vim.g.configPath.."/snippets/"..name) == 1 then
		return print("File "..name.." already exists.")
	end
	local content = vim.fn.getline(1, '$')
	vim.fn.writefile(content, vim.g.configPath.."/snippets/"..name)
	vim.cmd[[q]]
	print("Snippet saved")
	M.show("")
end

--list all availible snippets
local function listSnippets(text)
	text = vim.split(text, '\n')
	for _, v in pairs(text) do
		if validSnip(v) then
			vim.fn.execute("normal o│─ "..v..string.rep(
			" ", vim.g.snipWidth - (4 + string.len(v))).."│"
			)
			deleteLine()
		end
	end
	vim.cmd[[normal gg0]]
end

--put the code from snippet into the buffer
function M.pasteSnippet(snip)
	local content=snips[snip]
	local keys = content[5]:gsub(".*Move cursor:%s*", "")
	vim.fn.execute("read "..vim.g.configPath.."/snippets/"..snip)
	vim.cmd[[silent! normal k8dd]]
	vim.fn.execute("normal "..keys)
	print("Pasted "..snip)
end

--do on pressing enter
function M.selection()
	local name = vim.fn.getline('.'):gsub("^│─%s*", ""):gsub("%s*│$", "")
	if name:gsub("^│%s*", "") == "PASTE" then
		vim.cmd[[normal 5k]]
		name = vim.fn.getline('.'):gsub("^│─%s*", ""):gsub("%s*│$", "")
		vim.cmd[[q!]]
		return M.pasteSnippet(name)
	end
	local content = snips[name]
	local i = 5
	local j = 2
	vim.cmd[[set noreadonly]]
	local x = vim.fn.getline(vim.fn.line('.') + 1):gsub("%s*│$", "")
	while x =="│    "..content[j] or x=="│    PASTE"do
		vim.cmd[[normal jddk]]
		x = vim.fn.getline(vim.fn.line('.') + 1):gsub("%s*│$", "")
		addLine()
		j = j + 1
	end
	if j < 3 then
		while i > 1 do
			content[i] = content[i]:gsub("│ ", "")
			vim.fn.execute("normal o│    "..content[i]..string.rep(
			" ", vim.g.snipWidth - (6 + string.len(content[i]))).."│"
			)
			deleteLine()
			vim.cmd[[normal k]]
			i = i - 1
		end
		vim.fn.execute("normal 4jo│    PASTE"..string.rep(
		" ", vim.g.snipWidth - 11).."│"
		)
		vim.cmd[[normal 5k0]]
		deleteLine()
	end
	vim.cmd[[set readonly]]
end

--Load snippets so remappings work
local function loadSnippets()
	local text = vim.split(vim.fn.globpath(
	',', vim.g.configPath..'/snippets/*'):gsub(
	vim.g.configPath..'/snippets/', ""
	), '\n')
	for _, v in pairs(text) do
		if validSnip(v) then
			local content = snips[v]
			local keys = content[4]:gsub(".*Key binding:%s*", "")
			:gsub("%s*│$", "")
			vim.fn.execute(
			"nnoremap "..keys..
			" :lua require'collection'.pasteSnippet('"..v..
			"')<CR>")
		end
	end
	print("Snippets have been loaded.")
end

function M.show(args)
	if args == 'load' then
		return loadSnippets()
	end
	--toggle on snippets
	vim.g.currentWin = vim.fn.win_getid()
	--if oppened, close
	if vim.fn.win_gotoid(vim.g.snipWin) == 1 then
		if args ~= 'save' then
			return vim.cmd[[q!]]
		else
			local r,e = pcall(saveSnippet)
			if not r then
				print(e)
			end
			return
		end
	elseif args == 'save' then
		return print('No snippet is being managed.')
	end
	local filetype = vim.bo.filetype
	--create popup
	local swidth = vim.fn.nvim_win_get_width(0)
	local sheight = vim.fn.nvim_win_get_height(0)
	local width = swidth
	local height = sheight
	if width > 90 then
		width = 90
	end
	if height > 60 then
		height = 60
	end
	local rows = (sheight + 4 - height) / 2
	local cols = (swidth + 4 - width) / 2
	vim.g.snipWidth = width - 8
	vim.g.snipHeight = height - 4
	vim.g.snipBuf = vim.api.nvim_create_buf(false, true)
	vim.g.snipWin = vim.api.nvim_open_win(vim.g.snipBuf, true, {
		relative="editor",
		width = vim.g.snipWidth,
		height = vim.g.snipHeight,
		col = cols,
		row = rows,
		style='minimal'
	})
	local half1 = (vim.g.snipWidth - 12) / 2
	local half2 = vim.g.snipWidth - 12 - half1
	if vim.g.snipWidth % 2 ~= 0 then
		half1 = half1 - 0.5
		half2 = half2 + 1
	end
	local topBorder = "╭"..string.rep("─", half1)..
	" SNIPPETS "..string.rep("─", half2).."╮"
	if args == '' then
		local bottomBorder = "╰"..string.rep("─", half1)..
		" SNIPPETS "..string.rep("─", half2).."╯"
		local midBorder = string.rep("│"..string.rep(
		" ", half1 + half2 + 10).."│\n", vim.g.snipHeight - 2
		)
		vim.fn.execute("normal i"..topBorder.."\n"..midBorder..bottomBorder)
		vim.cmd[[normal gg0j]]
		vim.bo.filetype="snippets"
		vim.cmd[[setlocal cursorline]]
		local text = vim.fn.globpath(',', vim.g.configPath..'/snippets/*')
		:gsub(vim.g.configPath.."/snippets/", "")
		listSnippets(text)
		vim.cmd[[set readonly]]
		vim.fn.execute("setlocal scrolloff="..height - 2)
		vim.cmd[[syntax match Snippets "│─.*\ .*\..*"]]
		vim.cmd[[syntax match Paste "│\s*PASTE"]]
		vim.cmd[[highlight def link Snippets Function]]
		vim.cmd[[highlight def Paste guifg=#fb4934 ctermfg=167]]
		vim.fn.execute(
		"nnoremap <buffer> <silent><CR> "..
		":lua require'collection'.selectSnippet()<CR>"
		)
	else
		vim.fn.execute("normal i"..topBorder.."\n")
		vim.cmd[[normal gg0]]
		newSnippet(args, filetype)
	end
end

return M
