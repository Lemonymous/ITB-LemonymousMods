
local this = {}

lmn_SmokeMech = Pawn:new{
	Name = "APC Mech",
	Class = "Science",
	Health = 3,
	MoveSpeed = 4,
	Image = "lmn_MechApc",
	ImageOffset = 0,
	SkillList = { "lmn_SmokeLauncher" },
	SoundLocation = "/mech/brute/tank/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Massive = true,
	Armor = true,
}
AddPawn("lmn_SmokeMech")

lmn_SmokeLauncher = Skill:new{
	Name = "Smoke Launcher",
	Class = "Science",
	Icon = "weapons/lmn_smoke_launcher.png",
	Description = "Covers one of the 8 surrounding tiles in smoke.\n\nEvacuates civilian buildings, and disconnects power pylons from the grid.",
	Sound = "/general/combat/explode_small",
	UpShot = "effects/shotup_smokeblast_missile.png",
	PowerCost = 1,
	Diagonal = true,
	Range = 1,
	ArtillerySize = 0,
	Evac = true,
	Upgrades = 1,
	UpgradeCost = { 1 },
	UpgradeList = { "Ignore Smoke", "Artillery" },
	LaunchSound = "/weapons/artillery_volley",
	CustomTipImage = "lmn_SmokeLauncher_Tip",
	TipImage = {
		CustomPawn = "lmn_SmokeMech",
		Unit = Point(2,2),
		Building = Point(2,1),
		Target = Point(2,1),
		Enemy = Point(1,1),
		Second_Origin = Point(2,2),
		Second_Target = Point(1,1),
		Length = 2
	}
}

local function iterateDiamond(center, size, cond, action)
	assert(type(cond) == "function")
	assert(type(action) == "function")
	
	local corner = center - Point(size, size)
	local p = Point(corner)
	
	for i = 0, ((size*2+1)*(size*2+1)) do
		local diff = center - p
		local dist = math.abs(diff.x) + math.abs(diff.y)
		
		if	dist <= size	and
			cond(p)			then
			
			action(p)
		end
		p = p + VEC_RIGHT
		if math.abs(p.x - corner.x) == (size*2+1) then
			p.x = p.x - (size*2+1)
			p = p + VEC_DOWN
		end
	end
end

local function iterateSquare(center, size, cond, action)
	assert(type(cond) == "function")
	assert(type(action) == "function")
	
	local corner = center - Point(size, size)
	local p = Point(corner)
	
	for i = 1, ((size*2+1)*(size*2+1)) do
		if cond(p) then
			action(p)
		end
		p = p + VEC_RIGHT
		if math.abs(p.x - corner.x) == (size*2+1) then
			p.x = p.x - (size*2+1)
			p = p + VEC_DOWN
		end
	end
end

local targetInfo ={
	pawn,
	weaponId,
	target,
}

function lmn_SmokeLauncher:GetTargetArea(point)
	local ret = PointList()
	
	if self.Diagonal then
		iterateSquare(
			point,
			self.Range,
			function(p)
				return	Board:IsValid(p)	and
						p ~= point
			end,
			function(p)
				ret:push_back(p)
			end
		)
	else
		iterateDiamond(
			point,
			self.Range,
			function(p)
				return	Board:IsValid(p)	and
						p ~= point
			end,
			function(p)
				ret:push_back(p)
			end
		)
	end
	
	for dir = DIR_START, DIR_END do
		for i = 2, self.ArtillerySize do
			local curr = Point(point + DIR_VECTORS[dir] * i)
			if not Board:IsValid(curr) then
				break
			end
			
			if not self.OnlyEmpty or not Board:IsBlocked(curr, PATH_GROUND) then
				ret:push_back(curr)
			end

		end
	end
	
	return ret
end

