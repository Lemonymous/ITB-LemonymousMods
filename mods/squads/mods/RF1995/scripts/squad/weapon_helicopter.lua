
local effectBurst = LApi.library:fetch("effectBurst")

lmn_Emitter_Helicopter_Rocket = Emitter_Missile:new{
	image = "effects/smoke/art_smoke.png",
	y = 8,
	variance = 0,
	variance_y = 3,
	variance_x = 6,
	burst_count = 5,
	layer = LAYER_FRONT
}

lmn_Helicopter_Rocket = Skill:new{
	Name = "Leto Rockets",
	Class = "Brute",
	Icon = "weapons/rf_rocket.png",
	Description = "Lobs a rocket at a tile on a cornerless 5x5 square, damaging and pushing it.",
	UpShot = "effects/rf_shotup_missile.png",
	ProjectileArt = "effects/rf_shot_missile",
	Range = 2,
	Push = 1,
	Damage = 1,
	PowerCost = 1,
	PointBlank = 0,
	ArtilleryHeight = 15,
	Upgrades = 2,
	UpgradeCost = {1, 2},
	UpgradeList = {"Point Blank", "+1 Damage"},
	LaunchSound = "/weapons/shrapnel",
	ImpactSound = "/impact/generic/explosion",
	CustomTipImage = "lmn_Helicopter_Rocket_Tip",
	TipImage = {
		CustomPawn = "lmn_HelicopterMech",
		Unit = Point(2,3),
		Enemy = Point(2,1),
		Enemy2 = Point(1,1),
		Mountain = Point(2,2),
		Target = Point(1,1),
		Second_Origin = Point(2,3),
		Second_Target = Point(2,1),
	}
}

function lmn_Helicopter_Rocket:GetTargetArea(point)
	local ret = PointList()
	local targets = { 
		Point(-2,-1), Point(-2, 0), Point(-2, 1),
		Point( 2,-1), Point( 2, 0), Point( 2, 1),
		Point(-1,-2), Point( 0,-2), Point( 1,-2),
		Point(-1, 2), Point( 0, 2), Point( 1, 2)
	}
	if self.PointBlank == 1 then
		table.insert(targets, Point(-1, 0))
		table.insert(targets, Point( 1, 0))
		table.insert(targets, Point( 0,-1))
		table.insert(targets, Point( 0, 1))
	end
	
	for k = 1, #targets do
		if Board:IsValid(point + targets[k]) then
			ret:push_back(point + targets[k])
		end
	end
	
	return ret
end

function lmn_Helicopter_Rocket:GetSkillEffect(p1, p2, parentSkill, isTipImage)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	local distance = p1:Manhattan(p2)
	
	local damage = SpaceDamage(p2, self.Damage)
	if self.Push then
		damage.iPush = dir
		damage.sAnimation = "airpush_".. dir
	end
	
	local damageAnim = SpaceDamage(p2, 0)
	if distance > 1 then
		ret:AddArtillery(damage, self.UpShot)
		damageAnim.sAnimation = "ExploAir1"
	else
		effectBurst.Add(ret, p1, "lmn_Emitter_Helicopter_Rocket", dir, isTipImage)
		ret:AddProjectile(damage, self.ProjectileArt)
		effectBurst.Add(ret, p2, "lmn_Emitter_Helicopter_Rocket", dir, isTipImage)
		damageAnim.sAnimation = "explopush1_".. dir
	end
	
	ret:AddDamage(damageAnim)
	ret:AddBounce(p2, 1)
	return ret
end

lmn_Helicopter_Rocket_A = lmn_Helicopter_Rocket:new{
	UpgradeDescription = "Allows attacking adjacent tiles.",
	PointBlank = 1,
	CustomTipImage = "lmn_Helicopter_Rocket_Tip_A",
	TipImage = {
		CustomPawn = "lmn_HelicopterMech",
		Unit = Point(2,3),
		Enemy = Point(1,1),
		Enemy2 = Point(2,2),
		Target = Point(2,2),
		Second_Origin = Point(2,3),
		Second_Target = Point(1,1),
	}
}

lmn_Helicopter_Rocket_B = lmn_Helicopter_Rocket:new{
	UpgradeDescription = "Increases damage by 1.",
	Damage = 2,
	CustomTipImage = "lmn_Helicopter_Rocket_Tip_B",
}

lmn_Helicopter_Rocket_AB = lmn_Helicopter_Rocket:new{
	Damage = 2,
	PointBlank = 1,
	CustomTipImage = "lmn_Helicopter_Rocket_Tip_AB",
	TipImage = lmn_Helicopter_Rocket_A.TipImage
}

lmn_Helicopter_Rocket_Tip = lmn_Helicopter_Rocket:new{}
lmn_Helicopter_Rocket_Tip_A = lmn_Helicopter_Rocket_A:new{}
lmn_Helicopter_Rocket_Tip_B = lmn_Helicopter_Rocket_B:new{}
lmn_Helicopter_Rocket_Tip_AB = lmn_Helicopter_Rocket_AB:new{}

function lmn_Helicopter_Rocket_Tip:GetSkillEffect(p1, p2, parentSkill)
	return lmn_Helicopter_Rocket.GetSkillEffect(self, p1, p2, parentSkill, true)
end

lmn_Helicopter_Rocket_Tip_A.GetSkillEffect = lmn_Helicopter_Rocket_Tip.GetSkillEffect
lmn_Helicopter_Rocket_Tip_B.GetSkillEffect = lmn_Helicopter_Rocket_Tip.GetSkillEffect
lmn_Helicopter_Rocket_Tip_AB.GetSkillEffect = lmn_Helicopter_Rocket_Tip.GetSkillEffect

modApi:addWeaponDrop("lmn_Helicopter_Rocket")
