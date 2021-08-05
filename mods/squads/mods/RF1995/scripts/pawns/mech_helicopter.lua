
local mod = mod_loader.mods[modApi.currentMod]
local resourcePath = mod.resourcePath
local scriptPath = mod.scriptPath

local imageOffset = modApi:getPaletteImageOffset(mod.id)
local modApiExt = require(scriptPath .."modApiExt/modApiExt")
local worldConstants = LApi.library:fetch("worldConstants")
local weaponHover = require(scriptPath .."libs/weaponHover")
local weaponArmed = require(scriptPath .."libs/weaponArmed")
local effectBurst = require(scriptPath .."libs/effectBurst")
local nonMassiveDeployWarning = require(scriptPath .."libs/nonMassiveDeployWarning")
local shop = require(scriptPath .."libs/shop")

modApi:appendAsset("img/units/player/lmn_mech_helicopter.png", resourcePath .."img/units/player/helicopter.png")
modApi:appendAsset("img/units/player/lmn_mech_helicopter_a.png", resourcePath .."img/units/player/helicopter_a.png")
modApi:appendAsset("img/units/player/lmn_mech_helicopter_broken.png", resourcePath .."img/units/player/helicopter_broken.png")
modApi:appendAsset("img/units/player/lmn_mech_helicopter_w_broken.png", resourcePath .."img/units/player/helicopter_w_broken.png")
modApi:appendAsset("img/units/player/lmn_mech_helicopter_ns.png", resourcePath .."img/units/player/helicopter_ns.png")
modApi:appendAsset("img/units/player/lmn_mech_helicopter_h.png", resourcePath .."img/units/player/helicopter_h.png")

modApi:appendAsset("img/effects/lmn_helicopter_shot_missile_U.png", resourcePath .."img/effects/shot_missile_U.png")
modApi:appendAsset("img/effects/lmn_helicopter_shot_missile_R.png", resourcePath .."img/effects/shot_missile_R.png")
modApi:appendAsset("img/effects/lmn_helicopter_shotup_missile.png", resourcePath .."img/effects/shotup_missile.png")

modApi:appendAsset("img/weapons/lmn_helicopter_rocket.png", resourcePath.."img/weapons/rocket.png")

lmn_Emitter_Helicopter_Rocket = Emitter_Missile:new{
	image = "effects/smoke/art_smoke.png",
	y = 8,
	variance = 0,
	variance_y = 3,
	variance_x = 6,
	burst_count = 5,
	layer = LAYER_FRONT
}

local a = ANIMS
a.lmn_MechHelicopter =			a.MechUnit:new{ Image = "units/player/lmn_mech_helicopter.png", PosX = -15, PosY = 0 }
a.lmn_MechHelicoptera =			a.lmn_MechHelicopter:new{ Image = "units/player/lmn_mech_helicopter_a.png", NumFrames = 4 }
a.lmn_MechHelicopter_broken =	a.lmn_MechHelicopter:new{ Image = "units/player/lmn_mech_helicopter_broken.png", PosY = 9 }
a.lmn_MechHelicopterw =			a.lmn_MechHelicopter:new{ Image = "units/player/lmn_mech_helicopter_w_broken.png", PosY = 14 }
a.lmn_MechHelicopterw_broken =	a.lmn_MechHelicopterw:new{ Image = "units/player/lmn_mech_helicopter_w_broken.png" }
a.lmn_MechHelicopter_ns =		a.MechIcon:new{ Image = "units/player/lmn_mech_helicopter_ns.png" }

lmn_HelicopterMech = Pawn:new{
	Name = "Helicopter",
	Class = "Brute",
	Health = 1,
	MoveSpeed = 4,
	Image = "lmn_MechHelicopter",
	ImageOffset = imageOffset,
	SkillList = { "lmn_Helicopter_Rocket" },
	SoundLocation = "/support/support_drone/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Flying = true,
}
AddPawn("lmn_HelicopterMech")

lmn_Helicopter_Rocket = Skill:new{
	Name = "Leto Rockets",
	Class = "Brute",
	Icon = "weapons/lmn_helicopter_rocket.png",
	Description = "Lobs a rocket at a tile on a cornerless 5x5 square, damaging and pushing it.",
	UpShot = "effects/lmn_helicopter_shotup_missile.png",
	ProjectileArt = "effects/lmn_helicopter_shot_missile",
	Range = 2,
	Push = 1,
	Damage = 1,
	PowerCost = 1,
	PointBlank = 0,
	Y_Velocity = 15,
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

local function onHover(self, type)
	Values.y_velocity = self.Y_Velocity
end

local function onUnhover(self, type)
	if
		not weaponHover:IsCurrent(type) and
		not weaponArmed:IsCurrent(type)
	then
		Values.y_velocity = worldConstants:getDefaultHeight()
	end
end

weaponHover:Add("lmn_Helicopter_Rocket", onHover, onUnhover)
weaponHover:Add("lmn_Helicopter_Rocket_A", onHover, onUnhover)
weaponHover:Add("lmn_Helicopter_Rocket_B", onHover, onUnhover)
weaponHover:Add("lmn_Helicopter_Rocket_AB", onHover, onUnhover)

weaponArmed:Add("lmn_Helicopter_Rocket", onHover, onUnhover)
weaponArmed:Add("lmn_Helicopter_Rocket_A", onHover, onUnhover)
weaponArmed:Add("lmn_Helicopter_Rocket_B", onHover, onUnhover)
weaponArmed:Add("lmn_Helicopter_Rocket_AB", onHover, onUnhover)

nonMassiveDeployWarning:AddPawn("lmn_HelicopterMech")
shop:addWeapon{ id = "lmn_Helicopter_Rocket", desc = "Adds Leto Rockets to the store." }

local function init() end
local function load() end

return { init = init, load = load }
