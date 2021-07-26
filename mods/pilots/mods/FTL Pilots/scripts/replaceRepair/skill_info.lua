
local path = mod_loader.mods[modApi.currentMod].scriptPath
local uiVisiblePawn = require(path .."replaceRepair/lib/uiVisiblePawn")
local this = {}

function this:Override()
	local old = GetSkillInfo
	function GetSkillInfo(skill)
		local pawn = uiVisiblePawn()
		local new
		
		for _, v in ipairs(lmn_replaceRepair.swaps) do
			if skill == v.PilotSkill then
				if pawn and v.IsActive(pawn) then
					return PilotSkill(v.Name, v.Description)
				else
					new = PilotSkill(v.Name, v.Description)
				end
			end
		end
		
		if new then return new end
		
		return old(skill)
	end
end

return this
