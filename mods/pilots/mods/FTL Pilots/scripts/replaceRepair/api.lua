
--[[-----------------------------------------------------------------------------
	API for
	 - replacing repair skill for pilots
	 - replacing repair skill for mechs
	 - replacing repair skill for abritrary conditions
	
	
	 request api:
	==============
	local path = mod_loader.mods[modApi.currentMod].scriptPath
	local repairApi = require(path .."replaceRepair/api")
	
	NOTE:
	requesting the api will initialize the library,
	but it needs to be loaded as well.
	
	in function load in your mod's init.lua
		
		require(self.scriptPath .."replaceRepair/api"):load()
		
		..etc
	
	
	-----------------
	   Method List
	-----------------
	
	
	repairApi:GetVersion()
	======================
	returns the version of this library. (not the highest version initialized)
	
	
	
	repairApi:GetHighestVersion()
	=============================
	returns the highest version of this library.
	since mods are initialized sequentially,
	this function cannot be sure of the highest version until after init.
	(will not detect library before version 2.0.0)
	
	
	
	repairApi:SetPilotRepairSkill(input)
	====================================
	sets the repair skill for a pilot.
	input is a table with the following required fields:
	
	field       | type   | description
	------------+--------+--------------------------------------
	Name        | string | displayed skill name for pilot
	Description | string | displayed skil description for pilot
	PilotSkill  | string | id of pilot skill
	Weapon      | string | id of weapon replacing repair skill
	Icon        | table  | path to icon (in game or mod)
	------------+--------+--------------------------------------
	
	 example:
	----------
	repairApi:SetPilotRepairSkill{
		Name = "Titan Fist",
		Description = "Ralpha has started punching instead of repairing.",
		PilotSkill = "Extra_XP",
		Weapon = "Prime_Punchmech",
		Icon = "img/repair/my_punch_icon.png"
	}
	
	
	
	repairApi:ClearPilotRepairSkill(PilotSkill)
	===========================================
	removes any custom repair skill set for a pilot (by your mod only).
	
	field      | type   | description
	-----------+--------+-------------------
	PilotSkill | string | id of pilot skill
	-----------+--------+-------------------
	
	 example:
	----------
	repairApi:ClearPilotRepairSkill("Extra_XP")
	
	
	
	repairApi:SetMechRepairSkill(input)
	===================================
	sets the repair skill for a mech type.
	input is a table with the following required fields:
	
	field    | type   | description
	---------+--------+-------------------------------------
	MechType | string | id of mech type
	Weapon   | string | id of weapon replacing repair skill
	Icon     | table  | path to icon (in game or mod)
	---------+--------+-------------------------------------
	
	 example:
	----------
	repairApi:SetMechRepairSkill{
		MechType = "PunchMech",
		Weapon = "Ranged_Artillerymech",
		Icon = "img/repair/my_artillery_icon.png"
	}
	
	
	
	repairApi:ClearMechRepairSkill(MechType)
	========================================
	removes any custom repair skill set for a mech type (by your mod only).
	
	field    | type   | description
	---------+--------+-----------------
	MechType | string | id of mech type
	---------+--------+-----------------
	
	 example:
	----------
	repairApi:ClearMechRepairSkill("PunchMech")
	
	
	
	repairApi:SetRepairSkill(input)
	===============================
	sets the repair skill dynamically when a condition is met.
	input is a table with the following required fields:
	
	field    | type           | description
	---------+----------------+------------------------------------------------------------
	Id       | string         | optional identifier used if you later need to clear the skill
	Weapon   | string         | id of weapon replacing repair skill
	Icon     | table          | path to icon (in game or mod)
	IsActive | function(pawn) | if function for pawn returns true, repair skill is swapped
	---------+----------------+------------------------------------------------------------
	
	 example:
	----------
	repairApi:SetRepairSkill{
		Weapon = "Support_Destruct",
		Icon = "img/repair/my_explosive_icon.png",
		
		IsActive = function(pawn)
			return pawn:IsFire()
		end
	}
	
	
	
	repairApi:ClearRepairSkill(Id)
	==============================
	removes any custom repair skill with a unique identifier.
	
	field | type   | description
	------+--------+-------------------------------
	Id    | string | Id manually assigned to skill
	------+--------+-------------------------------
	
	 example:
	----------
	repairApi:ClearRepairSkill("my_unique_identifier")
	
	
]]-------------------------------------------------------------------------------

