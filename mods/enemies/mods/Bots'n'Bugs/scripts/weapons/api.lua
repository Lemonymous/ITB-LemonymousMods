
--[[-----------------------------------------------------------------------------
	Weapons v1.3 - a code library for Into the Breach.
	
	API for
	 - causing a pawn to fire an arbitrary weapon, regardless if it is equipped or not.
	 - listing a pawn's equipped and powered weapons.
	 - listing a pawn's equipped and powered weapons at base level.
	 - listing a pawn's equipped and powered weapons at current upgrade level.
	
	-- requires LApi
	
	 request api:
	==============
	local path = mod_loader.mods[modApi.currentMod].scriptPath
	local weaponApi = require(path .."weapons/api")
	
	NOTE:
	requesting the api will initialize the library.
	
	
	-----------------
	   Method List
	-----------------
	weaponApi.CanFire(pawnId, weapon, loc)
	weaponApi.Fire(pawnId, weapon, loc)
	weaponApi.Get(pawnId)
	weaponApi.GetBase(pawnId)
	weaponApi.GetCurrent(pawnId)
	
	
	
	weaponApi.CanFire(pawnId, weapon, loc)
	===================================
	returns true if pawn can fire weapon targeting 'loc'.
	
	field  | type   | description
	-------+--------+----------------------------------
	pawnId | number | pawnId of pawn firing the weapon
	weapon | string | table id of weapon being fired
	loc    | Point  | target location
	-------+--------+----------------------------------
	
	 example:
	----------
	local p1 = Board:GetPawn(0):GetSpace()
	local p2 = pawn:GetSpace() + VEC_UP
	LOG("Can pawn at ".. p1:GetString() .." fire at ".. loc:GetString() .."? - Answer: ".. tostring(weaponApi.CanFire(0, "Prime_PunchMech", p2)))
	
	
	
	weaponApi.Fire(pawnId, weapon, loc)
	===================================
	causes pawn to fire a weapon, targeting 'loc'.
	
	field  | type   | description
	-------+--------+----------------------------------
	pawnId | number | pawnId of pawn firing the weapon
	weapon | string | table id of weapon being fired
	loc    | Point  | target location
	-------+--------+----------------------------------
	
	 example:
	----------
	local loc = pawn:GetSpace() + VEC_UP
	weaponApi.Fire(0, "Prime_PunchMech", loc)
	
	
	
	weaponApi.Get(pawnId)
	=====================
	returns a table with the fields 'base' and 'weapon',
	where 'base' contains a pawn's equipped weapons at base level,
	and 'weapon' contains a pawn's equipped weapons at current upgrade level.
	
	field  | type   | description
	-------+--------+----------------
	pawnId | number | pawnId of pawn
	-------+--------+----------------
	
	
	 example:
	----------
	local weapons = weaponApi.Get(0)
	LOG("base:".. save_table(weapons.base))
	LOG("current:".. save_table(weapons.curr))
	
	
	
	weaponApi.GetBase(pawnId)
	=========================
	returns a table of a pawns equipped weapons at base level.
	
	field  | type   | description
	-------+--------+----------------
	pawnId | number | pawnId of pawn
	-------+--------+----------------
	
	
	 example:
	----------
	local base = weaponApi.GetBase(0)
	LOG("base:".. save_table(base))
	
	
	
	weaponApi.GetCurrent(pawnId)
	============================
	returns a table of a pawns equipped weapons at current upgrade level.
	
	field  | type   | description
	-------+--------+----------------
	pawnId | number | pawnId of pawn
	-------+--------+----------------
	
	
	 example:
	----------
	local current = weaponApi.GetCurrent(0)
	LOG("current:".. save_table(current))
	
	
]]-------------------------------------------------------------------------------

local mod = mod_loader.mods[modApi.currentMod]
local path = mod.scriptPath .."weapons/"
local fireWeapon = require(path .."libs/fireWeapon")
local getWeapons = require(path .."libs/getWeapons")
local this = {}

this.CanFire = fireWeapon.CanFire
this.Fire = fireWeapon.Fire

function this.Get(...)
	assert(not IsTestMechScenario(), " this function cannot be used in test mech scenario.")
	return getWeapons.GetPowered(...)
end

function this.GetBase(...)
	assert(not IsTestMechScenario(), " this function cannot be used in test mech scenario.")
	return getWeapons.GetPoweredBase(...)
end

function this.GetCurrent(...)
	assert(not IsTestMechScenario(), " this function cannot be used in test mech scenario.")
	return getWeapons.GetPoweredUpgraded(...)
end

return this