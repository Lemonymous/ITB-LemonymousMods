
local path = mod_loader.mods[modApi.currentMod].resourcePath
local utils = require(path .."scripts/utils")
modApi:appendAsset("img/weapons/lmn_deploy_copter.png", path .."img/weapons/deploy_copter.png")
modApi:appendAsset("img/portraits/npcs/lmn_copter.png", path .."img/portraits/npcs/copter.png")
modApi:appendAsset("img/effects/shotup_lmn_copter_deploy.png", path .."img/effects/copter_deploy_shotup.png")
modApi:appendAsset("img/effects/emitters/lmn_petal_copter_deploy.png", path .."img/effects/emitters/petal_copter_deploy.png")

local writePath = "img/units/mission/"
local readPath = path .. "img/units/aliens/"
local imagePath = writePath:sub(5,-1)
utils.appendAssets{
	writePath = writePath,
	readPath = readPath,
	{"lmn_copter_deploy.png", "copter_deploy.png"},
	{"lmn_copter_deploya.png", "copter_deploya.png"},
	{"lmn_copter_deploy_death.png", "copter_deployd.png"}
}

local a = ANIMS
local base = a.BaseUnit:new{Image = imagePath .."lmn_copter_deploy.png", PosX = -15, PosY = -15}

a.lmn_Copter_Deploy = base
a.lmn_Copter_Deploya = base:new{Image = imagePath .."lmn_copter_deploya.png", NumFrames = 4}
a.lmn_Copter_Deployd = base:new{Image = imagePath .."lmn_copter_deploy_death.png", NumFrames = 10, Time = .14, Loop = false}

lmn_Emitter_Copter_Deploy = lmn_Emitter_Copter1d:new{ image = "effects/emitters/lmn_petal_copter_deploy.png" }

lmn_DeploySkill_Copter = DeploySkill_Tank:new{
	Name = "Support Copter",
	Description = "Deploy a reprogrammed Copter to help in combat.",
	Icon = "weapons/lmn_deploy_copter.png",
	Rarity = 4,
	Deployed = "lmn_Deploy_Copter",
	Projectile = "effects/shotup_lmn_copter_deploy.png",
	PowerCost = 2,
	Upgrades = 2,
	UpgradeCost = {2, 3},
	UpgradeList = { "Range & Damage", "Range & Damage" },
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

function lmn_DeploySkill_Copter:GetTargetArea(p)
	local ret = PointList()
	
	for dir = DIR_START, DIR_END do
		for i = 2, self.ArtillerySize do
			local curr = Point(p + DIR_VECTORS[dir] * i)
			if not Board:IsValid(curr) then
				break
			end
			
			if not Board:IsBlocked(curr, PATH_FLYER) then
				ret:push_back(curr)
			end
		end
	end
	
	return ret
end

lmn_DeploySkill_Copter_A = lmn_DeploySkill_Copter:new{
	UpgradeDescription = "Increases the Copter's potential hit tiles and damage by 1.",
	Deployed = "lmn_Deploy_CopterA",
	TipImage = shallow_copy(lmn_DeploySkill_Copter.TipImage)
}
lmn_DeploySkill_Copter_A.TipImage.Enemy2 = Point(3,1)
lmn_DeploySkill_Copter_A.TipImage.Second_Target = Point(3,1)

lmn_DeploySkill_Copter_B = lmn_DeploySkill_Copter:new{
	UpgradeDescription = "Increases the Copter's potential hit tiles and damage by 1.",
	Deployed = "lmn_Deploy_CopterB",
	TipImage = lmn_DeploySkill_Copter_A.TipImage
}
lmn_DeploySkill_Copter_AB = lmn_DeploySkill_Copter:new{
	Deployed = "lmn_Deploy_CopterAB",
	TipImage = shallow_copy(lmn_DeploySkill_Copter_A.TipImage)
}
lmn_DeploySkill_Copter_AB.TipImage.Enemy3 = Point(4,1)
lmn_DeploySkill_Copter_AB.TipImage.Second_Target = Point(4,1)

lmn_Deploy_Copter = lmn_Copter1:new{
	Name = "Support Copter",
	Health = 1,
	MoveSpeed = 4,
	lmn_PetalsOnDeath = "lmn_Emitter_Copter_Deploy",
	Image = "lmn_Copter_Deploy",
	SkillList = { "lmn_Deploy_CopterAtk" },
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_FLESH,
	Flying = true,
	Portrait = "npcs/lmn_copter",
}

lmn_Deploy_CopterA = lmn_Deploy_Copter:new{ SkillList = {"lmn_Deploy_CopterAtkA"} }
lmn_Deploy_CopterB = lmn_Deploy_Copter:new{ SkillList = {"lmn_Deploy_CopterAtkB"} }
lmn_Deploy_CopterAB = lmn_Deploy_Copter:new{ SkillList = {"lmn_Deploy_CopterAtkAB"} }

lmn_Deploy_CopterAtk = Prime_Spear:new{
	Name = "Stinger",
	Description = "Stab the target.",
	Icon = "weapons/enemy_hornet2.png",
	Class = "Unique",
	LaunchSound = "default",
	Push = 1,
	Damage = 0,
	PathSize = 1,
	TipImage = {
		Unit = Point(2,2),
		Enemy = Point(2,1),
		Target = Point(2,1),
		CustomPawn = "lmn_Deploy_Copter"
	}
}

lmn_Deploy_CopterAtkA = lmn_Deploy_CopterAtk:new{ Damage = 1, PathSize = 2 }
lmn_Deploy_CopterAtkB = lmn_Deploy_CopterAtkA:new{}
lmn_Deploy_CopterAtkAB = lmn_Deploy_CopterAtk:new{ Damage = 2, PathSize = 3 }

function lmn_Deploy_CopterAtk:GetSkillEffect(p1, p2)
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