local this = {}
local mod = mod_loader.mods[modApi.currentMod]
local path = mod.resourcePath
local init = require(path .."scripts/replaceRepair/init")
local skill_repair = require(path .."scripts/replaceRepair/skill_repair")
local file_exists = require(path .."scripts/replaceRepair/lib/file_exists")
local asset_exists = require(path .."scripts/replaceRepair/lib/asset_exists")
local pilotSkills = {}
local mechSkills = {}

-- added for backwards compatibility. does nothing.
function this:init() end

function this:load()
	init:load()
end

function this:GetVersion()
	return init.version
end

function this:GetHighestVersion()
	return lmn_replaceRepair.version
end

function this:SetRepairSkill(t)
	assert(type(t.Weapon) == "string")
	assert(type(t.IsActive) == 'function')
	
	if t.Icon then
		assert(type(t.Icon) == 'string')
		
		local icon = path .. t.Icon
		if file_exists(icon) then
			t.surface = sdlext.surface(icon)
		elseif asset_exists(t.Icon) then
			t.surface = sdlext.surface(t.Icon)
		end
		
		icon = path .. t.Icon:sub(1,-5) .."_frozen.png"
		if file_exists(icon) then
			t.surface_frozen = sdlext.surface(icon)
		end
	end
	
	t.modId = mod.id
	t.Priority = t.MechType and 0 or t.PilotSkill and 1 or 2
	skill_repair.add(t)
end

function this:ClearRepairSkill(id)
	skill_repair.clear(id, "Id")
end

function this:SetPilotRepairSkill(t)
	assert(type(t) == 'table')
	assert(type(t.PilotSkill) == 'string')
	
	t.Name = type(t.Name) == "string" and t.Name or "Replace Repair: No Name"
	t.Description = type(t.Description) == "string" and t.Description or "Replace Repair: No Description"
	
	t.IsActive = function(pawn)
		return pawn:IsAbility(t.PilotSkill)
	end
	
	self:SetRepairSkill(t)
end

function this:ClearPilotRepairSkill(PilotSkill)
	skill_repair.clearPilot(PilotSkill, "PilotSkill")
end

function this:SetMechRepairSkill(t)
	assert(type(t) == 'table')
	assert(type(t.MechType) == 'string')
	
	t.IsActive = function(pawn)
		return pawn:GetType() == t.MechType
	end
	
	self:SetRepairSkill(t)
end

function this:ClearMechRepairSkill(mechType)
	skill_repair.clear(mechType, "MechType")
end

-- deprecated function for backwards compatibility.
-- use SetPilotRepairSkill instead.
function this:ForPilot(sPilotSkill, sWeapon, sPilotTooltip, sIcon)
	
	local t = {
		Name = sPilotTooltip[1],
		Description = sPilotTooltip[2],
		PilotSkill = sPilotSkill,
		Weapon = sWeapon,
		Icon = sIcon:gsub(mod.resourcePath, "")
	}
	self:SetPilotRepairSkill(t)
end

-- deprecated function for backwards compatibility.
-- use SetMechRepairSkill instead.
function this:ForMech(sMech, sWeapon, sIcon)
	local t = {
		MechType = sMech,
		Weapon = sWeapon,
		Icon = sIcon:gsub(mod.resourcePath, "")
	}
	self:SetMechRepairSkill(t)
end

return this
