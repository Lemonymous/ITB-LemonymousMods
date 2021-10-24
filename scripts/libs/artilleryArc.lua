
local VERSION = "1.1.0"
---------------------------------------------------
-- Artillery Arc v1.1.0 - code library
--
-- by Lemonymous
---------------------------------------------------
-- When Artillery Arc has executed, skills can set
-- the following fields to automatically adjust
-- artillery height, both when they are armed, and
-- when viewed in the tooltip:
--
--    Skill.ArtilleryHeight - if defined,
-- specifies the height of any artillery attack in
-- the skill.
--
--    Skill.GetArtilleryHeight - function variant
-- of Skill.ArtilleryHeight.
--
--    Skill.UpdateArtilleryHeight - if defined,
-- this function will be called each update when
-- the skill is armed or viewed in the tipimage,
-- allowing you to set a conditional artillery
-- height. The library will handle resetting the
-- value automatically.
--
---------------------------------------------------

local weaponArmed = LApi.library:fetch("weaponArmed")
local worldConstants = LApi.library:fetch("worldConstants")

local function onModsInitialized()
	if VERSION < ArtilleryArc.version then
		return
	end

	if ArtilleryArc.initialized then
		return
	end

	ArtilleryArc:finalizeInit()
	ArtilleryArc.initialized = true
end

modApi:addModsInitializedHook(onModsInitialized)


local isNewestVersion = false
	or ArtilleryArc == nil
	or modApi:isVersion(VERSION, ArtilleryArc.version) == false

if isNewestVersion then
	ArtilleryArc = ArtilleryArc or {}
	ArtilleryArc.version = VERSION
	
	local function resetArtilleryHeight()
		Values.y_velocity = worldConstants:getDefaultHeight()
	end

	local function setSkillArtilleryHeight(skill)
		local artilleryHeight
		if type(skill.GetArtilleryHeight) == 'function' then
			artilleryHeight = skill:GetArtilleryHeight()
		end

		if type(artilleryHeight) ~= 'number' then
			artilleryHeight = skill.ArtilleryHeight
		end

		if type(artilleryHeight) == 'number' then
			Values.y_velocity = artilleryHeight
		else
			resetArtilleryHeight()
		end
	end

	ArtilleryArc.onWeaponArmed = function(armedSkill)
		local hoveredSkill = modApi:getHoveredSkill()
		if hoveredSkill then return end

		setSkillArtilleryHeight(armedSkill)
	end

	ArtilleryArc.onWeaponUnarmed = function(skill)
		local hoveredSkill = modApi:getHoveredSkill()
		if hoveredSkill then return end

		resetArtilleryHeight()
	end

	ArtilleryArc.onTipImageShown = function(hoveredSkill)
		setSkillArtilleryHeight(hoveredSkill)
	end

	ArtilleryArc.onTipImageHidden = function(skill)
		local armedSkill = weaponArmed:getArmedWeapon()
		if armedSkill then
			setSkillArtilleryHeight(armedSkill)
		else
			resetArtilleryHeight()
		end
	end

	ArtilleryArc.onMissionUpdate = function(mission)
		local skill = modApi:getHoveredSkill() or weaponArmed:getArmedWeapon()
		if skill then
			if type(skill.UpdateArtilleryHeight) == 'function' then
				skill.UpdateArtilleryHeight()
			end
		end
	end

	function ArtilleryArc:finalizeInit()
		weaponArmed.events.onWeaponArmed:subscribe(self.onWeaponArmed)
		weaponArmed.events.onWeaponUnarmed:subscribe(self.onWeaponUnarmed)
		modApi.events.onTipImageShown:subscribe(self.onTipImageShown)
		modApi.events.onTipImageHidden:subscribe(self.onTipImageHidden)
		modApi.events.onMissionUpdate:subscribe(self.onMissionUpdate)
	end
end
