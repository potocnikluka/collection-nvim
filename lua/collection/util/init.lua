local popup = require 'collection.util.popup'
local M = {}

function M.createPopup(name, info, onCreation)
	popup.createPopup(name, info, onCreation)
end
function M.getFiletype(fl)
	if fl == 'py' then
		return 'python'
	elseif fl == 'th' then
		return 'typescript'
	elseif fl == 'js' then
		return 'javascript'
	else
		return fl
	end
end
return M
