
----------------------------------------------------------------
-- Armor Detection v1.3 - code library
----------------------------------------------------------------
-- provides easy access to armor detection,
-- as well as a few other functions required in the process,
-- which can be useful in other contexts.
--
-- requires a mod with modApiExt for optimal result.
----------------------------------------------------------------

-------------------
-- initialization:
-------------------

-- local armorDetection = require(self.scriptPath ..'armorDetection')


------------------
-- function list:
------------------

-------------------------------------
-- armorDetection.IsArmor(pawn)
-------------------------------------
-- returns true if a pawn has armor,
-- (even if inflicted with A.C.I.D)
-------------------------------------

------------------------------------
-- armorDetection.IsBot(pawn)
------------------------------------
-- returns true if a pawn is a Bot.
------------------------------------

--------------------------------------
-- armorDetection.IsPsion(pawn)
--------------------------------------
-- returns true if a pawn is a Psion.
--------------------------------------

--------------------------------------------------------------
-- armorDetection.HasPsionLeech()
--------------------------------------------------------------
-- returns true if the player has a powered Psionic Receiver,
-- or any weapon with the same passive power.
--------------------------------------------------------------

-------------------------------------------------------------------------------
-- armorDetection.IsArmorPsion()
-------------------------------------------------------------------------------
-- returns true if an Armor Psion or another pawn with same power is on board.
-- (checks both teams, because Vek will benefit regardless)
-------------------------------------------------------------------------------

--------------------------------------------------------------------------
-- armorDetection.HasPoweredWeapon(pawn, weapon)
--------------------------------------------------------------------------
-- returns true if 'pawn' has powered 'weapon'.
-- Note:	requires any mod with modApiExt to check powered state.
--			without modApiExt, this returns true if the pawn has 'weapon'
--------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- armorDetection.HasPoweredPassive(pawn, passive)
-----------------------------------------------------------------------------------------
-- returns true if 'pawn' has a powered weapon with 'passive'.
-- Note:	requires any mod with modApiExt to check powered state.
--			without modApiExt, this returns true if the pawn has a weapon with 'passive'
-----------------------------------------------------------------------------------------

----------------------------------------------------------------
----------------------------------------------------------------

local this = {}

-- returns a string with suffixes "_A", "_B", "_AB" pruned.
local function GetBaseWeapon(weapon)
	assert(type(weapon) == 'string')
	
	if modApi:stringEndsWith(weapon, "_AB") then
		return string.sub(weapon, 1, -4)
	elseif
		modApi:stringEndsWith(weapon, "_A") or
		modApi:stringEndsWith(weapon, "_B")
	then
		return string.sub(weapon, 1, -3)
	end
	
	return weapon
end

-- returns an array of size 2 with upgrade booleans.
local function GetWeaponUpgrades(weapon)
	assert(type(weapon) == 'string')
	
	if modApi:stringEndsWith(weapon, "_AB") then
		return {true, true}
	elseif modApi:stringEndsWith(weapon, "_A") then
		return {true, false}
	elseif modApi:stringEndsWith(weapon, "_B") then
		return {false, true}
	end
	
	return {false, false}
end

-- returns true if 'weapon' has 'passive'
local function IsPassive(weapon, passive)
	assert(type(weapon) == 'string')
	assert(type(passive) == 'string')
	
	return _G[weapon].Passive == passive
end

