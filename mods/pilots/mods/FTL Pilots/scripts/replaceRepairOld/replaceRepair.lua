
--[[
	Replace Repair is a system intended to
	provide everything you need to replace the
	repair skill of a mech, or a pilot.
	
	it should now be compatible with
	several mods using it at the same time.
--]]

local replaceRepair = {
	version = "1.3.0",
	weapons = {},
	pilotTooltips = {},
	iconForMech = {},
	iconForPilot = {},
}
local modApiExt
local Selected
local Highlighted

local function InTipImage()
	--return not Board.gameBoard --Doesn't work.
	return Board:GetSize() == Point(6, 6)
end

-- returns the mech with
-- UI currently enabled
local function GetVisiblePawn()
	if Selected then
		return Selected
	elseif Highlighted and Board and Board:IsPawnSpace(Highlighted) then
		return Board:GetPawn(Highlighted)
	end
	
	return nil
end

--[[
	returns the name of the skill
	we should replace repair with for a pawn.
	we only look through entries added by this
	instance of replaceRepair.
--]]
local function GetRepairSkill()
	local pawn = InTipImage() and Selected or Pawn
	if not pawn then return false end
	
	--search through every replaced repair entry
	--and look for a match for either pilot or mech.
	for _, v in ipairs(replaceRepair.weapons) do
		if pawn:IsAbility(v.sPilotSkill) or v.sMech == pawn:GetType() then
			return v.sSkill
		end
	end
	
	--No repair replacements found;
	--using default repair skill.
	return false
end

local function GetField(skill, field, default)
	return type(skill["Get"..field]) == 'function'	and	skill["Get"..field](skill)
													or	skill[field]
													or	default
													or	nil
end

--Recursive search for the CustomTipImage of a weapon.
--The name CustomTipImage is misleading.
--It is the string of the weapon containing the tipimage.
local function GetTipSkill(sSkill)
	local customTipImage = GetField(_G[sSkill], "CustomTipImage")
	if customTipImage and customTipImage ~= "" and customTipImage ~= sSkill then
		return GetTipSkill(customTipImage)
	end
	return sSkill
end

local function AddTipPawn(board, entry, point, type)
	if not board:IsPawnSpace(point) then
		board:AddPawn(type, point)
		if board:IsPawnSpace(point) then
			local pawn = board:GetPawn(point)
			if modApiExt.string:endsWith(entry, "Damaged") then
				test.SetHealth(pawn, 1)
			end
		end
	end
end

local function AddTipEffect(board, point, effect)
	local damage = SpaceDamage(point)
	damage[effect] = EFFECT_CREATE
	board:DamageSpace(damage)
end

--------------------------------------------------------
-------------------- SETUP TIPIMAGE --------------------

local function IterateBoard(cond, action)
	assert(type(cond) == "function")
	assert(type(action) == "function")
	
	local size = Board:GetSize()
	for x = 0, size.x - 1 do
		for y = 0, size.y - 1 do
			local p = Point(x, y)
			if cond(p) then action(p) end
		end
	end
end

-- Some juggling to make sure terrain returns to default.
local function ClearTerrain(point)
	Board:SetTerrain(point, TERRAIN_ICE)
	local damage = SpaceDamage(point)
	damage.iFire = EFFECT_CREATE
	Board:DamageSpace(damage)
	Board:SetTerrain(point, TERRAIN_ROAD)
	damage.iFire = EFFECT_REMOVE
	Board:DamageSpace(damage)
end

