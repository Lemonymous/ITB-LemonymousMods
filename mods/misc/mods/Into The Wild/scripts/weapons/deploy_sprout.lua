
-- F this for now.
lmn_DeploySkill_Sprout = DeploySkill_Tank:new{
	Icon = "weapons/lmn_deploy_sprout.png",
	--Rarity = 4, -- TODO low rarity when testing
	Deployed = "lmn_Deploy_Sprout",
	Projectile = "effects/shotup_lmn_copter1.png", -- TODO new
	PowerCost = 2,
	Upgrades = 2,
	UpgradeCost = {2, 2},
	LaunchSound = "/weapons/deploy_tank", -- TODO
	ImpactSound = "/impact/generic/mech", -- TODO
	TipImage = {
		Unit = Point(1,3),
		Target = Point(1,1),
		Enemy = Point(2,1),
		Second_Origin = Point(1,1),
		Second_Target = Point(2,1),
	},
}

lmn_DeploySkill_Sprout_A = lmn_DeploySkill_Sprout:new{
	UpgradeDescription = "Increases the Sprout's potential hit tiles by 1.",
	Deployed = "lmn_Deploy_SproutA"
}
lmn_DeploySkill_Sprout_B = lmn_DeploySkill_Sprout:new{
	UpgradeDescription = "Increases the Sprout's attack damage to 2.",
	Deployed = "lmn_Deploy_SproutB"
}
lmn_DeploySkill_Sprout_AB = lmn_DeploySkill_Sprout:new{
	Deployed = "lmn_Deploy_SproutAB"
}

lmn_Deploy_Sprout = lmn_Sprout1:new{
	Name = "Support Sprout",
	Health = 1,
	MoveSpeed = 4,
	Image = "lmn_Sprout1", -- TODO recolor/swap
	SkillList = { "lmn_Deploy_SproutAtk" },
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_FLESH,
	Flying = true,
	Portrait = "enemy/lmn_Sprout1", -- ok?
}

lmn_Deploy_SproutA = lmn_Deploy_Sprout:new{ SkillList = {"lmn_Deploy_SproutAtkA"} }
lmn_Deploy_SproutB = lmn_Deploy_Sprout:new{ SkillList = {"lmn_Deploy_SproutAtkB"} }
lmn_Deploy_SproutAB = lmn_Deploy_Sprout:new{ SkillList = {"lmn_Deploy_SproutAtkAB"} }

lmn_Deploy_SproutAtk = Skill:new{
	Name = "Stinger",
	Description = "Stab the target.",
	--Icon = "weapons/lmn_SproutAtk1.png", -- TODO
	Class = "Unique",
	Push = 1,
	Damage = 0,
	PathSize = 1,
	TipImage = {
		Unit = Point(2,2),
		Enemy = Point(2,1),
		Target = Point(2,1),
		CustomPawn = "lmn_Deploy_Sprout"
	}
}

lmn_Deploy_SproutAtkA = lmn_Deploy_SproutAtk:new{ PathSize = 2 }
lmn_Deploy_SproutAtkB = lmn_Deploy_SproutAtk:new{ Damage = 2 }
lmn_Deploy_SproutAtkAB = lmn_Deploy_SproutAtk:new{ PathSize = 2, Damage = 2 }

function lmn_Deploy_SproutAtk:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local direction = GetDirection(p2 - p1)
	local distance = p1:Manhattan(p2)

	for i = 1, distance do
		local push = self.Push == 1 and (i == distance) and direction * self.Push or DIR_NONE
		local damage = SpaceDamage(p1 + DIR_VECTORS[direction] * i, self.Damage, push)
		damage.sAnimation = "explohornet_".. direction
		damage.fDelay = 0.15
		ret:AddDamage(damage)
	end
	
	return ret
end