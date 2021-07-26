
--------------------------------------------
-- World Constants v.1.1 - code library
--------------------------------------------
-- provides functions for setting/resetting
-- projectile/charge speed,
-- artillery/leap height,
-- gravity (strange results)
--------------------------------------------
--------------------------------------------
-- NOTE:
-- changing any constant, will affect every
-- weapon in the game.
-- to play nice with other mods, it is
-- important to reset them after each use.
--
-- to apply a new value to your weapon,
-- follow this simple checklist:
--
---------------------------------
-- 1. set the constant
-- 2. AddProjectile(.. NO_DELAY)
-- 3. reset constant
---------------------------------
--
-- always use NO_DELAY between setting and
-- resetting to ensure it all happens in a
-- single cycle.
--
--------------------------------------------
--------------------------------------------

-------------------
-- initialization:
-------------------

-- local worldConstants = require(self.scriptPath ..'worldConstants')


------------------
-- function list:
------------------

-----------------------------------------------
-- worldConstants.SetSpeed(effect, value)
-----------------------------------------------
-- sets projectile/charge speed to 'value'
-----------------------------------------------

--------------------------------------
-- worldConstants.ResetSpeed(effect)
--------------------------------------
-- resets projectile/charge speed
--------------------------------------

-------------------------------------------
-- worldConstants.SetHeight(effect, value)
-------------------------------------------
-- sets artillery/leap height to 'value'
-------------------------------------------

--------------------------------------
-- worldConstants.ResetHeight(effect)
--------------------------------------
-- resets artillery/leap height
--------------------------------------

--------------------------------------------
-- worldConstants.SetGravity(effect, value)
--------------------------------------------
-- sets gravity to 'value'
--------------------------------------------

---------------------------------------
-- worldConstants.ResetGravity(effect)
---------------------------------------
-- resets gravity
---------------------------------------

--------------------------------------
-- worldConstants.GetDefaultGravity()
--------------------------------------
-- returns the default gravity.
--------------------------------------

--------------------------------------
-- worldConstants.GetDefaultSpeed()
--------------------------------------
-- returns the default
-- projectile/charge speed.
--------------------------------------

--------------------------------------
-- worldConstants.GetDefaultHeight()
--------------------------------------
-- returns the default
-- artillery/leap height.
--------------------------------------

----------------------------------------------------------------
----------------------------------------------------------------

local default_gravity = Values["gravity"]
local default_x_velocity = Values["x_velocity"]
local default_y_velocity = Values["y_velocity"]

local this = {
	GetDefaultGravity = function() return default_gravity end,
	GetDefaultSpeed = function() return default_x_velocity end,
	GetDefaultHeight = function() return default_y_velocity end
}

local orig_world_constants = {}

function this.SetConstant(effect, name, value)
	assert(type(effect) == 'userdata')
	assert(type(name) == 'string')
	assert(type(value) == 'number')
	assert(
		not orig_world_constants[name],
		"Attempted to change constant ".. name .." multiple times without resetting it inbetween.")
	
	orig_world_constants[name] = Values[name]
	effect:AddScript("Values['".. name .."'] = ".. value)
end

function this.ResetConstant(effect, name)
	assert(type(effect) == 'userdata')
	assert(
		orig_world_constants[name],
		"Attempted to reset constant ".. name .." without setting it first.")
		
	effect:AddScript("Values['".. name .."'] = ".. orig_world_constants[name])
	orig_world_constants[name] = nil
end

function this.SetSpeed(effect, value)
	this.SetConstant(effect, 'x_velocity', value)
end

function this.ResetSpeed(effect)
	this.ResetConstant(effect, 'x_velocity')
end

function this.SetHeight(effect, value)
	this.SetConstant(effect, 'y_velocity', value)
end

function this.ResetHeight(effect)
	this.ResetConstant(effect, 'y_velocity')
end

function this.SetGravity(effect, value)
	this.SetConstant(effect, 'gravity', value)
end

function this.ResetGravity(effect)
	this.ResetConstant(effect, 'gravity')
end

return this