
local VERSION = "1.0.1"
---------------------------------------------------
-- mod loader fixes v1.0.1
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
-- TipImageShown & TipImageHidden Event Bug
--    These events don't fire when hovering possible
--    weapon upgrades in the Mech upgrade window.
--
---------------------------------------------------

local NULL_FUNCTION = function() end

local function override_Mission_ApplyEnvironmentEffect()
	local oldApplyEnvironmentEffect = Mission.ApplyEnvironmentEffect
	function Mission:ApplyEnvironmentEffect()
		if not self.LiveEnvironment.eventDispatched then
			self.LiveEnvironment.eventDispatched = true

			modApi.events.onPreEnvironment:dispatch(self)
		end

		local result = false
		if self.LiveEnvironment:IsEffect() then
			result = oldApplyEnvironmentEffect(self)
		end

		if not result then
			self.LiveEnvironment.eventDispatched = nil

			modApi.events.onPostEnvironment:dispatch(self)
		end

		return result
	end
end

local function buildGetUpgradeDescriptionOverride(skill)
	local originalFn = skill.GetUpgradeDescription

	return function(self, pawn, ...)
		-- Hack: The mod loader hooks into GetTipDamage to
		-- know when a skill is being hovered. Call this
		-- function to "inform" the mod loader this skill
		-- is being hovered.
		self:GetTipDamage()
		return originalFn(self, pawn, ...)
	end
end

local function override_Skill_GetUpgradeDescription()
	for k, skill in pairs(_G) do
		if type(skill) == 'table' and skill.GetSkillEffect then
			skill.GetUpgradeDescription = buildGetUpgradeDescriptionOverride(skill)
		end
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
		override_Skill_GetUpgradeDescription()
	end
end
