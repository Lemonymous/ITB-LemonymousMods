
local weaponArmed = LApi.library:fetch("weaponArmed")
local worldConstants = LApi.library:fetch("worldConstants")

local VERSION = "0.0.0"

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

if ArtilleryArc == nil or modApi:isVersion(VERSION, ArtilleryArc.version) then
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
