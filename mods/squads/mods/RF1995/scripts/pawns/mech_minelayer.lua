
local mod = mod_loader.mods[modApi.currentMod]
local resourcePath = mod.resourcePath
local scriptPath = mod.scriptPath

local modApiExt = require(scriptPath .."modApiExt/modApiExt")
local colorMaps = require(scriptPath .."libs/colorMaps")
local nonMassiveDeployWarning = require(scriptPath .."libs/nonMassiveDeployWarning")
local weapon_launcher = require(scriptPath .."weapons/weapon_launcher")
local weapon_minelayer = require(scriptPath .."weapons/weapon_minelayer")

modApi:appendAsset("img/units/player/lmn_mech_minelayer.png", resourcePath .."img/units/player/minelayer.png")
modApi:appendAsset("img/units/player/lmn_mech_minelayer_a.png", resourcePath .."img/units/player/minelayer_a.png")
modApi:appendAsset("img/units/player/lmn_mech_minelayer_w.png", resourcePath .."img/units/player/minelayer_w.png")
modApi:appendAsset("img/units/player/lmn_mech_minelayer_broken.png", resourcePath .."img/units/player/minelayer_broken.png")
modApi:appendAsset("img/units/player/lmn_mech_minelayer_w_broken.png", resourcePath .."img/units/player/minelayer_w_broken.png")
modApi:appendAsset("img/units/player/lmn_mech_minelayer_ns.png", resourcePath .."img/units/player/minelayer_ns.png")
modApi:appendAsset("img/units/player/lmn_mech_minelayer_h.png", resourcePath .."img/units/player/minelayer_h.png")

local a = ANIMS
a.lmn_MechMinelayer =			a.MechUnit:new{ Image = "units/player/lmn_mech_minelayer.png", PosX = -14, PosY = 7 }
a.lmn_MechMinelayera =			a.lmn_MechMinelayer:new{ Image = "units/player/lmn_mech_minelayer_a.png", NumFrames = 4 }
a.lmn_MechMinelayer_broken =	a.lmn_MechMinelayer:new{ Image = "units/player/lmn_mech_minelayer_broken.png" }
a.lmn_MechMinelayerw =			a.lmn_MechMinelayer:new{ Image = "units/player/lmn_mech_minelayer_w.png", PosY = 14 }
a.lmn_MechMinelayerw_broken =	a.lmn_MechMinelayerw:new{ Image = "units/player/lmn_mech_minelayer_w_broken.png" }
a.lmn_MechMinelayer_ns =		a.MechIcon:new{ Image = "units/player/lmn_mech_minelayer_ns.png" }

lmn_MinelayerMech = Pawn:new{
	Name = "Rocket Artillery",
	Class = "Ranged",
	Health = 2,
	MoveSpeed = 2,
	Image = "lmn_MechMinelayer",
	ImageOffset = colorMaps.Get(mod.id),
	SkillList = { "lmn_Minelayer_Launcher", "lmn_Minelayer_Mine" },
	SoundLocation = "/support/civilian_artillery/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
}
AddPawn("lmn_MinelayerMech")

nonMassiveDeployWarning:AddPawn("lmn_MinelayerMech")
weapon_launcher:load()
weapon_minelayer:load()

local function init() end
local function load() end

return { init = init, load = load }