function lmn_SmokeLauncher:ReplacePylon()
	local mission = GetCurrentMission()
	if not mission then return end
	
	local voiceId = "MissionFinal_Pylon_Smoked"
	
	if not mission[this.mod.id .."_smokeEvac"] then
		mission[this.mod.id .."_smokeEvac"] = true
		voiceId = "MissionFinal_Pylon_Smoked_First"
	end
	
	local deployment = {}
	local size = Board:GetSize()
	for x = 0, size.x - 1 do
		for y = 0, size.y -1 do
			local tile = Point(x, y)
			local terrain = Board:GetTerrain(tile)
			
			if
				not Board:IsPawnSpace(tile)				and
				not Board:IsBlocked(tile, PATH_GROUND)	and
				not Board:IsDangerous(tile)				and
				not Board:IsDangerousItem(tile)			and
				not Board:IsSpawning(tile)				and
				not Board:IsTargeted(tile)				and
				not Board:IsPod(tile)					and
				not (terrain == TERRAIN_ICE)			and
				not list_contains(mission.LiveEnvironment.Locations, tile)
			then
				table.insert(deployment, tile)
			end
		end
	end
	
	if #deployment > 0 then
		TriggerVoiceEvent(VoiceEvent(voiceId, PAWN_ID_CEO, 0))
		
		local effect = SkillEffect()
		local building = SpaceDamage()
		building.iTerrain = TERRAIN_BUILDING
		--effect:AddVoice(voiceId, PAWN_ID_CEO)
		effect:AddDelay(1.5)
		
		building.loc = random_removal(deployment)
		if Board:IsPawnSpace(building.loc) then
			building.iDamage = DAMAGE_DEATH
		end
		effect:AddDropper(building,"combat/tiles_grass/building_fall.png")
		effect:AddDropper(building, "combat/tiles_grass/building_fall.png")
		
		Board:AddEffect(effect)
	end
end

local evacVoice = {
	{2, "Building evacuated. Fire at will!"},
}

local oddsMax = 98 -- odds of no voice
for i, v in ipairs(evacVoice) do
	oddsMax = oddsMax + v[1]
end

function lmn_SmokeLauncher:EvacVoice(pawnId)
	local odds = 0
	local rng = math.random(1, oddsMax)
	for i, v in ipairs(evacVoice) do
		local odds = odds + v[1]
		if rng <= odds then
			local pop = VoicePopup()
			pop.pawn = pawnId
			pop.text = v[2]
			Game:AddVoicePopup(pop)
			break
		end
	end
end

function lmn_SmokeLauncher:GetSkillEffect(p1, p2, parentSkill, isTipImage)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	--ret:AddBounce(p1, 2)
	
	targetInfo.pawn = Board:GetPawn(p1)
	targetInfo.weaponId = targetInfo.pawn:GetArmedWeaponId()
	targetInfo.target = p2
	
	local damage = SpaceDamage(p2, self.Damage)
	damage.sAnimation = ""
	damage.iSmoke = 1
	
	local evac
	
	if
		Board:IsBuilding(p2) and
		self.Evac	
	then
		if
			not Board:IsUniqueBuilding(p2) and
			Board:IsPowered(p2)
		then
			damage.sImageMark = "combat/icons/lmn_people.png"
			evac = true
		else
			damage.sImageMark = "combat/icons/lmn_people_none.png"
		end
	end
	
	ret:AddArtillery(damage, self.UpShot)
	
	if evac then
		ret:AddDelay(0.14)
		ret:AddBounce(p2, -2)
		ret:AddScript([[
			local p = ]].. p2:GetString() ..[[;
			Board:SetPopulated(false, p);
			Board:Ping(p, GL_Color(255,255,255,1));
			Game:TriggerSound("/ui/battle/population_points");
		]])
		
		if
			not IsTestMechScenario() and
			not isTipImage
		then
			local region = GetCurrentRegion()
			if region == RegionData["final_region"] then
				ret:AddScript("lmn_SmokeLauncher:ReplacePylon()")
			else
				ret:AddDelay(0.2)
				ret:AddBounce(p1, -2)
				ret:AddScript([[
					local p = ]].. p1:GetString() ..[[;
					Board:Ping(p, GL_Color(255,255,255,1));
					Game:TriggerSound("/ui/map/flyin_rewards");
				]])
				
				ret:AddScript("lmn_SmokeLauncher:EvacVoice(".. Board:GetPawn(p1):GetId() ..")")
			end
		end
	else
		ret:AddBounce(p2, 2)
	end
	
	return ret
end