local function SetupBoard(board, sSkill)
	local unitIsFriendly = true
	sSkill = GetTipSkill(sSkill)
	local tipImage = GetField(_G[sSkill], "TipImage", {})
	local unitPoint = tipImage.Unit or tipImage.Unit_Damaged
	if unitPoint then
		local unitType = tipImage.CustomPawn or Selected:GetType()
		board:AddPawn(unitType, unitPoint)
		local pawn = board:GetPawn(unitPoint)
		unitIsFriendly = _G[unitType].DefaultTeam ~= TEAM_ENEMY and true or false
		test.SetMaxHealth(pawn, _G[unitType].Health or 3)
		if tipImage.Unit_Damaged then
			test.SetHealth(pawn, 1)
		end
	end
	local mechId = Selected:GetId()
	local defaultVek = "Scorpion2"
	for k, v in pairs(tipImage) do
		mechId = (mechId + 1) % 3
		local mech = Game:GetPawn(mechId)
		local defaultMech = mech and mech:GetType() or "PunchMech"
		if modApiExt.string:startsWith(k, "Enemy") then
			AddTipPawn(board, k, v, tipImage.CustomEnemy or unitIsFriendly and "Scorpion2" or defaultMech)
		elseif modApiExt.string:startsWith(k, "Friendly") then
			AddTipPawn(board, k, v, tipImage.CustomFriendly or unitIsFriendly and defaultMech or "Scorpion2")
		elseif modApiExt.string:startsWith(k, "Building") then
			board:SetTerrain(v, 1)
		elseif modApiExt.string:startsWith(k, "Rubble") then
			board:SetTerrain(v, 2)
		elseif modApiExt.string:startsWith(k, "Water") then
			board:SetTerrain(v, 3)
		elseif modApiExt.string:startsWith(k, "Mountain") then
			board:SetTerrain(v, 4)
		elseif modApiExt.string:startsWith(k, "Ice") then
			board:SetTerrain(v, 5)
		elseif modApiExt.string:startsWith(k, "Forest") then
			board:SetTerrain(v, 6)
		elseif modApiExt.string:startsWith(k, "Sand") then
			board:SetTerrain(v, 7)
		elseif modApiExt.string:startsWith(k, "Hole") then
			board:SetTerrain(v, 9)
		elseif modApiExt.string:startsWith(k, "Lava") then
			board:SetTerrain(v, 14)
		elseif modApiExt.string:startsWith(k, "Fire") then
			AddTipEffect(board, v, "iFire")
		elseif modApiExt.string:startsWith(k, "Smoke") then
			AddTipEffect(board, v, "iSmoke")
		elseif modApiExt.string:startsWith(k, "Acid") then
			AddTipEffect(board, v, "iAcid")
		--elseif modApiExt.string:startsWith(k, "Target") then
			--We change the target later.
		elseif modApiExt.string:startsWith(k, "Spawn") then
			board:SpawnPawn(unitIsFriendly and (tipImage.CustomEnemy	or "Scorpion2")
											or (tipImage.CustomFriendly or "Scorpion2")
										,v)
		elseif k == "Length" then
		end
	end
end

--[[
	NOT YET ADDED:
	
	Second_Origin
	Second_Target
--]]

local function FieldValue(sSkill, sField)
	local skill = _G[sSkill]
	if sField == 'Name' or sField == 'Description' then
		if		modApiExt.string:endsWith(sSkill, "_A") or
				modApiExt.string:endsWith(sSkill, "_B")	then
			sSkill = string.sub(sSkill, 1, string.len(sSkill) - 2)
		elseif	modApiExt.string:endsWith(sSkill, "_AB") then
			sSkill = string.sub(sSkill, 1, string.len(sSkill) - 3)
		end
		
		local ret = Weapon_Texts[sSkill .."_".. sField]
		if ret then return ret end
	end
	
	if skill["Get".. sField] == 'function' and skill["Get".. sField](skill) then
		return skill["Get".. sField](skill)
	elseif skill[sField] then
		return skill[sField]
	else
		return nil
	end
end

--------------------------------------------------------
------------------ FUNCTION OVERRIDES ------------------

local function ReplaceGetFunction(sField)
	local PrevGetFunction = Skill_Repair["Get".. sField]
	Skill_Repair["Get".. sField] = function(self)
		local sSkill = GetRepairSkill()
		if sSkill then
			-- check for CustomTipImage
			sSkill = GetTipSkill(sSkill)
			return	FieldValue(sSkill, sField)
		end
		return type(PrevGetFunction) == 'function' and PrevGetFunction(self) or nil
	end
end

local function CustomGetTargetArea(self, point)
	local sSkill = GetRepairSkill()
	if InTipImage() then
		-- check for CustomTipImage
		sSkill = GetTipSkill(sSkill)
		IterateBoard(
			function(point)
				return true
			end,
			function(point)
				Board:ClearSpace(point)
				ClearTerrain(point)
			end
		)
		SetupBoard(Board, sSkill)
		
		--Default GetTargetArea() to ensure GetSkillEffect() is called.
		return replaceRepair_internal.OrigGetTargetArea(self, point)
	end
	
	return _G[sSkill]:GetTargetArea(point)
end

local function CustomGetSkillEffect(self, p1, p2)
	local sSkill = GetRepairSkill()
	if InTipImage() then
		-- check for CustomTipImage
		sSkill = GetTipSkill(sSkill)
		local tipImage = GetField(_G[sSkill], "TipImage", {})
		p1 = tipImage.Unit or tipImage.Unit_Damaged
		p2 = tipImage.Target
	end
	
	return _G[sSkill]:GetSkillEffect(p1, p2)
