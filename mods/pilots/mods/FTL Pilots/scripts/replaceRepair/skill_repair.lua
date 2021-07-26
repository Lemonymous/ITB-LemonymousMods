
-- internal library, not meant for outside use.
local mod = mod_loader.mods[modApi.currentMod]
local path = mod.scriptPath
local subs = require(path .."replaceRepair/subs")
local selected = require(path .."replaceRepair/lib/selected")
local uiVisiblePawn = require(path .."replaceRepair/lib/uiVisiblePawn")
local isTipImage = require(path .."replaceRepair/lib/isTipImage")
local tipImage = require(path .."replaceRepair/tipImage")
local this = {}

-- overriding most of these fields,
-- even if they won't make an impact on the tipimage.
local fields = {
	"Name",				-- displays
	"Description",		-- displays
	--"Class",			-- no display. Causes bizarre crashes
	"PathSize",
	"MinDamage",		-- displays?
	"Damage",			-- displays
	"SelfDamage",		-- displays
	--"Limited",		-- shows up on tooltip, but doesn't seem to do anything. Causes bizarre crashes
	"LaunchSound",		-- no sound in tipimage
	"ImpactSound",		-- no sound in tipimage
	"ProjectileArt",
	"Web",
	"Push",
	"Acid",
	"Range",
	"Smoke",
	"Fire",
	"Shield",
	"TargetArea",
	"SkillEffect"
	--"TipImage"		-- GetTipImage is called once, so overriding is useless.
}

local weaponTexts = {
	"Name",
	"Description"
}

local function GetTargetArea(skill, p, ...)
	local Skill = _G[skill]
	
	if isTipImage() then
		tipImage:clear()
		tipImage:setup(skill)
		
		-- call original GetTargetArea to ensure
		-- GetSkillEffect is called.
		return Skill_Repair_Orig:GetTargetArea(p, ...)
	end
	
	return Skill:GetTargetArea(p, ...)
end

local function GetSkillEffect(skill, p1, p2, _, ...)
	local Skill = _G[skill]
	
	if isTipImage() then
		if Skill.CustomTipImage ~= "" then
			skill = Skill.CustomTipImage
		end
		
		local check = tipImage:verify(skill)
		if check.incomplete then
			return lmn_TipImageNotFound:GetSkillEffect(
				p1,
				p2,
				lmn_TipImageNotFound,
				not check.unit,
				not check.target
			)
		end
		
		local Skill = _G[skill]
		local t = Skill.TipImage
		p1 = t.Unit or t.Unit_Damaged
		p2 = t.Target
	end
	
	return Skill:GetSkillEffect(p1, p2, Skill, ...)
end

local function getField(skill, field, ...)
	local Skill = _G[skill]
	if not Skill then
		skill = "lmn_RepairNotFound"
		Skill = lmn_RepairNotFound
	end
	
	-- need some special consideration for
	-- GetTargetArea and GetSkillEffect.
	if field == "TargetArea" then
		return GetTargetArea(skill, ...)
	elseif field == "SkillEffect" then
		return GetSkillEffect(skill, ...)
	end
	
	-- check Weapon_Texts for data and return
	-- those names and description if available.
	-- (could be done cleaner with gsub?)
	if list_contains(weaponTexts, field) then
		if
			skill:sub(-2,-1) == "_A" or 
			skill:sub(-2,-1) == "_B"
		then
			skill = skill:sub(1,-3)
		elseif skill:sub(-3,-1) == "_AB" then
			skill = skill:sub(1,-4)
		end
		
		local ret = Weapon_Texts[skill .."_".. field]
		if ret then return ret end
	end
	
	-- return other Get- functions.
	if type(Skill["Get".. field]) == 'function' then
		local ret = Skill["Get".. field](Skill, ...)
		if ret then return ret end
	end
	
	-- return fields without Get- functions.
	return Skill[field]
end

local function OverrideGetFuncs(field)
	local m = lmn_replaceRepair
	Skill_Repair["Get".. field] = function(self, ...)
		local pawn = isTipImage() and selected:Get() or Pawn
		if pawn then
			for _, v in ipairs(m.swaps) do
				if v.IsActive(pawn) then
					return getField(v.Weapon, field, ...)
				end
			end
		end
		
		return getField("Skill_Repair_Orig", field, ...)
	end
end

function this:Override()
	Skill_Repair_Orig = Skill_Repair
	Skill_Repair = Skill_Repair:new{}
	
	-- Weapon_Texts for Skill_Repair needs to be cleared
	-- in order to rename Name and Description for custom skills.
	local t = Weapon_Texts
	t.Skill_Repair_Orig_Name = t.Skill_Repair_Name
	t.Skill_Repair_Orig_Description = t.Skill_Repair_Description
	t.Skill_Repair_Name = nil
	t.Skill_Repair_Description = nil
	
	for _, field in ipairs(fields) do
		OverrideGetFuncs(field)
	end
	
	Skill_Repair.TipImage = copy_table(Skill_Repair.TipImage)
	Skill_Repair.TipImage.Fire = nil
	
	lmn_replaceRepair.GetCurrentSkill = self.GetCurrent
end

function this.GetCurrent()
	local pawn = uiVisiblePawn()
	if not pawn then return end
	
	for _, v in ipairs(lmn_replaceRepair.swaps) do
		if v.IsActive(pawn) then
			return v
		end
	end
end

function this.add(input)
	local m = lmn_replaceRepair
	table.insert(m.swaps, input)
	table.sort(m.swaps, function(a,b)
		-- sort table with all custom skill first, then pilot skills, and finally mech skills.
		return a.Priority > b.Priority
	end)
end

function this.clear(id, field)
	for i = #m.swaps, 1, -1 do
		local v = m.swaps[i]
		if v.modId == mod.id and v[field] == id then
			table.remove(m.swaps, i)
		end
	end
end

local vanillaGetText = GetText
function GetText(id, ...)
	local result = vanillaGetText(id, ...)
	
	if id:match("^Skill_Repair") then
		local repair = lmn_replaceRepair.GetCurrentSkill()
		
		if type(repair) == 'table' then
			if id:match("Name$") then
				result = _G[repair.Weapon]:GetName()
			elseif id:match("Description$") then
				result = _G[repair.Weapon]:GetDescription()
			end
		end
	end
	
	return result
end

return this
