
local mod = mod_loader.mods[modApi.currentMod]
local resourcePath = mod.resourcePath
local shop = LApi.library:fetch("shop")

lmn_BomberMech = Pawn:new{
	Name = "Bomber Mech",
	Class = "Brute",
	Health = 2,
	MoveSpeed = 3,
	Image = "lmn_MechBomber",
	ImageOffset = 0,
	SkillList = { "lmn_Bombrun" },
	SoundLocation = "/mech/flying/jet_mech/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Massive = true,
	Flying = true,
}
AddPawnName("lmn_BomberMech")

lmn_Bombrun = Skill:new{
	Name = "Bomb Run",
	Class = "Unique",
	Icon = "weapons/lmn_bombrun.png",
	Description = "Flyer Only Weapon\n\nFly in a line and bomb any 2 tiles in transit.",
	AttackAnimation = "ExploArt2",
	Bombs = 2,
	Push = 0,
	Range = INT_MAX,
	Damage = 2,
	PowerCost = 0,
	Upgrades = 2,
	UpgradeCost = { 1, 2 },
	UpgradeList = { "Napalm", "Push" },
	LaunchSound = "/weapons/bomb_strafe",
	ImpactSound = "/impact/generic/explosion",
	CustomTipImage = "lmn_Bombrun_Tip",
	TipImage = {
		CustomPawn = "lmn_BomberMech",
		Unit = Point(2,4),
		Building = Point(2,3),
		Enemy = Point(2,2),
		Target = Point(2,2)
	}
}

function lmn_Bombrun:GetTargetArea(point)
	local ret = PointList()
	
	-- disable weapon for non-flyers.
	if not Pawn:IsFlying() then
		return ret
	end
	
	-- find valid flight paths
	-- based on bomb count.
	for i = DIR_START, DIR_END do
		local distance = 0
		for k = self.Bombs + 1, self.Range - self.Bombs do
			local curr = DIR_VECTORS[i]*k + point
			if not Board:IsValid(curr) then
				break
			end
			if not Board:IsBlocked(curr, Pawn:GetPathProf()) then
				distance = k
			end
		end
		for k = 1, distance do
			ret:push_back(DIR_VECTORS[i]*k + point)
		end
	end
	
	return ret
end

function lmn_Bombrun:GetSkillEffect(p1, p2, parentSkill, isTipImage)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	local distance = p1:Manhattan(p2)
	local distanceMax = 0
	
	-- calculate where bombs should land.
	for k = self.Bombs + 1, self.Range - self.Bombs do
		local curr = DIR_VECTORS[dir]*k + p1
		if not Board:IsValid(curr) then
			break
		end
		if not Board:IsBlocked(curr, Pawn:GetPathProf()) then
			distanceMax = k - 1
		end
	end
	if distance > distanceMax then distance = distanceMax end
	local bombStart = distance - self.Bombs + 1
	local bombEnd = distance
	
	while bombStart < 1 do
		bombStart = bombStart + 1
		bombEnd = bombEnd + 1
	end
	while bombEnd > distanceMax do
		bombStart = bombStart - 1
		bombEnd = bombEnd - 1
	end
	
	-- calculate where the plane should arrive at.
	for k = bombEnd + 1, INT_MAX do
		local curr = DIR_VECTORS[dir]*k + p1
		if not Board:IsValid(curr) then
			break
		end
		if not Board:IsBlocked(curr, Pawn:GetPathProf()) then
			distanceMax = k
			break
		end
	end
	
	-- add a small delay to allow the player
	-- to look back at the plane as it starts it's bombrun.
	ret:AddDelay(0.25)
	
	-- air graphics to emphasize speed.
	local damage = SpaceDamage(p1, 0)
	damage.sAnimation = "airpush_".. ((dir+2)%4)
	ret:AddDamage(damage)
	
	-- start plane.
	ret:AddCharge(Board:GetPath(p1, DIR_VECTORS[dir] * distanceMax + p1, PATH_FLYER), NO_DELAY)
	ret:AddBounce(p1, 3)
	
	local bombsLanded = 0
	local bombsInTransit = {}
	
	--[[
		charge speed is 0.08 per tile.
		t indicates how many tiles we
		are from the origin point.
	--]]
	local t = 1
	local bombTravelTime = math.ceil(ANIMS.lmn_bombdrop.Time * 125) -- 1 tick per .008 duration of animation
	while bombsLanded < self.Bombs do
		ret:AddDelay(0.08)
		
		--[[
			drop bombs on each tile from
			p1 + [bombStart, bombEnd]
			
			track them and deal damage later,
			when they have reached the ground.
		--]]
		if t >= bombStart and t <= bombEnd then
			local damage = SpaceDamage(DIR_VECTORS[dir]*t + p1, 0)
			damage.sAnimation = "lmn_bombdrop"
			damage.sSound = "/weapons/raining_volley_tile"
			ret:AddDamage(damage)
			table.insert(bombsInTransit, t + bombTravelTime)
		end
		
		-- if a bomb has reached the ground,
		-- apply it's damage.
		if bombsInTransit[1] == t then
			table.remove(bombsInTransit, 1)
			bombsLanded = bombsLanded + 1
			
			-- calculate bombed target location.
			local curr = DIR_VECTORS[dir] * (t - bombTravelTime) + p1
			damage = SpaceDamage(curr, self.Damage)
			damage.sAnimation = self.AttackAnimation
			damage.sSound = self.ImpactSound
			damage.iFire = self.Fire
			
			if self.Flip then
				damage.iPush = DIR_FLIP
			end
			
			-- bombed target damage.
			ret:AddDamage(damage)
			ret:AddBounce(curr, 3)
			
			-- push code to push tiles
			-- adjacent to bombed targets.
			if self.Push == 1 then
				local right = (dir+1)%4
				local left = (dir-1)%4
				local damage = SpaceDamage(curr + DIR_VECTORS[left], 0, left)
				damage.sAnimation = "exploout0_".. left
				ret:AddDamage(damage)
				
				damage = SpaceDamage(curr + DIR_VECTORS[right], 0, right)
				damage.sAnimation = "exploout0_".. right
				ret:AddDamage(damage)
			end
		end
		t = t + 1
	end
	
	return ret
