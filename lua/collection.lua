local terminal = require'collection.terminal'
local program = require'collection.program'
local format = require'collection.format'
local M = {}

local termInfo = {}
termInfo['termWin'] = 0
termInfo['termBuf'] = 0
local progInfo = {}
progInfo['progBuf'] = 0
progInfo['progWin'] = 0

function M.toggleTerminal()
	terminal.toggle(termInfo)
end
function M.toggleErrorlist()
	program.toggle(progInfo)
end
function M.runProgram(args)
	program.run(args, progInfo)
end
function M.format(dontFormat)
	format.format(dontFormat)
end
return M
