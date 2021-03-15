local terminal = require'collection.terminal'
local program = require'collection.program'
local format = require'collection.format'
local snippets = require'collection.snippets'
local M = {}

function M.toggleTerminal()
	terminal.toggle()
end
function M.toggleErrorlist()
	program.toggle()
end
function M.runProgram(args)
	program.run(args)
end
function M.format()
	format.format()
end
function M.showSnippets(args)
	snippets.show(args)
end
function M.selectSnippet()
	snippets.selection()
end
function M.saveSnippet(args)
	snippets.saveSnippet(args)
end
function M.pasteSnippet(args)
	snippets.pasteSnippet(args)
end
return M
