
local modApiExt = LApi.library:fetch("modApiExt/modApiExt", nil, "ITB-ModUtils")
local teamTurn = {}

function teamTurn:isVekTurn()
	local mission = GetCurrentMission()
	if not mission then return nil end
	
	return (mission.lmn_VekTurnCount or 0) == Game:GetTurnCount()
end

function teamTurn:isVekMovePhase()
	local mission = GetCurrentMission()
	if not mission then return nil end
	
	return (mission.lmn_VekMovePhase or -1) == Game:GetTurnCount()
end

function teamTurn:isPlayerTurn()
	local mission = GetCurrentMission()
	if not mission then return nil end

	return (mission.lmn_VekTurnCount or 0) < Game:GetTurnCount()
end

local applyEnvironmentEffect = Mission.ApplyEnvironmentEffect
function Mission:ApplyEnvironmentEffect(...)
	local ret = applyEnvironmentEffect(self, ...)
	
	self.lmn_VekTurnCount = Game:GetTurnCount()
	
	return ret
end

local function onModsLoaded()
	modApiExt:addVekMoveStartHook(function(mission)
		mission.lmn_VekMovePhase = Game:GetTurnCount()
	end)
end

modApi.events.onModsLoaded:subscribe(onModsLoaded)

return teamTurn