lmn_SmokeLauncher_A = lmn_SmokeLauncher:new {
	UpgradeDescription = "Allows the Mech to ignore smoke completely.",
	IgnoreSmoke = true,
	CustomTipImage = "lmn_SmokeLauncher_Tip_A",
	TipImage = {
		CustomPawn = "lmn_SmokeMech",
		Unit = Point(2,2),
		Smoke = Point(2,2),
		Building = Point(2,1),
		Target = Point(2,1),
		Enemy = Point(1,1),
		Second_Origin = Point(2,2),
		Second_Target = Point(1,1),
		Length = 2
	}
}

lmn_SmokeLauncher_B = lmn_SmokeLauncher:new {
	UpgradeDescription = "Can target any tile in a straight line.",
	ArtillerySize = INT_MAX,
	CustomTipImage = "lmn_SmokeLauncher_Tip_B",
	TipImage = {
		CustomPawn = "lmn_SmokeMech",
		Unit = Point(2,2),
		Mountain = Point(2,1),
		Building = Point(2,0),
		Target = Point(2,0),
		Enemy = Point(1,1),
		Second_Origin = Point(2,2),
		Second_Target = Point(1,1),
		Length = 2
	}
}

lmn_SmokeLauncher_AB = lmn_SmokeLauncher:new {
	IgnoreSmoke = true,
	ArtillerySize = INT_MAX,
	CustomTipImage = "lmn_SmokeLauncher_Tip_AB",
	TipImage = {
		CustomPawn = "lmn_SmokeMech",
		Unit = Point(2,2),
		Smoke = Point(2,2),
		Mountain = Point(2,1),
		Building = Point(2,0),
		Target = Point(2,0),
		Enemy = Point(1,1),
		Second_Origin = Point(2,2),
		Second_Target = Point(1,1),
		Length = 2
	}
}

lmn_SmokeLauncher_Tip = lmn_SmokeLauncher:new{}
lmn_SmokeLauncher_Tip_A = lmn_SmokeLauncher_A:new{}
lmn_SmokeLauncher_Tip_B = lmn_SmokeLauncher_B:new{}
lmn_SmokeLauncher_Tip_AB = lmn_SmokeLauncher_AB:new{}

function lmn_SmokeLauncher_Tip:GetSkillEffect(p1, p2, parentSkill)
	local ret = SkillEffect()
	
	-- (re)populate building if on first target.
	if p2 == self.TipImage.Target then
		Board:SetPopulated(true, self.TipImage.Target)
	end
	
	local ret = lmn_SmokeLauncher.GetSkillEffect(self, p1, p2, parentSkill, true)
	
	-- add delay if _not_ on first target.
	if p2 ~= self.TipImage.Target then
		ret:AddDelay(2)
	end
	
	return ret
end

lmn_SmokeLauncher_Tip_A.GetSkillEffect = lmn_SmokeLauncher_Tip.GetSkillEffect
lmn_SmokeLauncher_Tip_B.GetSkillEffect = lmn_SmokeLauncher_Tip.GetSkillEffect
lmn_SmokeLauncher_Tip_AB.GetSkillEffect = lmn_SmokeLauncher_Tip.GetSkillEffect

local function HasSmokeLauncher()
	for i = 0, 2 do
		if Game:GetPawn(i):IsWeaponPowered("lmn_SmokeLauncher") then
			return true
		end
	end
	
	return false
end

local oldTriggerVoiceEvent = TriggerVoiceEvent
function TriggerVoiceEvent(event, ...)
	if
		event.id == "MissionFinal_Pylons" and
		HasSmokeLauncher()
	then
		local event = shallow_copy(event)
		event.id = "MissionFinal_Pylons_Replace"
		oldTriggerVoiceEvent(event, ...)
		return
	end
	
	oldTriggerVoiceEvent(event, ...)
end

