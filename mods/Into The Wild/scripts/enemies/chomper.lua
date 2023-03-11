
local mod = modApi:getCurrentMod()
local path = mod.resourcePath
local utils = require(path .."scripts/libs/utils")

WeakPawns.lmn_Chomper = true
Spawner.max_pawns.lmn_Chomper = 3

local writePath = "img/units/aliens/"
local readPath = path .. "img/units/aliens/"
local imagePath = writePath:sub(5,-1)
utils.appendAssets{
	writePath = writePath,
	readPath = readPath,
	{"lmn_chomper1.png", "chomper1.png"},
	{"lmn_chomper1a.png", "chomper1a.png"},
	{"lmn_chomper1_emerge.png", "chomper1e.png"},
	{"lmn_chomper1_death.png", "chomper1d.png"},
	{"lmn_chomper1w.png", "chomper1.png"},

	{"lmn_chomper2.png", "chomper2.png"},
	{"lmn_chomper2a.png", "chomper2a.png"},
	{"lmn_chomper2_emerge.png", "chomper2e.png"},
	{"lmn_chomper2_death.png", "chomper2d.png"},
	{"lmn_chomper2w.png", "chomper2.png"},
}

utils.appendAssets{
	writePath = "img/",
	readPath = path .."img/",
	{"portraits/enemy/lmn_Chomper1.png", "portraits/chomper1.png"},
	{"portraits/enemy/lmn_Chomper2.png", "portraits/chomper2.png"},
	{"portraits/enemy/lmn_ChomperBoss.png", "portraits/chomperBoss.png"},
	{"portraits/pilots/Pilot_lmn_Chomper.png", "portraits/chomper.png"},
	{"weapons/lmn_ChomperAtk.png", "weapons/iron_jaws.png"},
	{"weapons/lmn_ChomperAtk1.png", "weapons/chomperAtk1.png"},
	{"weapons/lmn_ChomperAtk2.png", "weapons/chomperAtk2.png"},
	{"weapons/lmn_ChomperAtkB.png", "weapons/chomperAtkB.png"},
	{"effects/lmn_ChomperAtk_0.png", "effects/chomperAtk_0.png"},
	{"effects/lmn_ChomperAtk_1.png", "effects/chomperAtk_1.png"},
	{"effects/lmn_ChomperAtk_2.png", "effects/chomperAtk_2.png"},
	{"effects/lmn_ChomperAtk_3.png", "effects/chomperAtk_3.png"},
}

local a = ANIMS
local base = a.BaseUnit:new{Image = imagePath .."lmn_chomper1.png", PosX = -16, PosY = -16}
local alpha = a.BaseUnit:new{Image = imagePath .."lmn_chomper2.png", PosX = -22, PosY = -12}
local baseEmerge = a.BaseEmerge:new{Image = imagePath .."lmn_chomper1_emerge.png", PosX = -23, PosY = -16, Height = 1, NumFrames = 13,
	Lengths = {.15, .15, .15, .15, .075, .075, .075, .15, .075, .075, .15, .15, .15}
}
local alphaEmerge = a.BaseEmerge:new{Image = imagePath .."lmn_chomper2_emerge.png", PosX = -23, PosY = -12, Height = 1, NumFrames = 13}

a.lmn_Chomper1 = base
a.lmn_Chomper1a = base:new{Image = imagePath .."lmn_chomper1a.png", NumFrames = 6}
a.lmn_Chomper1e = baseEmerge
a.lmn_Chomper1d = base:new{Image = imagePath .."lmn_chomper1_death.png", PosX = -22, PosY = -14, Loop = false, NumFrames = 10, Time = .14}
a.lmn_Chomper1w = base:new{Image = imagePath .."lmn_chomper1w.png"}

a.lmn_Chomper2 = alpha
a.lmn_Chomper2a = alpha:new{Image = imagePath .."lmn_chomper2a.png", NumFrames = 6}
a.lmn_Chomper2e = alphaEmerge
a.lmn_Chomper2d = alpha:new{Image = imagePath .."lmn_chomper2_death.png", PosX = -24, PosY = -16, Loop = false, NumFrames = 10, Time = .14}
a.lmn_Chomper2w = alpha:new{Image = imagePath .."lmn_chomper2w.png"}

utils.appendAssets{
	writePath = "img/units/player/",
	readPath = path .."img/units/aliens/",

	{"lmn_chomper.png", "chomper.png"},
	{"lmn_chomper_a.png", "chompera.png"},
	{"lmn_chomper_broken.png", "chomperd.png"},
	{"lmn_chomper_w.png", "chomperw.png"},
	{"lmn_chomper_w_broken.png", "chomperwd.png"},
	{"lmn_chomper_ns.png", "chomperns.png"},
	{"lmn_chomper_h.png", "chomperh.png"},
}