end

local oldGetSkillInfo = GetSkillInfo
function GetSkillInfo(skill)
	if replaceRepair.pilotTooltips[skill] then
		return PilotSkill(replaceRepair.pilotTooltips[skill][1], replaceRepair.pilotTooltips[skill][2])
	end
	return oldGetSkillInfo(skill)
end

--------------------------------------------------------
------------------- ROOT FUNCTIONS ---------------------

local function RootGetTargetArea(self, point)
	if InTipImage() then
		IterateBoard(
			function(point)
				return point ~= Point(2, 2)
			end,
			function(point)
				Board:ClearSpace(point)
				ClearTerrain(point)
			end
		)
		AddTipEffect(Board, point, "iFire")
	end
	
	return replaceRepair_internal.OrigGetTargetArea(self, point)
end

local function RootGetSkillEffect(self, p1, p2)
	return replaceRepair_internal.OrigGetSkillEffect(self, p1, p2)
end

--------------------------------------------------------
------------------------ RETURN ------------------------

function replaceRepair:init(mod, _modApiExt)
	modApiExt = _modApiExt
	assert(package.loadlib(mod.scriptPath .."/replaceRepair/lib/utils.dll", "luaopen_utils"))()
	
	replaceRepair_internal = replaceRepair_internal or {}
	local m = replaceRepair_internal
	local v = m.version
	if not v or (v ~= self.version and modApi:isVersion(v, self.version)) then
		m.version = replaceRepair.version
		
		--[[
			save every original unmodified function,
			in case we will need them in later versions.
		--]]
		m.OrigGetTargetArea		= m.OrigGetTargetArea	or Skill_Repair.GetTargetArea
		m.OrigGetSkillEffect	= m.OrigGetSkillEffect	or Skill_Repair.GetSkillEffect
		m.OrigTipImage			= m.OrigTipImage		or Skill_Repair.TipImage
		m.OrigName				= m.OrigName			or Weapon_Texts.Skill_Repair_Name
		m.OrigDescription		= m.OrigDescription		or Weapon_Texts.Skill_Repair_Description
		m.RootGetTargetArea		= RootGetTargetArea
		m.RootGetSkillEffect	= RootGetSkillEffect
		
		-- if the following fields are set,
		-- our 'Get..' functions won't run.
		Weapon_Texts.Skill_Repair_Name = nil
		Weapon_Texts.Skill_Repair_Description = nil
		
		local SaveGetFunction = function(sField)
			-- ensures we know which fields were originally nil.
			if	Skill_Repair["Get".. sField] == nil	or
				m["OrigGet".. sField .."IsNil"]	then
				
				m["OrigGet".. sField .."IsNil"] = true
				return
			end
			m["OrigGet".. sField] = m["OrigGet".. sField] or Skill_Repair["Get".. sField]
		end
		
		--[[
			most of these 'get' functions will probably be nil,
			but let's attempt to store them just in case.
		--]]
		SaveGetFunction("Name")
		SaveGetFunction("Description")
		SaveGetFunction("Description2")
		SaveGetFunction("Class")
		SaveGetFunction("PathSize")
		SaveGetFunction("MinDamage")
		SaveGetFunction("Damage")
		SaveGetFunction("SelfDamage")
		SaveGetFunction("Limited")
		SaveGetFunction("LaunchSound")
		SaveGetFunction("ImpactSound")
		SaveGetFunction("ProjectileArt")
		SaveGetFunction("Web")
		SaveGetFunction("Push")
		SaveGetFunction("Acid")
		SaveGetFunction("Range")
		SaveGetFunction("Smoke")
		SaveGetFunction("Fire")
		SaveGetFunction("Shield")
		SaveGetFunction("TipImage")
		
		-- remove fire from repair's tipimage so replaced
		-- tipimages don't all have black smoke in them.
		Skill_Repair.TipImage.Fire		= nil
		if not v then
			require(mod.scriptPath .."replaceRepair/replaceIcon")
			Skill_Repair.GetName		= function(self)			return m.OrigName							end
			Skill_Repair.GetDescription	= function(self)			return m.OrigDescription					end
			Skill_Repair.GetTargetArea	= function(self, point)		return m.RootGetTargetArea(self, point)		end
			Skill_Repair.GetSkillEffect	= function(self, p1, p2)	return m.RootGetSkillEffect(self, p1, p2)	end
		end
	end
	
	-- allow for chaining of functions
	local PrevGetTargetArea = Skill_Repair.GetTargetArea
	Skill_Repair.GetTargetArea = function(self, p)
		if GetRepairSkill() then
			return CustomGetTargetArea(self, p)
		end
		return PrevGetTargetArea(self, p)
	end
	
	local PrevGetSkillEffect = Skill_Repair.GetSkillEffect
	Skill_Repair.GetSkillEffect = function(self, p1, p2)
		if GetRepairSkill() then
			return CustomGetSkillEffect(self, p1, p2)
		end
		return PrevGetSkillEffect(self, p1, p2)
	end
	
	local PrevGetRepairIcon = m.GetRepairIcon
	m.GetRepairIcon = function(self)
		local pawn = GetVisiblePawn()
		if not pawn then return nil end
		
		for sMech, surface in pairs(replaceRepair.iconForMech) do
			if sMech == pawn:GetType() then
				return surface
			end
		end
		for sPilotSkill, surface in pairs(replaceRepair.iconForPilot) do
			if pawn:IsAbility(sPilotSkill) then
				return surface
			end
		end
		if type(PrevGetRepairIcon) == 'function' then
			return PrevGetRepairIcon(self)
		end
		
		return nil
	end
	
	ReplaceGetFunction("Name")
	ReplaceGetFunction("Description")
