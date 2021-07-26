
local path = mod_loader.mods[modApi.currentMod].scriptPath
local getModUtils = require(path .."getModUtils")
local utils = require(path .."utils")
local this = {}

local missions = {
	"Mission_lmn_Geothermal_Plant",
	"Mission_lmn_Greenhouse",
	"Mission_lmn_Agroforest",
	"Mission_lmn_Hotel"
}

function lmn_Jungle_Structure_Voice(id)
	local fx = SkillEffect()
	fx:AddVoice(id .."_Destroyed", -1)
	Board:AddEffect(fx)
end

function this:load()
	local modUtils = getModUtils()
	
	modUtils:addSkillBuildHook(function(mission, pawn, weaponId, p1, p2, skillEffect)
		if not mission then return end
		if not list_contains(missions, mission.ID) then return end
		if utils.IsTipImage() then return end
		
		local criticals = shallow_copy(mission.Criticals)
		local script = ""
		
		for i,p in ipairs(criticals) do
			if not Board:IsDamaged(p) then
				script = script .. string.format([[
					modApi:conditionalHook(
						function()
							return not Board or not Board:IsBusy();
						end,
						function()
							if Board then
								local p, mID, fx = %s, %q, SkillEffect();
								fx:AddScript(string.format("if Board:IsDamaged(%%s) then lmn_Jungle_Structure_Voice(%%q) end", p:GetString(), mID));
								Board:AddEffect(fx);
							end
						end
					)
				]], p:GetString(), mission.ID)
			end
		end
		
		if script == "" then return end
		if skillEffect.effect:size() > 0 then skillEffect:AddScript(script) end
		if skillEffect.q_effect:size() > 0 then skillEffect:AddQueuedScript(script) end
	end)
	
end

return this