
local modApiExt = LApi.library:fetch("modApiExt/modApiExt", nil, "ITB-ModUtils")

local pawns = {
	lmn_ConvoyTruck = "Mission_lmn_Convoy_Destroyed",
}

local function onModsLoaded()
	modApiExt:addPawnKilledHook(function(mission, pawn)
		local pawnType = pawn:GetType()
		local voice = pawns[pawnType]
		if not voice then return end
		
		local fx = SkillEffect()
		fx:AddVoice(voice, -1)
		Board:AddEffect(fx)
	end)
end

modApi.events.onModsLoaded:subscribe(onModsLoaded)
