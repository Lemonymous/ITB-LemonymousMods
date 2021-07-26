
local path = mod_loader.mods[modApi.currentMod].scriptPath
local spaceDamageObjects = require(path .."spaceDamageObjects")
local getModUtils = require(path .."getModUtils")
local this = {}

-- insert into missionEnd to fire pawnKilledHooks on minor enemies killed instead of retreating.
--[[local pawn = Board:GetPawn(effect.loc)
local pawnType = pawn:GetType()
if _G[pawnType].Minor or _G[pawnType].SpawnLimit == false then
	effect.sScript = string.format("modApiExt_internal.firePawnKilledHooks(GetCurrentMission(), Board:GetPawn(%s))", effect.loc:GetString())
else
	effect.sScript = ""
end]]

--[[sdlext.addFrameDrawnHook(function()
	if
		not Board				or
		not GAME				or
		not GAME.trackedPawns
	then
		return
	end
	
	for id, pd in pairs(GAME.trackedPawns) do
		local pawn = Board:GetPawn(id)
		
		if not pd.dead and pawn:GetHealth() == 0 then
			local petals = _G[pawn:GetType()].lmn_PetalsOnDeath
			if petals then
				local loc = pawn:GetSpace()
				Board:DamageSpace(spaceDamageObjects.Emitter(loc, petals))
			end
		end
	end
end)]]

function this:load()
	local modUtils = getModUtils()
	
	modUtils:addPawnKilledHook(function(_, pawn)
		local petals = _G[pawn:GetType()].lmn_PetalsOnDeath
		if petals then
			local loc = pawn:GetSpace()
			Board:DamageSpace(spaceDamageObjects.Emitter(loc, petals))
		end
	end)
end

return this