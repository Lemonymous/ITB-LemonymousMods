
---------------------------------------------------------------------
-- getWeapons v1.3 - code library
--[[-----------------------------------------------------------------
	provides functions for finding a pawn's equipped weapons
	during missions.
	
	requires modApiExt loaded to function.
]]
local mod = mod_loader.mods[modApi.currentMod]
local modUtils = require(mod.scriptPath .."modApiExt/modApiExt")
local this = {}

local function getWeapons(pawnId)
	pawnId = (type(pawnId) == 'userdata') and pawnId:GetId() or pawnId
	assert(type(pawnId) == 'number')
	
	local ptable = modUtils.pawn:getSavedataTable(pawnId)
	if not ptable then return {} end
	
	local weapons = {}
	weapons[1] = modUtils.pawn:getWeaponData(ptable, "primary") or {}
	weapons[2] = modUtils.pawn:getWeaponData(ptable, "secondary") or {}
	
	return weapons
end

-- returns a size 0-2 table with a pawn's base and upgraded weapons.
-- table will be empty outside of missions with available save data.
function this.GetPowered(pawnId)
	local ret = {}
	local pawn = Board:GetPawn(pawnId)
	if not pawn then return ret end
	
	-- if not a mech with purchaseable weaponry
	if pawnId > 2 then
		-- get weapons from default pawn table.
		local pData = _G[pawn:GetType()]
		for i, weapon in ipairs(pData.SkillList) do
			ret[i] = {
				base = weapon,
				weapon = weapon
			}
		end
		
		return ret
	end
	
	local weapons = getWeapons(pawnId)
	
	for i = 1, #weapons do
		
		-- if 'powered' array's first core is powered.
		local power = weapons[i].power or {0}
		if #power == 0 or power[1] > 0 then
			ret[i] = {}
			local w = ret[i]
			w.base = weapons[i].id
			w.curr = weapons[i].id
			local upg = "_"
			
			-- if 'upgrade1' array's first core is powered.
			local upgrade = weapons[i].upgrade1 or {0}
			if #upgrade == 0 or upgrade[1] > 0 then
				upg = upg .."A"
			end
			
			-- if 'upgrade2' array's first core is powered.
			local upgrade = weapons[i].upgrade2 or {0}
			if #upgrade == 0 or upgrade[1] > 0 then
				upg = upg .."B"
			end
			
			w.curr = upg:len() > 1 and w.curr .. upg or w.curr
		end
	end
	
	return ret
end

-- returns a size 0-2 table with a pawn's base weapons.
-- table will be empty outside of missions with available save data.
function this.GetPoweredBase(pawnId)
	local ret = {}
	for i, v in ipairs(this.GetPowered(pawnId)) do
		ret[i] = v.base
	end
	
	return ret
end

-- returns a size 0-2 table with a pawn's upgraded weapons.
-- table will be empty outside of missions with available save data.
function this.GetPoweredUpgraded(pawnId)
	local ret = {}
	for i, v in ipairs(this.GetPowered(pawnId)) do
		ret[i] = v.curr
	end
	
	return ret
end

return this
