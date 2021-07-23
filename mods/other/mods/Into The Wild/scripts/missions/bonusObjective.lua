
local path = mod_loader.mods[modApi.currentMod].scriptPath
local switch = require(path .."switch")

local this = {
	status		= switch{ default = function(mission, obj, endstate) return nil end },
	objective	= switch{ default = function(mission, obj) return nil end },
	update		= switch{ default = function(mission, obj) return nil end },
	endstate	= switch{ default = function(mission, obj, endstate) return nil end }
}

local getBonusStatus = Mission.GetBonusStatus
function Mission.GetBonusStatus(self, obj, endstate, ...)
	local ret = getBonusStatus(self, obj, endstate, ...)
	local status = this.status:case(obj, self, obj, endstate)
	
	if status then return status end
	
	return ret
end

local getBonusObjective = Mission.GetBonusObjective
function Mission.GetBonusObjective(self, obj, ...)
	local ret = getBonusObjective(self, obj, ...)
	local objective = this.objective:case(obj, self, obj)
	
	if objective then return objective end
	
	return ret
end

local baseObjectives = Mission.BaseObjectives
function Mission.BaseObjectives(self, ...)
	local ret = baseObjectives(self, ...)
	
	for _, obj in ipairs(self.BonusObjs) do
		this.update:case(obj, self, obj)
	end
	
	return ret
end

local getBonusInfo = Mission.GetBonusInfo
function Mission.GetBonusInfo(self, endstate, ...)
	for _, obj in ipairs(self.BonusObjs) do
		local endstate = this.endstate:case(obj, self, obj, endstate)
		
		if endstate then return endstate end
	end
	
	return getBonusInfo(self, endstate, ...)
end

function this:Add(bonus)
	assert(type(bonus) == 'table')
	assert(type(bonus.id) == 'string')
	local id = bonus.id
	
	self.status[id] = bonus.GetStatus
	self.objective[id] = bonus.GetObjective
	self.update[id] = bonus.Update
	self.endstate[id] = bonus.GetInfo
end

return this