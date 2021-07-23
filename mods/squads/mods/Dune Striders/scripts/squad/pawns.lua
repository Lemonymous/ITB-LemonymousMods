
local mod = mod_loader.mods[modApi.currentMod]
--local colorMaps = require(mod.scriptPath .."libs/colorMaps")
--local imageOffset = colorMaps.Get(mod.id)
local imageOffset = modApi:getPaletteImageOffset(mod.id)

modApi:appendAsset("img/units/player/lmn_ds_commando.png", mod.resourcePath.. "img/units/player/commando.png")
modApi:appendAsset("img/units/player/lmn_ds_commando_a.png", mod.resourcePath.. "img/units/player/commando_a.png")
modApi:appendAsset("img/units/player/lmn_ds_commando_w.png", mod.resourcePath.. "img/units/player/commando_w.png")
modApi:appendAsset("img/units/player/lmn_ds_commando_broken.png", mod.resourcePath.. "img/units/player/commando_b.png")
modApi:appendAsset("img/units/player/lmn_ds_commando_w_broken.png", mod.resourcePath.. "img/units/player/commando_wb.png")
modApi:appendAsset("img/units/player/lmn_ds_commando_ns.png", mod.resourcePath.. "img/units/player/commando_ns.png")
modApi:appendAsset("img/units/player/lmn_ds_commando_h.png", mod.resourcePath.. "img/units/player/commando_h.png")

modApi:appendAsset("img/units/player/lmn_ds_gunslinger.png", mod.resourcePath.. "img/units/player/gunslinger.png")
modApi:appendAsset("img/units/player/lmn_ds_gunslinger_a.png", mod.resourcePath.. "img/units/player/gunslinger_a.png")
modApi:appendAsset("img/units/player/lmn_ds_gunslinger_w.png", mod.resourcePath.. "img/units/player/gunslinger_w.png")
modApi:appendAsset("img/units/player/lmn_ds_gunslinger_broken.png", mod.resourcePath.. "img/units/player/gunslinger_b.png")
modApi:appendAsset("img/units/player/lmn_ds_gunslinger_w_broken.png", mod.resourcePath.. "img/units/player/gunslinger_wb.png")
modApi:appendAsset("img/units/player/lmn_ds_gunslinger_ns.png", mod.resourcePath.. "img/units/player/gunslinger_ns.png")
modApi:appendAsset("img/units/player/lmn_ds_gunslinger_h.png", mod.resourcePath.. "img/units/player/gunslinger_h.png")

modApi:appendAsset("img/units/player/lmn_ds_swoop.png", mod.resourcePath.. "img/units/player/swoop.png")
modApi:appendAsset("img/units/player/lmn_ds_swoop_a.png", mod.resourcePath.. "img/units/player/swoop_a.png")
modApi:appendAsset("img/units/player/lmn_ds_swoop_w.png", mod.resourcePath.. "img/units/player/swoop_w.png")
modApi:appendAsset("img/units/player/lmn_ds_swoop_broken.png", mod.resourcePath.. "img/units/player/swoop_b.png")
modApi:appendAsset("img/units/player/lmn_ds_swoop_w_broken.png", mod.resourcePath.. "img/units/player/swoop_wb.png")
modApi:appendAsset("img/units/player/lmn_ds_swoop_ns.png", mod.resourcePath.. "img/units/player/swoop_ns.png")
modApi:appendAsset("img/units/player/lmn_ds_swoop_h.png", mod.resourcePath.. "img/units/player/swoop_h.png")

lmn_ds_Commando = {
	Name = "Commando Mech",
	Class = "Prime",
	Image = "lmn_ds_Commando",
	ImageOffset = imageOffset,
	MoveSpeed = 3,
	Health = 3,
	SkillList = { "lmn_ds_PulseRifle" },
	SoundLocation = "/mech/prime/punch_mech/",
	MoveSkill = "lmn_ds_Teleport",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Massive = true,
	Teleporter = true
}
AddPawn("lmn_ds_Commando")

lmn_ds_Gunslinger = {
	Name = "Gunslinger Mech",
	Class = "Brute",
	Image = "lmn_ds_Gunslinger",
	ImageOffset = imageOffset,
	MoveSpeed = 4,
	Health = 2,
	SkillList = { "lmn_ds_DualPistols" },
	SoundLocation = "/mech/prime/punch_mech/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Massive = true
}
AddPawn("lmn_ds_Gunslinger")

lmn_ds_Swoop = {
	Name = "Swoop Mech",
	Class = "Science",
	Image = "lmn_ds_Swoop",
	ImageOffset = imageOffset,
	MoveSpeed = 4,
	Health = 2,
	SkillList = { "lmn_ds_HaulerHooks" },
	SoundLocation = "/mech/flying/jet_mech/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Massive = true,
	Flying = true
}
AddPawn("lmn_ds_Swoop")

setfenv(1, ANIMS)
lmn_ds_Commando =				MechUnit:new{ Image = "units/player/lmn_ds_commando.png", PosX = -12, PosY = -10 }
lmn_ds_Commandoa =				lmn_ds_Commando:new{ Image = "units/player/lmn_ds_commando_a.png", NumFrames = 4 }
lmn_ds_Commando_broken =		lmn_ds_Commando:new{ Image = "units/player/lmn_ds_commando_broken.png" }
lmn_ds_Commandow =				lmn_ds_Commando:new{ Image = "units/player/lmn_ds_commando_w.png", PosY = 6 }
lmn_ds_Commandow_broken =		lmn_ds_Commandow:new{ Image = "units/player/lmn_ds_commando_w_broken.png" }
lmn_ds_Commando_ns =			MechIcon:new{ Image = "units/player/lmn_ds_commando_ns.png" }

lmn_ds_Gunslinger =			MechUnit:new{ Image = "units/player/lmn_ds_gunslinger.png", PosX = -12, PosY = -4 }
lmn_ds_Gunslingera =			lmn_ds_Gunslinger:new{ Image = "units/player/lmn_ds_gunslinger_a.png", NumFrames = 4 }
lmn_ds_Gunslinger_broken =		lmn_ds_Gunslinger:new{ Image = "units/player/lmn_ds_gunslinger_broken.png", PosX = -14, PosY = -2 }
lmn_ds_Gunslingerw =			lmn_ds_Gunslinger:new{ Image = "units/player/lmn_ds_gunslinger_w.png", PosX = -14, PosY = 12 }
lmn_ds_Gunslingerw_broken =	lmn_ds_Gunslingerw:new{ Image = "units/player/lmn_ds_gunslinger_w_broken.png" }
lmn_ds_Gunslinger_ns =			MechIcon:new{ Image = "units/player/lmn_ds_gunslinger_ns.png" }

lmn_ds_Swoop =					MechUnit:new{ Image = "units/player/lmn_ds_swoop.png", PosX = -24, PosY = -14 }
lmn_ds_Swoopa =				lmn_ds_Swoop:new{ Image = "units/player/lmn_ds_swoop_a.png", NumFrames = 4 }
lmn_ds_Swoop_broken =			lmn_ds_Swoop:new{ Image = "units/player/lmn_ds_swoop_broken.png", PosY = -8 }
lmn_ds_Swoopw =				lmn_ds_Swoop:new{ Image = "units/player/lmn_ds_swoop_w.png", PosY = 6 }
lmn_ds_Swoopw_broken =		lmn_ds_Swoopw:new{ Image = "units/player/lmn_ds_swoop_w_broken.png" }
lmn_ds_Swoop_ns =				MechIcon:new{ Image = "units/player/lmn_ds_swoop_ns.png" }
