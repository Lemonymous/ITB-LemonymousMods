
--------------------------------------------
-- Weapon Hover - code library
--------------------------------------------
-- provides hooks for when a weapon is
-- being hovered and unhovered.
--------------------------------------------
--------------------------------------------

-------------------------------
-- initialization and loading:
--[[---------------------------

	-- in init.lua
	local weaponHover

	-- in init.lua - function init:
	weaponHover = require(self.scriptPath .."weaponHover")
	weaponHover:init(self)
	
	
	-- after you have initialized and loaded it,
	-- you can request it again in your weapons with:
	local weaponHover = require(self.scriptPath .."weaponHover")
	
]]-----------------------------

------------------
-- function list:
------------------

-----------------------------------------------------------
-- weaponHover:Add(weapon, onHoverFunc, onUnhoverFunc)
--[[-------------------------------------------------------
	overrides a weapon's GetTipDamage function in order to
	detect when a weapon is being hovered, calling provided
	functions when it is hovered/unhovered.
	
	example:
	
	weaponHover:Add(
		"Prime_Punchmech",
		function(self, type)
			LOG("weapon ".. type .." with name ".. self.Name .." hovered")
		end,
		function(self, type)
			LOG("weapon ".. type .." with name ".. self.Name .." unhovered")
		end
	)
	
]]---------------------------------------------------------

-----------------------------------------------------------
-- weaponHover:GetCurrent()
--[[-------------------------------------------------------
	returns weapon currently being hovered,
	but only if it has been added with weaponHover:Add,
	otherwise nil.
	
	example:
	
	local skill, skillType = weaponHover:GetCurrent()
	if skill then
		LOG(skill.Name .."is currently being hovered")
		LOG(skillType .."is currently being hovered")
	else
		LOG(no tracked weapon is currently being hovered")
	end
	
]]---------------------------------------------------------

-----------------------------------------------------------
-- weaponHover:IsCurrent(weapon)
--[[-------------------------------------------------------
	returns true if weapon is currently being hovered,
	but only if it has been added with weaponHover:Add,
	otherwise false.
	
	example:
	
	if weaponHover:IsCurrent("Prime_Punchmech") then
		LOG("Prime_Punchmech is currently being hovered")
	else
		LOG("Prime_Punchmech is currently not being hovered")
	end
	
]]---------------------------------------------------------

local this = {
	prev = {},
	weapon = {},
	weapons = {}
}

function this:Add(weapon, onHoverFunc, onUnhoverFunc)
	assert(type(weapon) == 'string')
	assert(_G[weapon])
	assert(type(_G[weapon].GetSkillEffect) == 'function')
	assert(not onHoverFunc or type(onHoverFunc) == 'function')
	assert(not onUnhoverFunc or type(onUnhoverFunc) == 'function')
	
	onHoverFunc = onHoverFunc or function() end
	onUnhoverFunc = onUnhoverFunc or function() end
	self.weapons[weapon] = self.weapons[weapon] or {}
	table.insert(
		self.weapons[weapon],
		{
			onHover = onHoverFunc,
			onUnhover = onUnhoverFunc
		}
	)
	
	local this = self
	_G[weapon].GetTipDamage = function(self, pawn, ...)
		this.weapon = {type = weapon, tbl = self}
		
		return self.GetDamage and self:GetDamage(self, pawn, ...) or self.Damage
	end
end

function this:GetCurrent()
	return self.weapon.tbl, self.weapon.type
end

function this:IsCurrent(weapon)
	assert(type(weapon) == 'string')
	
	return self.weapon.type == weapon
end

sdlext.addFrameDrawnHook(function()
	if this.prev.tbl and this.weapon.tbl ~= this.prev.tbl then
		for _, v in ipairs(this.weapons[this.prev.type]) do
			v.onUnhover(this.prev.tbl, this.prev.type)
		end
	end
	
	if this.weapon.tbl and this.weapon.tbl ~= this.prev.tbl then
		for _, v in ipairs(this.weapons[this.weapon.type]) do
			v.onHover(this.weapon.tbl, this.weapon.type)
		end
	end
	
	this.prev = this.weapon
	this.weapon = {}
end)

function this:init() end
function this:load() end

return this
