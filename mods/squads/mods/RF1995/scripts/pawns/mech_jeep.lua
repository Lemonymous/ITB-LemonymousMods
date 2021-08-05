
local mod = mod_loader.mods[modApi.currentMod]
local resourcePath = mod.resourcePath
local scriptPath = mod.scriptPath

local imageOffset = modApi:getPaletteImageOffset(mod.id)
local modApiExt = require(scriptPath .."modApiExt/modApiExt")
local shop = require(scriptPath .."libs/shop")
local nonMassiveDeployWarning = require(scriptPath .."libs/nonMassiveDeployWarning")
local worldConstants = LApi.library:fetch("worldConstants")
local weaponHover = require(scriptPath .."libs/weaponHover")
local weaponArmed = require(scriptPath .."libs/weaponArmed")

modApi:appendAsset("img/units/player/lmn_mech_jeep.png", resourcePath .."img/units/player/jeep.png")
modApi:appendAsset("img/units/player/lmn_mech_jeep_a.png", resourcePath .."img/units/player/jeep_a.png")
modApi:appendAsset("img/units/player/lmn_mech_jeep_w.png", resourcePath .."img/units/player/jeep_w.png")
modApi:appendAsset("img/units/player/lmn_mech_jeep_broken.png", resourcePath .."img/units/player/jeep_broken.png")
modApi:appendAsset("img/units/player/lmn_mech_jeep_w_broken.png", resourcePath .."img/units/player/jeep_w_broken.png")
modApi:appendAsset("img/units/player/lmn_mech_jeep_ns.png", resourcePath .."img/units/player/jeep_ns.png")
modApi:appendAsset("img/units/player/lmn_mech_jeep_h.png", resourcePath .."img/units/player/jeep_h.png")

modApi:appendAsset("img/effects/lmn_shotup_jeep_grenade.png", resourcePath .."img/effects/shotup_grenade.png")
modApi:appendAsset("img/weapons/lmn_jeep_grenade.png", resourcePath .."img/weapons/grenade.png")

local a = ANIMS
a.lmn_MechJeep =			a.MechUnit:new{ Image = "units/player/lmn_mech_jeep.png", PosX = -11, PosY = 6 }
a.lmn_MechJeepa =			a.lmn_MechJeep:new{ Image = "units/player/lmn_mech_jeep_a.png", PosY = 5, NumFrames = 2 }
a.lmn_MechJeep_broken =		a.lmn_MechJeep:new{ Image = "units/player/lmn_mech_jeep_broken.png" }
a.lmn_MechJeepw =			a.lmn_MechJeep:new{ Image = "units/player/lmn_mech_jeep_w.png", PosY = 13 }
a.lmn_MechJeepw_broken =	a.lmn_MechJeepw:new{ Image = "units/player/lmn_mech_jeep_w_broken.png" }
a.lmn_MechJeep_ns =			a.MechIcon:new{ Image = "units/player/lmn_mech_jeep_ns.png" }

lmn_JeepMech = Pawn:new{
	Name = "Jeep",
	Class = "Science",
	Health = 1,
	MoveSpeed = 5,
	Image = "lmn_MechJeep",
	ImageOffset = imageOffset,
	SkillList = { "lmn_Jeep_Grenade" },
	SoundLocation = "/support/civilian_truck/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
}
AddPawn("lmn_JeepMech")

lmn_Jeep_Grenade = Skill:new{
	Name = "Hand Grenades",
	Class = "Science",
	Icon = "weapons/lmn_jeep_grenade.png",
	Description = "Lobs a grenade at one of the 8 surrounding tiles.",
	UpShot = "effects/lmn_shotup_jeep_grenade.png",
	Range = 1,
	Damage = 2,
	Push = 0,
	PowerCost = 1,
	Y_Velocity = 14,
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

weaponHover:Add("lmn_Jeep_Grenade", onHover, onUnhover)
weaponHover:Add("lmn_Jeep_Grenade_A", onHover, onUnhover)
weaponHover:Add("lmn_Jeep_Grenade_B", onHover, onUnhover)
weaponHover:Add("lmn_Jeep_Grenade_AB", onHover, onUnhover)

weaponArmed:Add("lmn_Jeep_Grenade", onHover, onUnhover)
weaponArmed:Add("lmn_Jeep_Grenade_A", onHover, onUnhover)
weaponArmed:Add("lmn_Jeep_Grenade_B", onHover, onUnhover)
weaponArmed:Add("lmn_Jeep_Grenade_AB", onHover, onUnhover)

nonMassiveDeployWarning:AddPawn("lmn_JeepMech")
shop:addWeapon{ id = "lmn_Jeep_Grenade", desc = "Adds Hand Grenades to the store." }

local function init() end
local function load() end

return { init = init, load = load }
