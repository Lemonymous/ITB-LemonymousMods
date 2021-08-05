
--------------------------------------------
-- Weapon Armed - code library
--------------------------------------------
-- provides hooks for when a weapon is
-- being armed and unarmed.
--------------------------------------------
--------------------------------------------

-------------------------------
-- initialization and loading:
--[[---------------------------

	-- in init.lua
	local weaponArmed

	-- in init.lua - function init:
	weaponArmed = require(self.scriptPath .."weaponArmed")
	weaponArmed:init(self)

	-- in init.lua - function load:
	weaponArmed:load(modApiExt)
	
	
	-- after you have initialized and loaded it,
	-- you can request it again in your weapons with:
	local weaponArmed = require(self.scriptPath .."weaponArmed")
	
]]-----------------------------

------------------
-- function list:
------------------

-----------------------------------------------------------
-- weaponArmed:Add(weapon, onArmedFunc, onUnarmedFunc)
--[[-------------------------------------------------------
	calls provided functions when weapon is armed/unarmed.
	
	example:
	
	weaponArmed:Add(
		"Prime_Punchmech",
		function(self, type)
			LOG("weapon ".. type .." with name ".. self.Name .." armed")
		end,
		function(self, type)
			LOG("weapon ".. type .." with name ".. self.Name .." unarmed")
		end
	)
	
]]---------------------------------------------------------

-----------------------------------------
-- weaponArmed:GetPawn()
--[[-------------------------------------
	returns the selected pawn.
	regardless if weapon is armed or not
]]---------------------------------------

-----------------------------------------------------------
-- weaponArmed:GetCurrent()
--[[-------------------------------------------------------
	returns weapon currently armed, or nil if none are.
	
	example:
	
	local skill, skillType = weaponArmed:GetCurrent()
	if skill then
		LOG(skill.Name .."is currently armed")
		LOG(skillType .."is currently armed")
	else
		LOG(no weapon is currently armed")
	end
	
]]---------------------------------------------------------

-----------------------------------------------------------
-- weaponArmed:IsCurrent(weapon)
--[[-------------------------------------------------------
	returns true if weapon is currently armed,
	otherwise false
	
	example:
	
	if weaponArmed:IsCurrent("Prime_Punchmech") then
		LOG("Prime_Punchmech is currently armed")
	else
		LOG("Prime_Punchmech is currently not armed")
	end
	
]]---------------------------------------------------------

local mod = mod_loader.mods[modApi.currentMod]
local resourcePath = mod.resourcePath
local scriptPath = mod.scriptPath

local modApiExt = LApi.library:fetch("ITB-ModUtils/modApiExt/modApiExt")

local this = {
	prev = {},
	weapon = {},
	weapons = {}
}

local function GetArmedWeapon(pawn)
	if not pawn then return {} end
	
	local wID = pawn:GetArmedWeaponId()
	local weapons = modApiExt.pawn:getWeapons(pawn:GetId())
	
	if weapons[wID] then
		return {type = weapons[wID], tbl = _G[weapons[wID]]}
	end
	
	return {}
end

function this:Add(weapon, onArmedFunc, onUnarmedFunc)
	assert(type(weapon) == 'string')
	assert(_G[weapon])
	assert(type(_G[weapon].GetSkillEffect) == 'function')
	assert(not onArmedFunc or type(onArmedFunc) == 'function')
	assert(not onUnarmedFunc or type(onUnarmedFunc) == 'function')
	
	onArmedFunc = onArmedFunc or function() end
	onUnarmedFunc = onUnarmedFunc or function() end
	self.weapons[weapon] = self.weapons[weapon] or {}
	table.insert(
		self.weapons[weapon],
		{
			onArmed = onArmedFunc,
			onUnarmed = onUnarmedFunc
		}
	)
end

function this:GetPawn()
	return self.selected
end

function this:GetCurrent()
	local weapon = GetArmedWeapon(self.selected)
	
	return weapon.tbl, weapon.type
end

function this:IsCurrent(weapon)
	assert(type(weapon) == 'string')
	
	return GetArmedWeapon(self.selected).type == weapon
end

sdlext.addGameExitedHook(function()
	this.selected = nil
end)

sdlext.addFrameDrawnHook(function()
	this.weapon = GetArmedWeapon(this.selected)
	
	if
		this.prev.tbl						and
		this.weapon.tbl ~= this.prev.tbl	and
		this.weapons[this.prev.type]
	then
		for _, v in ipairs(this.weapons[this.prev.type]) do
			v.onUnarmed(this.prev.tbl, this.prev.type)
		end
	end
	
	if
		this.weapon.tbl						and
		this.weapon.tbl ~= this.prev.tbl	and
		this.weapons[this.weapon.type]
	then
		for _, v in ipairs(this.weapons[this.weapon.type]) do
			v.onArmed(this.weapon.tbl, this.weapon.type)
		end
	end
	
	this.prev = this.weapon
	this.weapon = {}
end)

function this:init() end
function this:load()
	modApiExt:addPawnSelectedHook(function(_, pawn) self.selected = pawn end)
	modApiExt:addPawnDeselectedHook(function() self.selected = nil end)
	modApi:addTestMechEnteredHook(function() modApi:runLater(function() self.selected = Board:GetPawn(0) or Board:GetPawn(1) or Board:GetPawn(2) end) end)
	modApi:addTestMechExitedHook(function() self.selected = nil end)
end

return this