-- returns true if 'pawn' has a powered weapon with 'passive'
--
-- deprecated function.
-- Can check if the player has a passive with IsPassiveSkill(passive).
function this.HasPoweredPassive(pawn, passive)
	assert(type(passive) == 'string')
	
	if modApiExt_internal then
		local modApiExt = modApiExt_internal.getMostRecent()
		
		local ptable = modApiExt.pawn:getSavedataTable(pawn:GetId())
		local weapons = {}
		table.insert(weapons, modApiExt.pawn:getWeaponData(ptable, "primary"))
		table.insert(weapons, modApiExt.pawn:getWeaponData(ptable, "secondary"))
		
		for _, v in ipairs(weapons) do
			if v.id and (#v.power == 0 or v.power[1] > 0) then
				local suffix = ""
				
				if v.upgrade1[1] > 0 then
					if v.upgrade2[1] > 0 then
						suffix = "_AB"
					else
						suffix = "_A"
					end
				elseif v.upgrade2[1] > 0 then
					suffix = "_B"
				end
				
				if IsPassive(v.id .. suffix, passive) then
					return true
				end
			end
		end
	else
		local pawnType = pawn:GetType()
		assert(_G[pawnType].SkillList)
		
		for _, skill in ipairs(_G[pawnType].SkillList) do
			if _G[skill].Passive == passive then
				return true
			end
		end
	end
	
	return false
end

-- returns true if 'pawn' has 'weapon' with upgrades powered.
function this.HasPoweredWeapon(pawn, weapon)
	assert(type(weapon) == 'string')
	
	if modApiExt_internal then
		local modApiExt = modApiExt_internal.getMostRecent()
		
		local ptable = modApiExt.pawn:getSavedataTable(pawn:GetId())
		local weapons = {}
		table.insert(weapons, modApiExt.pawn:getWeaponData(ptable, "primary"))
		table.insert(weapons, modApiExt.pawn:getWeaponData(ptable, "secondary"))
		
		local weaponBase = GetBaseWeapon(weapon)
		local upgrades = GetWeaponUpgrades(weapon)
		for _, v in ipairs(weapons) do
			if v.id == weaponBase and (#v.power == 0 or v.power[1] > 0) then
				local powered = true
				
				for i, u in ipairs(upgrades) do
					if u and v['upgrade'.. i][1] == 0 then
						powered = false
					end
				end
				
				return powered
			end
		end
	else
		local pawnType = pawn:GetType()
		assert(_G[pawnType].SkillList)
		
		for _, skill in ipairs(_G[pawnType].SkillList) do
			if skill == weapon then
				return true
			end
		end
	end
	
	return false
end

-- returns true if the player has a powered Psionic Receiver,
-- or any weapon with the same passive power.
--
-- deprecated function. Use IsPassiveSkill directly instead.
function this.HasPsionLeech()
	return IsPassiveSkill("Psion_Leech")
end

-- returns true if an Armor Psion or another pawn with same power is on board.
-- (checks both teams, because Vek will benefit regardless)
function this.IsArmorPsion()
	-- Psions are inactive in Test Mech.
	if IsTestMechScenario() then
		return false
	end
	
	-- even if the player has Leader == LEADER_ARMOR, Vek gains armor.
	-- so look through all pawns, not just TEAM_ENEMY
	pawns = extract_table(Board:GetPawns(TEAM_ANY))
	for _, id in ipairs(pawns) do
		local pawn = Board:GetPawn(id)
		local pawnType = pawn:GetType()
		if _G[pawnType].Leader == LEADER_ARMOR then
			return true
		end
	end
	return false
end

-- returns true if a pawn is a Bot.
function this.IsBot(pawn)
	return Board:IsPawnTeam(pawn:GetSpace(), TEAM_BOTS)
end

-- returns true if a pawn is a Psion.
function this.IsPsion(pawn)
	local leader = _G[pawn:GetType()].Leader
	return leader and leader ~= LEADER_NONE
end

-- returns true if a pawn has armor,
-- (even if inflicted with A.C.I.D)
function this.IsArmor(pawn)
	return	_G[pawn:GetType()]:GetArmor()
		
		or	pawn:IsAbility("Armored")
		
		or	(pawn:IsEnemy()					and
			not this.IsBot(pawn)			and
			not this.IsPsion(pawn)			and
			this.IsArmorPsion())
			
		or	(pawn:IsMech()					and
			IsPassiveSkill("Psion_Leech")	and
			this.IsArmorPsion())
end

return this