end

lmn_Bombrun_A = lmn_Bombrun:new{
	UpgradeDescription = "Lights tiles on fire.",
	AttackAnimation = "explo_fire1",
	Fire = 1,
	CustomTipImage = "lmn_Bombrun_Tip_A"
}

lmn_Bombrun_B = lmn_Bombrun:new{
	UpgradeDescription = "Pushes adjacent tiles outwards.",
	Push = 1,
	CustomTipImage = "lmn_Bombrun_Tip_B",
	TipImage = {
		CustomPawn = "lmn_BomberMech",
		Unit = Point(2,4),
		Building = Point(2,3),
		Enemy = Point(2,2),
		Enemy2 = Point(1,2),
		Target = Point(2,2)
	}
}

lmn_Bombrun_AB = lmn_Bombrun:new{
	AttackAnimation = "explo_fire1",
	Fire = 1,
	Push = 1,
	CustomTipImage = "lmn_Bombrun_Tip_AB",
	TipImage = lmn_Bombrun_B.TipImage
}

lmn_Bombrun_Tip = lmn_Bombrun:new{}
lmn_Bombrun_Tip_A = lmn_Bombrun_A:new{}
lmn_Bombrun_Tip_B = lmn_Bombrun_B:new{}
lmn_Bombrun_Tip_AB = lmn_Bombrun_AB:new{}

function lmn_Bombrun_Tip:GetSkillEffect(p1, p2, parentSkill)
	local ret = lmn_Bombrun.GetSkillEffect(self, p1, p2, parentSkill, true)
	ret:AddDelay(2)
	
	return ret
end

lmn_Bombrun_Tip_A.GetSkillEffect = lmn_Bombrun_Tip.GetSkillEffect
lmn_Bombrun_Tip_B.GetSkillEffect = lmn_Bombrun_Tip.GetSkillEffect
lmn_Bombrun_Tip_AB.GetSkillEffect = lmn_Bombrun_Tip.GetSkillEffect

shop:addWeapon({
	id = "lmn_Bombrun",
	desc = "Adds Bomb Run to the store."
})

modApi:appendAsset("img/units/player/lmn_mech_bomber.png", resourcePath .."img/units/player/bomber.png")
modApi:appendAsset("img/units/player/lmn_mech_bomber_a.png", resourcePath .."img/units/player/bomber_a.png")
modApi:appendAsset("img/units/player/lmn_mech_bomber_broken.png", resourcePath .."img/units/player/bomber_broken.png")
modApi:appendAsset("img/units/player/lmn_mech_bomber_w_broken.png", resourcePath .."img/units/player/bomber_w_broken.png")
modApi:appendAsset("img/units/player/lmn_mech_bomber_ns.png", resourcePath .."img/units/player/bomber_ns.png")
modApi:appendAsset("img/units/player/lmn_mech_bomber_h.png", resourcePath .."img/units/player/bomber_h.png")

modApi:appendAsset("img/weapons/lmn_bombrun.png", resourcePath .."img/weapons/bombrun.png")
modApi:appendAsset("img/effects/lmn_explo_bomb.png", resourcePath .."img/effects/explo_bomb.png")

setfenv(1, ANIMS)
lmn_MechBomber =			MechUnit:new{ Image = "units/player/lmn_mech_bomber.png", PosX = -20, PosY = -10 }
lmn_MechBombera =			lmn_MechBomber:new{ Image = "units/player/lmn_mech_bomber_a.png", NumFrames = 4 }
lmn_MechBomber_broken =		lmn_MechBomber:new{ Image = "units/player/lmn_mech_bomber_broken.png", PosX = -21, PosY = 2 }
lmn_MechBomberw =			lmn_MechBomber:new{ Image = "units/player/lmn_mech_bomber_w_broken.png",  PosX = -21, PosY = 9 }
lmn_MechBomberw_broken =	lmn_MechBomberw:new{ Image = "units/player/lmn_mech_bomber_w_broken.png" }
lmn_MechBomber_ns =			MechIcon:new{ Image = "units/player/lmn_mech_bomber_ns.png" }

lmn_bombdrop = Animation:new{
	Image = "effects/lmn_explo_bomb.png",
	NumFrames = 10,
	Time = 0.032, --multiple of 0.008
	PosX = -18,
	PosY = -12
}
