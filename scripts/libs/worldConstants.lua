
--------------------------------------------
-- World Constants v1.5 - code library
--
-- by Lemonymous
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

-- local worldConstants = require(self.scriptPath..'worldConstants')


--------------------------------------------------------
-- function list:
--------------------------------------------------------
-- every constant we can change has functions
-- associated with them that follows the same pattern.
-- I've documented the functions for the Speed constant.
-- reference these functions for parameter use
-- of the remaining constants.
--------------------------------------------------------


----------------------------------- CONSTANT: SPEED ------------------------------------
----------------------------------------------------------------------------------------
-- projectile/charge speed.
----------------------------

----------------------------------------------------------------------------------------
-- worldConstants:setSpeed(effect, value, isQueued)
----------------------------------------------------------------------------------------
-- sets projectile/charge speed to 'value'
--
-- arg      - type        - description
-- ------     -----------   ------------------------------------------------------------
-- effect   - SkillEffect - effect object modifying the constants.
-- value    - number      - value to set the constant to.
-- isQueued - boolean     - if the constant change should be queued. defaults to false.
----------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------
-- worldConstants:resetSpeed(effect, isQueued)
----------------------------------------------------------------------------------------
-- resets projectile/charge speed
--
-- arg      - type        - description
-- ------     -----------   ------------------------------------------------------------
-- effect   - SkillEffect - effect object modifying the constants.
-- isQueued - boolean     - if the constant change should be queued. defaults to false.
----------------------------------------------------------------------------------------

-- worldConstants:queuedSetSpeed(effect, value)		-> calls set function with isQueued = true
-- worldConstants:queuedResetSpeed(effect)			-> calls set function with isQueued = true

-------------------------------------------------------
-- worldConstants:getDefaultSpeed()
-------------------------------------------------------
-- returns the game's default projectile/charge speed.
-------------------------------------------------------



----------------------------------- CONSTANT: HEIGHT -----------------------------------
----------------------------------------------------------------------------------------
-- artillery/leap height:
-- default = 18
-----------------------------------------------

-- worldConstants:setHeight(...)
-- worldConstants:resetHeight(...)
-- worldConstants:queuedSetHeight(...)
-- worldConstants:queuedResetHeight(...)
-- worldConstants:getDefaultHeight(...)
-----------------------------------------------


----------------------------------- CONSTANT: GRAVITY ----------------------------------
----------------------------------------------------------------------------------------
-- affects artillery in strange ways.
-- default = 3
-----------------------------------------------

-- worldConstants:setGravity(...)
-- worldConstants:resetGravity(...)
-- worldConstants:queuedSetGravity(...)
-- worldConstants:queuedResetGravity(...)
-- worldConstants:getDefaultGravity(...)
-----------------------------------------------


------------------------------- CONSTANT: LASER DURATION -------------------------------
----------------------------------------------------------------------------------------
-- the duration of a laser shot.
-- default = 0.5
-----------------------------------------------

-- worldConstants:setLaserDuration(...)
-- worldConstants:resetLaserDuration(...)
-- worldConstants:queuedSetLaserDuration(...)
-- worldConstants:queuedResetLaserDuration(...)
-- worldConstants:getDefaultLaserDuration(...)
-----------------------------------------------


----------------------------------------------------------------
----------------------------------------------------------------

local default = {}
local worldConstants = {}

-- sets up all functions for a certain constant.
function worldConstants:addConstant(name, const)
	Assert.Equals('string', type(name), "Argument #1")
	Assert.Equals('string', type(const), "Argument #2")

	name = name:gsub("^.", string.upper) -- capitalize first letter

	default[const] = Values[const]
	local getDefaultConstant = "getDefault".. name
	local setConstant = "set".. name
	local resetConstant = "reset".. name
	local queuedSetConstant = "queuedSet".. name
	local queuedResetConstant = "queuedReset".. name

	self[getDefaultConstant] = function(self)
		return default[const]
	end

	self[setConstant] = function(self, effect, value, isQueued)
		Assert.Equals('table', type(self), "Argument #1")
		Assert.Equals('userdata', type(effect), "Argument #2")
		Assert.Equals('number', type(value), "Argument #3")
		Assert.Equals({'nil', 'boolean'}, type(isQueued), "Argument #4")

		local AddScript = isQueued and "AddQueuedScript" or "AddScript"
		effect[AddScript](effect, string.format("Values.%s = %s", const, value))
	end

	self[resetConstant] = function(self, effect, isQueued)
		Assert.Equals('table', type(self), "Argument #1")
		Assert.Equals('userdata', type(effect), "Argument #2")
		Assert.Equals({'nil', 'boolean'}, type(isQueued), "Argument #3")

		local AddScript = isQueued and "AddQueuedScript" or "AddScript"
		effect[AddScript](effect, string.format("Values.%s = %s", const, default[const]))
	end

	self[queuedSetConstant] = function(self, effect, value)
		return self[setConstant](self, effect, value, true)
	end

	self[queuedResetConstant] = function(self, effect)
		return self[resetConstant](self, effect, true)
	end
end

worldConstants:addConstant("Speed", "x_velocity")
worldConstants:addConstant("Height", "y_velocity")
worldConstants:addConstant("Gravity", "gravity")
worldConstants:addConstant("LaserDuration", "laser_length")

return worldConstants