function this:init(mod)
	self.mod = mod
	require(mod.scriptPath .."shop"):addWeapon({
		id = "lmn_SmokeLauncher",
		desc = "Adds Smoke Launcher to the store."
	})
	
	Personality["CEO_Sand"]["MissionFinal_Pylons_Replace"] = {"Sending down power pylons. Keep them operational, we don't have many more."}
	Personality["CEO_Sand"]["MissionFinal_Pylon_Smoked_First"] = {"Sending down a replacement pylon. Keep this one intact."}
	Personality["CEO_Sand"]["MissionFinal_Pylon_Smoked"] = {
		"Sending down a replacement pylon. Take care of this one.",
		"Sending another pylon. You need them to stay connected to the grid.",
		"Disconnecting them does save our grid, but they're still expensive. Keep this one online."
	}
	
	modApi:appendAsset("img/units/player/lmn_mech_apc.png", mod.resourcePath .."img/units/player/apc.png")
	modApi:appendAsset("img/units/player/lmn_mech_apc_a.png", mod.resourcePath .."img/units/player/apc_a.png")
	modApi:appendAsset("img/units/player/lmn_mech_apc_broken.png", mod.resourcePath .."img/units/player/apc_broken.png")
	modApi:appendAsset("img/units/player/lmn_mech_apc_w.png", mod.resourcePath .."img/units/player/apc_w.png")
	modApi:appendAsset("img/units/player/lmn_mech_apc_w_broken.png", mod.resourcePath .."img/units/player/apc_w_broken.png")
	modApi:appendAsset("img/units/player/lmn_mech_apc_ns.png", mod.resourcePath .."img/units/player/apc_ns.png")
	modApi:appendAsset("img/units/player/lmn_mech_apc_h.png", mod.resourcePath .."img/units/player/apc_h.png")
	
	modApi:appendAsset("img/weapons/lmn_smoke_launcher.png", mod.resourcePath .."img/weapons/smoke_launcher.png")
	
	modApi:copyAsset("img/combat/icons/people.png", "img/combat/icons/lmn_people.png")
	modApi:appendAsset("img/combat/icons/lmn_people_none.png", mod.resourcePath .."img/combat/icons/people_none.png")
	Location["combat/icons/lmn_people.png"] = Point(-35,-17)
	Location["combat/icons/lmn_people_none.png"] = Point(-35,-17)
	
	setfenv(1, ANIMS)
	lmn_MechApc =			MechUnit:new{ Image = "units/player/lmn_mech_apc.png", PosX = -19, PosY = 3 }
	lmn_MechApca =			lmn_MechApc:new{ Image = "units/player/lmn_mech_apc_a.png", NumFrames = 4 }
	lmn_MechApc_broken =	lmn_MechApc:new{ Image = "units/player/lmn_mech_apc_broken.png", }
	lmn_MechApcw =			lmn_MechApc:new{ Image = "units/player/lmn_mech_apc_w.png", PosY = 13 }
	lmn_MechApcw_broken =	lmn_MechApcw:new{ Image = "units/player/lmn_mech_apc_w_broken.png" }
	lmn_MechApc_ns =		MechIcon:new{ Image = "units/player/lmn_mech_apc_ns.png" }
end

function this:load(modApiExt)
	self.modApiExt = modApiExt
	
	modApiExt:addTileHighlightedHook(function(_, tile) self.highlighted = tile end)
	modApiExt:addTileUnhighlightedHook(function() self.highlighted = nil end)
	
	modApiExt:addPawnSelectedHook(function(_, pawn)
		if pawn:IsWeaponPowered("lmn_SmokeLauncher_A") then
			self.orig_ignoreSmoke = _G[pawn:GetType()].IgnoreSmoke
			_G[pawn:GetType()].IgnoreSmoke = true
		end
	end)
	
	modApiExt:addPawnDeselectedHook(function(_, pawn)
		if pawn:IsWeaponPowered("lmn_SmokeLauncher_A") then
			_G[pawn:GetType()].IgnoreSmoke = self.orig_ignoreSmoke
		end
	end)
	
	modApi:addMissionUpdateHook(function()
		if	targetInfo.pawn												and
			targetInfo.target == self.highlighted						and
			targetInfo.weaponId > 0										and
			targetInfo.pawn:GetArmedWeaponId() == targetInfo.weaponId	and
			
			Board:IsBuilding(targetInfo.target)							and					
			Board:IsPowered(targetInfo.target)							and
			not Board:IsUniqueBuilding(targetInfo.target)				then
			
			Board:MarkFlashing(targetInfo.target, true)
		end
	end)
end

return this