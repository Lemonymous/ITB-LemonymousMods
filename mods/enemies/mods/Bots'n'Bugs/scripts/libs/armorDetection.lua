
----------------------------------------------------------------
-- Armor Detection v1.4 - code library
--[[------------------------------------------------------------
	provides easy access to armor detection.
	
	
	[several unneeded functions has been removed since 1.3.
	if you needed those functions, that library still works exactly as this version.
	this is just more lightweight and too the point.]
	
	
	
	 request lib:
	==============
	local path = mod_loader.mods[modApi.currentMod].scriptPath
	local armorDetection = require(path ..'armorDetection')
	
	
	-----------------
	   Method List
	-----------------
	
	
	armorDetection.IsArmor(pawn)
	============================
	returns true if a pawn has armor,
	(even if inflicted with A.C.I.D)
	
	field | type     | description
	------+----------+-----------------------
	pawn  | userdata | pawn we want to check
	------+----------+-----------------------
	
	
	
	armorDetection.IsBot(pawn)
	==========================
	returns true if a pawn is a Bot.
	
	field | type     | description
	------+----------+-----------------------
	pawn  | userdata | pawn we want to check
	------+----------+-----------------------
	
	
	
	armorDetection.IsPsion(pawn)
	============================
	returns true if a pawn is a Psion.
	
	field | type     | description
	------+----------+-----------------------
	pawn  | userdata | pawn we want to check
	------+----------+-----------------------
	
	
	
	armorDetection.IsArmorPsion(pawn)
	=================================
	returns true if an Armor Psion or another pawn with same power is on board.
	(checks both teams, because Vek will benefit regardless)
	
	field | type     | description
	------+----------+-----------------------
	pawn  | userdata | pawn we want to check
	------+----------+-----------------------
	
	
]]---------------------------------------------------------------------------

local this = {}

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