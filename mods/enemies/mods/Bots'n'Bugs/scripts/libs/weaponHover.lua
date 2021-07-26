
--[[-------------------------------------------------------------------------
-- Weapon Hover v2.1 - code library
-----------------------------------------------------------------------------
	small library providing hooks for when
	weapons are hovered and unhovered
	
	
	 library dependencies:
	=======================
	libs/hooks.lua
	
	
	 request api:
	==============
	local path = mod_loader.mods[modApi.currentMod].scriptPath
	local weaponHover = require(path .."libs/weaponHover")
	
	libs/weaponHover must be requested at init at least once to automatically initialize itself and dependencies.
	
	
	-----------------
	   Method List
	-----------------
	
	
	weaponHover:addWeaponHoverHook(fn)
	==================================
	adds an event, listening to the event when a weapon gets hovered.
	
	field | type     | description
	------+----------+-------------------------------------------
	fn    | function | function to fire when the event triggers.
	------+----------+-------------------------------------------
	
	 example:
	---------
	weaponHover:addWeaponHoverHook(function(skill, skillType)
		LOG(skill.Name .." is hovered")
		LOG(skillType .." is hovered")
	end)
	
	
	weaponHover:addWeaponUnhoverHook(fn)
	====================================
	adds an event, listening to the event when a weapon gets unhovered.
	
	field | type     | description
	------+----------+-------------------------------------------
	fn    | function | function to fire when the event triggers.
	------+----------+-------------------------------------------
	
	 example:
	---------
	weaponHover:addWeaponUnhoverHook(function(skill, skillType)
		LOG(skill.Name .." is no longer hovered")
		LOG(skillType .." is no longer hovered")
	end)
	
	
	weaponHover:registerWeapon(weapon)
	==================================
	by default a skill will trigger hover/unhover events,
	but they will report that they are of type 'Skill'.
	explicitly registering a weapon lets
	the hooks return the correct weapontypes.
	you can also register upgraded weapons
	for the returned weapontype to be more specific.
	
	field  | type   | description
	-------+--------+------------------------
	weapon | string | weapontype to register
	-------+--------+------------------------
	
	 example:
	---------
	weaponHover:registerWeapon("Prime_Punchmech")
	weaponHover:registerWeapon("Prime_Punchmech_A")
	
	
	weaponHover:GetCurrent()
	========================
	returns weapon currently hovered, or nil if none are.
	
	 example:
	---------
	local skill, skillType = weaponHover:GetCurrent()
	if skill then
		LOG(skill.Name .."is currently hovered")
		LOG(skillType .."is currently hovered")
	else
		LOG(no weapon is currently hovered")
	end
	
	
	weaponHover:IsCurrent(weapon)
	=============================
	returns true if weapon is currently hovered,
	otherwise false
	
	field  | type   | description
	-------+--------+----------------------
	weapon | string | weapon type to check
	-------+--------+----------------------
	
	 example:
	----------
	if weaponHover:IsCurrent("Prime_Punchmech") then
		LOG("Prime_Punchmech is currently hovered")
	else
		LOG("Prime_Punchmech is currently not hovered")
	end
	
	
]]---------------------------------------------------------------------------

local mod = mod_loader.mods[modApi.currentMod]
local path = mod.resourcePath
local hooks = require(path .."scripts/libs/hooks")

local this = {}

local weapon_prev = {}
local weapon_curr = {}

hooks:new("WeaponHover")
hooks:new("WeaponUnhover")

function this:addWeaponHoverHook(fn)
	assert(type(fn) == 'function')
	hooks:addWeaponHoverHook(fn)
end

function this:addWeaponUnhoverHook(fn)
	assert(type(fn) == 'function')
	hooks:addWeaponUnhoverHook(fn)
end

function this:registerWeapon(weapon)
	assert(type(weapon) == 'string')
	assert(_G[weapon], "weapon not found")
	assert(type(_G[weapon].GetSkillEffect) == 'function', "weapon has no GetSkillEffect")
	
	local oldGetTipDamage = _G[weapon].GetTipDamage
	_G[weapon].GetTipDamage = function(self, pawn, ...)
		weapon_curr = {type = weapon, tbl = self}
		
		if oldGetTipDamage then
			return oldGetTipDamage(self, pawn, ...)
		end
		
		return self.TipDamage
		--return self.GetDamage and self:GetDamage(self, pawn, ...) or self.Damage
	end
end

function this:GetCurrent()
	return weapon_curr.tbl, weapon_curr.type
end

function this:IsCurrent(weapon)
	assert(type(weapon) == 'string')
	
	return weapon_curr.type == weapon
end

sdlext.addFrameDrawnHook(function()
	if weapon_prev.tbl and weapon_curr.tbl ~= weapon_prev.tbl then
		hooks:fireWeaponUnhoverHooks(weapon_prev.tbl, weapon_prev.type)
	end
	
	if weapon_curr.tbl and weapon_curr.tbl ~= weapon_prev.tbl then
		hooks:fireWeaponHoverHooks(weapon_curr.tbl, weapon_curr.type)
	end
	
	weapon_prev = weapon_curr
	weapon_curr = {}
end)

this:registerWeapon("Skill")

return this