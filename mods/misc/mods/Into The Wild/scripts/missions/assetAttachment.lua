
-- simple system to attack emitters or other init code to assets.
local path = mod_loader.mods[modApi.currentMod].scriptPath
local switch = require(path .."switch")

local this = {
	start = switch{ default = function(mission, loc) return nil end },
	update = switch{ default = function(mission, loc) return nil end },
	load = switch{ default = function(mission, loc) return nil end }
}

function this:Add(attachment)
	assert(type(attachment) == 'table')
	assert(type(attachment.id) == 'string')
	local id = attachment.id
	
	self.start[id] = attachment.OnStart or nil
	self.update[id] = attachment.OnUpdate or nil
	self.load[id] = attachment.OnLoad or nil
end

local function run(mission, name)
	if mission.AssetId ~= "" then
		this[name]:case(mission.AssetId, mission, mission.AssetLoc)
	end
	
	if mission.Criticals then
		for _, loc in ipairs(mission.Criticals) do
			this[name]:case(mission.Image, mission, loc)
		end
	end
end

local baseDeployment = Mission.BaseDeployment
function Mission:BaseDeployment(...)
	baseDeployment(self, ...)
	
	run(self, "start")
end

local baseUpdate = Mission.BaseUpdate
function Mission:BaseUpdate(...)
	baseUpdate(self, ...)
	
	run(self, "update")
end

local loadGame = LoadGame
function LoadGame(...)
	loadGame(...)
	
	modApi:runLater(function(mission)
		run(mission, "load")
	end)
end

return this