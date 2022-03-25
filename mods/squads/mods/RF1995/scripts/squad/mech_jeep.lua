
local mod = mod_loader.mods[modApi.currentMod]
local imageOffset = modApi:getPaletteImageOffset(mod.id)

lmn_JeepMech = Pawn:new{
	Name = "Jeep",
	Class = "Science",
	Health = 1,
	MoveSpeed = 5,
	Image = "rf_jeep",
	ImageOffset = imageOffset,
	SkillList = { "lmn_Jeep_Grenade" },
	SoundLocation = "/support/civilian_truck/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
}
AddPawnName("lmn_JeepMech")

lmn_Jeep_Grenade = Skill:new{
	Name = "Hand Grenades",
	Class = "Science",
	Icon = "weapons/rf_grenade.png",
	Description = "Lobs a grenade at one of the 8 surrounding tiles.",
	UpShot = "effects/rf_shotup_grenade.png",
	Range = 1,
	Damage = 2,
	Push = 0,
	PowerCost = 1,
	ArtilleryHeight = 14,
	Upgrades = 2,
	UpgradeCost = {1, 3},
	UpgradeList = {"Push", "+2 Damage"},
	LaunchSound = "/weapons/raining_volley_tile",
	ImpactSound = "/impact/generic/explosion",
	TipImage = {
		CustomPawn = "lmn_JeepMech",
		Unit = Point(2,3),
		Enemy = Point(2,2),
		Enemy2 = Point(3,2),
		Target = Point(3,2),
		Second_Origin = Point(2,3),
		Second_Target = Point(2,2),
	}
}

function lmn_Jeep_Grenade:GetTargetArea(point)
	local ret = PointList()
	local targets = {
		Point(-1,-1), Point(-1, 0), Point(-1, 1),
		Point( 0,-1), Point( 0, 1),
		Point( 1,-1), Point( 1, 0), Point( 1, 1)
	}
	
	for k = 1, #targets do
		if Board:IsValid(point + targets[k]) then
			ret:push_back(point + targets[k])
		end
	end
	
	return ret
end

function lmn_Jeep_Grenade:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	
	local damage = SpaceDamage(p2, self.Damage)
	damage.sAnimation = "explo_fire1"
	ret:AddArtillery(damage, self.UpShot)
	ret:AddBounce(p2, 3)
	
	if self.Push == 1 then
		for i = DIR_START, DIR_END do
			local curr = DIR_VECTORS[i] + p2
			damage = SpaceDamage(curr, 0)
			damage.iPush = i
			damage.sAnimation = "exploout0_".. i
			ret:AddDamage(damage)
		end
	end
	
	return ret
end

lmn_Jeep_Grenade_A = lmn_Jeep_Grenade:new{
	UpgradeDescription = "Push adjacent tiles.",
	Push = 1,
}

lmn_Jeep_Grenade_B = lmn_Jeep_Grenade:new{
	UpgradeDescription = "Increases damage by 2.",
	ImpactSound = "/impact/generic/explosion_large",
	Damage = 4,
}

lmn_Jeep_Grenade_AB = lmn_Jeep_Grenade:new{
	ImpactSound = "/impact/generic/explosion_large",
	Damage = 4,
	Push = 1,
}

modApi:addWeaponDrop("lmn_Jeep_Grenade")