local imagePath = "units/player/"
local base = a.MechUnit:new{Image = imagePath .."lmn_chomper.png", PosX = -16, PosY = -16}

a.lmn_Chomper = base
a.lmn_Chompera = base:new{Image = imagePath .."lmn_chomper_a.png", NumFrames = 6}
a.lmn_Chomper_broken = base:new{Image = imagePath .."lmn_chomper_broken.png"}
a.lmn_Chomperw = base:new{Image = imagePath .."lmn_chomper_w.png", PosY = -4}
a.lmn_Chomperw_broken = base:new{Image = imagePath .."lmn_chomper_w_broken.png", PosY = -4}
a.lmn_Chomper_ns = a.MechIcon:new{Image = imagePath .."lmn_chomper_ns.png"}

a.lmn_ChomperAtk_0 = a.explopunch1_0:new{ Image = "effects/lmn_ChomperAtk_0.png", NumFrames = 5, PosX = -19, PosY = -5 }
a.lmn_ChomperAtk_1 = a.explopunch1_1:new{ Image = "effects/lmn_ChomperAtk_1.png", NumFrames = 5, PosX = -14, PosY = -2,  }
a.lmn_ChomperAtk_2 = a.explopunch1_2:new{ Image = "effects/lmn_ChomperAtk_2.png", NumFrames = 5, PosX = -10, PosY = -2,  }
a.lmn_ChomperAtk_3 = a.explopunch1_3:new{ Image = "effects/lmn_ChomperAtk_3.png", NumFrames = 5, PosX = -7, PosY = -5 }

CreatePilot{
	Id = "Pilot_lmn_Chomper",
	Personality = "Vek",
	Sex = SEX_VEK,
	Skill = "Survive_Death",
	Rarity = 0,
	Blacklist = {"Invulnerable", "Popular"},
}

lmn_Chomper1 = Pawn:new{
	Name = "Chomper",
	Health = 3,
	MoveSpeed = 3,
	Image = "lmn_Chomper1",
	SkillList = { "lmn_ChomperAtk1" },
	SoundLocation = "/enemy/beetle_1/",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_FLESH,
	Portrait = "enemy/lmn_Chomper1",
}
AddPawnName("lmn_Chomper1")

lmn_Chomper2 = lmn_Chomper1:new{
	Name = "Alpha Chomper",
	Health = 5,
	Image = "lmn_Chomper2",
	SkillList = { "lmn_ChomperAtk2" },
	SoundLocation = "/enemy/beetle_2/",
	Portrait = "enemy/lmn_Chomper2",
	Tier = TIER_ALPHA,
}
AddPawnName("lmn_Chomper2")

lmn_ChomperAtk1 = Skill:new{
	Name = "Chomp",
	Description = "Pull in a target within 2 tiles and bite it.\n\n(Stable targets pull in Chomper instead)",
	--Description = "Pull self towards objects, or units to self, and bite them. Range: 2",
	Icon = "weapons/lmn_ChomperAtk1.png",
	Class = "Enemy",
	PathSize = 1,
	Range = 2,
	Damage = 2,
	Anim_Impact = "lmn_ChomperAtk_",
	SoundBase = "/enemy/scorpion_soldier_1",
	TipImage = {
		Unit = Point(2,2),
		Enemy = Point(2,0),
		Target = Point(2,1),
		Second_Origin = Point(2,2),
		Second_Target = Point(2,3),
		Building = Point(2,4),
		CustomPawn = "lmn_Chomper1"
	}
}

lmn_ChomperAtk2 = lmn_ChomperAtk1:new{
	Icon = "weapons/lmn_ChomperAtk2.png",
	Damage = 4,
	Anim_Impact = "lmn_ChomperAtk_",
	SoundBase = "/enemy/scorpion_soldier_2",
	TipImage = {
		Unit = Point(2,2),
		Enemy = Point(2,0),
		Target = Point(2,1),
		Second_Origin = Point(2,2),
		Second_Target = Point(2,3),
		Building = Point(2,4),
		CustomPawn = "lmn_Chomper2"
	}
}

local bonusDamageTable = {
	Passive_FriendlyFire = 1,
	Passive_FriendlyFire_A = 2,
	Passive_FriendlyFire_B = 2,
	Passive_FriendlyFire_AB = 3
}

