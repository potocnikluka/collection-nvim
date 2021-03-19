local terminal = require'collection.terminal'
local program = require'collection.program'
local format = require'collection.format'
local snippets = require'collection.snippets'
local M = {}

--terminal
function M.toggleTerminal()
	terminal.toggle()
end
--program running
function M.toggleErrorlist()
	program.toggle()
end
function M.runProgram(args)
	program.run(args)
end
--formating
function M.format()
	format.format()
end
--snippets
function M.snippets(args)
	snippets.snippets(args)
end
function M.pasteSnippet(args)
	snippets.pasteSnippet(args)
end
function M.snippetSelect()
	snippets.onSelect()
end

return M
