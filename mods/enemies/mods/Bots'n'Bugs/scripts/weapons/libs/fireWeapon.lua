
-- provides functionality for a pawn to fire an arbitrary weapon

local mod = mod_loader.mods[modApi.currentMod]
local path = mod.scriptPath .."weapons/"
local weapons = require(path .."libs/getWeapons")
local this = {}

local function pointlist_contains(list, obj)
	for i = 1, list:size() do
		if obj == list:index(i) then return true end
	end
	
	return false
end

function this.CanFire(pawnId, weapon, p2)
	assert(type(pawnId) == 'number')
	assert(type(weapon) == 'string')
	assert(type(p2) == 'userdata')
	
	assert(_G[weapon])
	assert(_G[weapon].GetTargetArea)
	assert(_G[weapon].GetSkillEffect)
	
	local pawn = Board:GetPawn(pawnId)
	if not pawn then return end
	
	local p1 = pawn:GetSpace()
	return pointlist_contains(_G[weapon]:GetTargetArea(p1), p2)
end

function this.Fire(pawnId, weapon, p2)
	assert(type(pawnId) == 'number')
	assert(type(weapon) == 'string')
	assert(type(p2) == 'userdata')
	
	assert(_G[weapon])
	assert(_G[weapon].GetTargetArea)
	assert(_G[weapon].GetSkillEffect)
	
	if not this.CanFire(pawnId, weapon, p2) then return end
	
	local old, Pawn = Pawn, Board:GetPawn(pawnId)
	local p1 = Pawn:GetSpace()
	local fx = _G[weapon]:GetSkillEffect(p1, p2)
	
	if not fx.effect:empty() or fx.q_effect:empty() then
		local weapons = weapons.GetPowered(pawnId)
		
		Pawn:AddWeapon(weapon)
		Pawn:FireWeapon(p2, #weapons + 1)
		Pawn:RemoveWeapon(#weapons + 1)
	end
	
	Pawn = old
end

return this
