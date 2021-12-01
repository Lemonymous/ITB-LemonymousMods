
local VERSION = "1.0.0"
---------------------------------------------------
-- mod loader fixes v1.0.0
--
-- by Lemonymous
---------------------------------------------------
-- Fixes for mod loader v 2.6.4
--
-- Environment Event Bug
--    Incorrectly fires events before and after each
--    separate boulder on the second phase of the
--    final mission.
--
---------------------------------------------------

local NULL_FUNCTION = function() end

local function override_Mission_ApplyEnvironmentEffect()
	local oldApplyEnvironmentEffect = Mission.ApplyEnvironmentEffect
	function Mission:ApplyEnvironmentEffect()
		if not self.LiveEnvironment.eventDispatched then
			self.LiveEnvironment.eventDispatched = true

			modApi.events.onPreEnvironment:dispatch()
		end

		local result = false
		if self.LiveEnvironment:IsEffect() then
			result = oldApplyEnvironmentEffect(self)
		end

		if not result then
			self.LiveEnvironment.eventDispatched = nil

			modApi.events.onPostEnvironment:dispatch()
		end

		return result
	end
end


local function onModsInitialized()
	if VERSION < modApiFixes.version then
		return
	end

	if modApiFixes.initialized then
		return
	end

	modApiFixes:finalizeInit()
	modApiFixes.initialized = true
end

modApi:addModsInitializedHook(onModsInitialized)

local isNewestVersion = false
	or modApiFixes == nil
	or modApi:isVersion(VERSION, modApiFixes.version) == false

if isNewestVersion then
	modApiFixes = modApiFixes or {}
	modApiFixes.version = VERSION

	function modApiFixes:finalizeInit()
		modApi.firePreEnvironmentHooks = NULL_FUNCTION
		modApi.firePostEnvironmentHooks = NULL_FUNCTION
		override_Mission_ApplyEnvironmentEffect()
	end
end