local function getBonusDamage(casterLoc, targetLoc)
	local bonusDamage = 0

	if Board:IsPawnTeam(casterLoc, TEAM_ENEMY) and Board:IsPawnTeam(targetLoc, TEAM_ENEMY) then
		for i, damage in pairs(bonusDamageTable) do
			if IsPassiveSkill(i) then
				bonusDamage = math.max(bonusDamage, damage)
			end
		end
	end

	return bonusDamage
end

function lmn_ChomperAtk1:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	local adjacent = p1 + DIR_VECTORS[dir]
	local target = utils.GetProjectileEnd(p1, p2, self.Range)
	local distance = p1:Manhattan(target)
	local pawn = Board:GetPawn(target)
	local d = SpaceDamage(adjacent)
	local pullPawn = pawn and not pawn:IsGuarding() and distance > 1

	d.sSound = self.SoundBase .."/attack"

	if not pullPawn then
		if Board:IsBlocked(target, PATH_PROJECTILE) then
			ret:AddQueuedCharge(Board:GetSimplePath(p1, target - DIR_VECTORS[dir]), FULL_DELAY)
			d.sSound = "/weapons/charge_impact"
			d.loc = target
		end
		d.iDamage = self.Damage
		d.sAnimation = self.Anim_Impact .. dir
	end

	ret:AddQueuedMelee(d.loc - DIR_VECTORS[dir], d, NO_DELAY)

	if pullPawn then
		-- charge pawn towards chomper.
		ret:AddQueuedDelay(0.25)
		ret:AddQueuedCharge(Board:GetSimplePath(target, adjacent), FULL_DELAY)

		local damage = math.min(DAMAGE_DEATH, self.Damage + getBonusDamage(p1, target))
		local d = SpaceDamage(adjacent, damage)
		d.sSound = "/weapons/charge_impact"
		d.sAnimation = self.Anim_Impact .. dir
		ret:AddQueuedMelee(p1, d, NO_DELAY)
	end

	return ret
end

lmn_Chomper = Pawn:new{
	Name = "Techno-Chomper",
	Class = "TechnoVek",
	Icon = path .."img/units/aliens/chomperic.png",
	Health = 3,
	MoveSpeed = 3,
	Image = "lmn_Chomper",
	ImageOffset = 8,
	SkillList = { "lmn_ChomperAtk" },
	SoundLocation = "/enemy/beetle_1/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_FLESH,
	Massive = true
}
AddPawnName("lmn_Chomper")

lmn_ChomperAtk = Skill:new{
	Name = "Iron Jaws",
	Description = "Pulls in a target within 2 tiles to bite it.\n\n(Stable targets pull you in instead)",
	--Description = "Pulls itself towards objects, or units to itself, and bites them. Range: 2",
	--Description = "Pull in a target within two tiles and bite it.",
	Icon = "weapons/lmn_ChomperAtk1.png",
	Class = "TechnoVek",
	Range = 2,
	Damage = 2,
	Anim_Impact = "lmn_ChomperAtk_",
	SoundBase = "/enemy/scorpion_soldier_1",
	PowerCost = 1,
	Upgrades = 2,
	UpgradeCost = {2, 3},
	UpgradeList = { "Range & Damage", "Range & Damage" },
	TipImage = {
		Unit = Point(2,2),
		Enemy = Point(2,0),
		Target = Point(2,1),
		Second_Origin = Point(2,2),
		Second_Target = Point(2,3),
		Mountain = Point(2,4),
		CustomPawn = "lmn_Chomper"
	}
}

function lmn_ChomperAtk:GetTargetArea(p)
	local ret = PointList()

	for i = DIR_START, DIR_END do
		local step = DIR_VECTORS[i]
		local target = p + step

		for k = 1, self.Range do
			local curr = p + step * k

			if not Board:IsValid(curr) then
				break
			end

			if Board:IsBlocked(curr, PATH_PROJECTILE) then
				target = curr
				break
			end
		end

		if target == p + step then
			ret:push_back(target)
		else
			local dist = p:Manhattan(target)
			for k = 1, dist do
				ret:push_back(p + step * k)
			end
		end
	end

	return ret
end

function lmn_ChomperAtk:GetSkillEffect(p1, p2)
	local ret = lmn_ChomperAtk1.GetSkillEffect(self, p1, p2, lmn_ChomperAtk1)
	ret.effect = ret.q_effect
	ret.q_effect = SkillEffect().q_effect

	return ret
end

lmn_ChomperAtk_A = lmn_ChomperAtk:new{
	UpgradeDescription = "Increases range and damage by 1.",
	Range = 3,
	Damage = 3,
}

lmn_ChomperAtk_B = lmn_ChomperAtk_A:new{}
lmn_ChomperAtk_AB = lmn_ChomperAtk:new{
	Range = 4,
	Damage = 4,
}
