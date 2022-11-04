
local this = {
	bonusAll = { BONUS_KILL_FIVE, BONUS_GRID, BONUS_MECHS, BONUS_BLOCK, "lmn_bonus_specimen" },
	bonusNoBlock = { BONUS_KILL_FIVE, BONUS_GRID, BONUS_MECHS, "lmn_bonus_specimen" },
	bonusNoKill = { BONUS_GRID, BONUS_MECHS, BONUS_BLOCK, "lmn_bonus_specimen" },
	bonusNoMechs = { BONUS_KILL_FIVE, BONUS_GRID, BONUS_BLOCK, "lmn_bonus_specimen" },
}

function this.GetCompletedStatusEnvironment(self)
	local total = 0
	local potential = 0
	
	for _, obj in ipairs(self:GetBonusCompleted()) do
		total = obj.rep + total
		potential = obj.potential + potential
	end
	
	if total == potential then
		return "Success"
	end
	
	return "Failure"
end

return this