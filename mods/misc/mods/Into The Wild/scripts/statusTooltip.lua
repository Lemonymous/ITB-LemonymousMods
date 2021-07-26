
---------------------------------------------------------------------
-- Status Tooltip v1.0 - code library
---------------------------------------------------------------------
-- provides a function for swapping tooltips of traits

local path = mod_loader.mods[modApi.currentMod].resourcePath
local selected = require(path .."scripts/selected")
local highlighted = require(path .."scripts/highlighted")
tips = {}

local oldGetStatusTooltip = GetStatusTooltip
function GetStatusTooltip(id, ...)
	local selected = selected:Get()
	local desc = selected and tips[id] and tips[id][selected:GetType()]
	
	if desc then
		return desc
	end
	
	return oldGetStatusTooltip(id, ...)
end

function add(pawnType, id, desc)
	assert(type(id) == 'string')
	assert(type(desc) == 'table')
	assert(type(desc[1]) == 'string')
	assert(type(desc[2]) == 'string')
	
	tips[id] = tips[id] or {}
	tips[id][pawnType] = desc
end

return add