--	ReplaceGetFunction("Description2")
--	ReplaceGetFunction("Class")		-- doesn't seem to do anything.
	ReplaceGetFunction("PathSize")
	ReplaceGetFunction("MinDamage")
	ReplaceGetFunction("Damage")
	ReplaceGetFunction("SelfDamage")
--	ReplaceGetFunction("Limited")	-- shows up on tooltip, but doesn't seem to do anything. hide it.
	ReplaceGetFunction("LaunchSound")
	ReplaceGetFunction("ImpactSound")
	ReplaceGetFunction("ProjectileArt")
	ReplaceGetFunction("Web")
	ReplaceGetFunction("Push")
	ReplaceGetFunction("Acid")
	ReplaceGetFunction("Range")
	ReplaceGetFunction("Smoke")
	ReplaceGetFunction("Fire")
	ReplaceGetFunction("Shield")
--	ReplaceGetFunction("TipImage")	-- Seems to only get the tipimage once,
									-- so it won't be dynamic like we need it to be.
end

sdlext.addGameExitedHook(function(screen)
	Selected = nil
	Highlighted = nil
end)

function replaceRepair:load(mod, options, version)
	
	modApiExt:addTileHighlightedHook(function(_, point)
		Highlighted = point
	end)
	modApiExt:addTileUnhighlightedHook(function()
		Highlighted = nil
	end)
	
	modApiExt:addPawnSelectedHook(function(_, pawn)
		Selected = pawn
	end)
	modApiExt:addPawnDeselectedHook(function()
		Selected = nil
	end)
	
	modApi:addTestMechEnteredHook(function()
		modApi:runLater(function()
			for id = 0, 2 do
				Selected = Board:GetPawn(id)
				if Selected then
					break
				end
			end
		end)
	end)
	modApi:addTestMechExitedHook(function()
		Selected = nil
	end)
end

function replaceRepair:ForPilot(sPilotSkill, sWeapon, sPilotTooltip, sIconPath)
	assert(sPilotSkill and type(sPilotSkill) == "string")
	assert(sWeapon and type(sWeapon) == "string")
	assert(sPilotTooltip and type(sPilotTooltip) == 'table')
	assert(sIconPath == nil or type(sIconPath) == "string")
	assert(sPilotTooltip[1] and type(sPilotTooltip[1]) == "string")
	assert(sPilotTooltip[2] and type(sPilotTooltip[2]) == "string")
	
	table.insert(self.weapons, {sPilotSkill = sPilotSkill, sMech = "N/A", sSkill = sWeapon})
	self.pilotTooltips[sPilotSkill] = sPilotTooltip
	self.iconForPilot[sPilotSkill] = sIconPath and sdlext.surface(sIconPath) or nil
end

function replaceRepair:ForMech(sMech, sWeapon, sIconPath)
	assert(sMech and type(sMech) == "string")
	assert(sWeapon and type(sWeapon) == "string")
	assert(sIconPath == nil or type(sIconPath) == "string")
	
	table.insert(self.weapons, {sPilotSkill = "N/A", sMech = sMech, sSkill = sWeapon})
	self.iconForMech[sMech] = sIconPath and sdlext.surface(sIconPath) or nil
end

return replaceRepair