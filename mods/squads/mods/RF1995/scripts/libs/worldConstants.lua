
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

-- sets projectile and charge speed to 'value'
function this.SetSpeed(effect, value)
	assert(type(value) == 'number')
	assert(
		not orig_world_constants.speed,
		"Attempted to SetSpeed multiple times without using ResetSpeed inbetween.")
	
	orig_world_constants.speed = Values.x_velocity;
	effect:AddScript("Values.x_velocity = ".. value)
end

-- resets projectile and charge speed
function this.ResetSpeed(effect)
	assert(
		orig_world_constants.speed,
		"Attempted to ResetSpeed without using SetSpeed first.")
	
	effect:AddScript("Values.x_velocity = ".. orig_world_constants.speed)
	orig_world_constants.speed = nil
end

-- sets artillery height to 'value'
function this.SetHeight(effect, value)
	assert(type(value) == 'number')
	assert(
		not orig_world_constants.height,
		"Attempted to SetHeight multiple times without using ResetHeight inbetween.")
	
	orig_world_constants.height = Values.y_velocity;
	effect:AddScript("Values.y_velocity = ".. value)
end

-- resets artillery height
function this.ResetHeight(effect)
	assert(
		orig_world_constants.height,
		"Attempted to ResetHeight without using SetHeight first.")
	
	effect:AddScript("Values.y_velocity = ".. orig_world_constants.height)
	orig_world_constants.height = nil
end

-- sets gravity to 'value'
function this.SetGravity(effect, value)
	assert(type(value) == 'number')
	assert(
		not orig_world_constants.gravity,
		"Attempted to SetGravity multiple times without using ResetGravity inbetween.")
	
	orig_world_constants.gravity = Values.gravity;
	effect:AddScript("Values.gravity = ".. value)
end

-- resets gravity
function this.ResetGravity(effect)
	assert(
		orig_world_constants.gravity,
		"Attempted to ResetGravity without using SetGravity first.")
	
	effect:AddScript("Values.gravity = ".. orig_world_constants.gravity)
	orig_world_constants.gravity = nil
end

return this
