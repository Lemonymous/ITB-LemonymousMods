
local path = mod_loader.mods[modApi.currentMod].scriptPath
local modApiExt = LApi.library:fetch("modApiExt/modApiExt", nil, "ITB-ModUtils")
local this = {}

local pawns = {
	lmn_ConvoyTruck = "Mission_lmn_Convoy_Destroyed",
}

function this:load()
	modApiExt:addPawnKilledHook(function(mission, pawn)
		local pawnType = pawn:GetType()
		local voice = pawns[pawnType]
		if not voice then return end
		
		local fx = SkillEffect()
		fx:AddVoice(voice, -1)
		Board:AddEffect(fx)
	end)
end

return this