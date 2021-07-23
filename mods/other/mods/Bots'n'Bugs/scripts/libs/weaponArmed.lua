
--[[-------------------------------------------------------------------------
-- Weapon Armed v2.2 - code library
-----------------------------------------------------------------------------
	small library providing hooks for when
	weapons are armed and unarmed
	
	
	 library dependencies:
	=======================
	modApiExt				- manual init/load
	libs/selected.lua		- auto init/manual load
	libs/hooks.lua			- auto init/no load
	
	
	 request api:
	==============
	local path = mod_loader.mods[modApi.currentMod].scriptPath
	local weaponArmed = require(path .."libs/weaponArmed")
	
	libs/weaponArmed.lua must be requested at init at least once to automatically initialize itself and dependencies.
	libs/selected.lua must be loaded separately.
	
	
	-----------------
	   Method List
	-----------------
	
	
	weaponArmed:addWeaponArmedHook(fn)
	==================================
	adds an event, listening to the event when a weapon gets armed.
	
	field | type     | description
	------+----------+-------------------------------------------
	fn    | function | function to fire when the event triggers.
	------+----------+-------------------------------------------
	
	 example:
	---------
	weaponArmed:addWeaponArmedHook(function(skill, skillType)
		LOG(skill.Name .." is armed")
		LOG(skillType .." is armed")
	end)
	
	
	weaponArmed:addWeaponUnarmedHook(fn)
	====================================
	adds an event, listening to the event when a weapon gets unarmed.
	
	field | type     | description
	------+----------+-------------------------------------------
	fn    | function | function to fire when the event triggers.
	------+----------+-------------------------------------------
	
	 example:
	---------
	weaponArmed:addWeaponUnarmedHook(function(skill, skillType)
		LOG(skill.Name .." is unarmed")
		LOG(skillType .." is unarmed")
	end)
	
	
	weaponArmed:GetCurrent()
	========================
	returns weapon currently armed, or nil if none are.
	
	 example:
	---------
	local skill, skillType = weaponArmed:GetCurrent()
	if skill then
		LOG(skill.Name .."is currently armed")
		LOG(skillType .."is currently armed")
	else
		LOG(no weapon is currently armed")
	end
	
	
	weaponArmed:IsCurrent(weapon)
	=============================
	returns true if weapon is currently armed,
	otherwise false
	
	field  | type   | description
	-------+--------+----------------------
	weapon | string | weapon type to check
	-------+--------+----------------------
	
	 example:
	----------
	if weaponArmed:IsCurrent("Prime_Punchmech") then
		LOG("Prime_Punchmech is currently armed")
	else
		LOG("Prime_Punchmech is currently not armed")
	end
	
	
]]---------------------------------------------------------------------------

local mod = mod_loader.mods[modApi.currentMod]
local path = mod.resourcePath
local modUtils = require(path .."scripts/modApiExt/modApiExt")
local selected = require(path .."scripts/libs/selected")
local hooks = require(path .."scripts/libs/hooks")

local this = {}

hooks:new("WeaponArmed")
hooks:new("WeaponUnarmed")

function this:addWeaponArmedHook(fn)
	assert(type(fn) == 'function')
	hooks:addWeaponArmedHook(fn)
end

function this:addWeaponUnarmedHook(fn)
	assert(type(fn) == 'function')
	hooks:addWeaponUnarmedHook(fn)
end

local function GetArmedWeapon()
	local selected = selected:Get()
	
	if not selected then
		return {}
	end
	
	local wID = selected:GetArmedWeaponId()
	local weapons = modUtils.pawn:getWeapons(selected:GetId())
	
	if weapons[wID] then
		return {type = weapons[wID], tbl = _G[weapons[wID]]}
	end
	
	return {}
end

-- returns currently armed weapon.
function this:GetCurrent()
	local weapon = GetArmedWeapon()
	
	return weapon.tbl, weapon.type
end

-- returns true if input weapon is currently armed.
function this:IsCurrent(weapon)
	assert(type(weapon) == 'string')
	
	return GetArmedWeapon().type == weapon
end

local weapon_prev = {}
sdlext.addFrameDrawnHook(function()
	local weapon = GetArmedWeapon()
	
	if weapon_prev.tbl and weapon.tbl ~= weapon_prev.tbl then
		hooks:fireWeaponUnarmedHooks(weapon_prev.tbl, weapon_prev.type)
	end
	
	if weapon.tbl and weapon.tbl ~= weapon_prev.tbl then
		hooks:fireWeaponArmedHooks(weapon.tbl, weapon.type)
	end
	
	weapon_prev = weapon
end)

return this