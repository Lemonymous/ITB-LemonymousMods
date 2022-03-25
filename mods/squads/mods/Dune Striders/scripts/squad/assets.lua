
modApi:appendMechAssets("img/mechs", "ds_")
modApi:appendEffectAssets("img/effects", "ds_")
modApi:appendWeaponAssets("img/weapons", "ds_")

modApi:copyAsset(
	"img/combat/icons/icon_sand_glow.png",
	"img/combat/icons/ds_icon_sand_glow.png"
)
modApi:copyAsset(
	"img/combat/icons/icon_smoke_glow.png", 
	"img/combat/icons/ds_icon_smoke_glow.png"
)
modApi:copyAsset(
	"img/combat/icons/icon_smoke_immune_glow.png", 
	"img/combat/icons/ds_icon_smoke_immune_glow.png"
)
modApi:copyAsset(
	"img/combat/icons/icon_postmove_glow.png",
	"img/combat/icons/ds_icon_bonus_move_glow.png"
)
modApi:copyAsset(
	"img/combat/icons/icon_fire_immune_glow.png", 
	"img/combat/icons/ds_icon_fire_immune_glow.png"
)

local laser_loc = Point(-12,3)
Location["combat/icons/ds_icon_sand_glow.png"] = Point(-13,12)
Location["combat/icons/ds_icon_smoke_glow.png"] = Point(-10,8)
Location["combat/icons/ds_icon_smoke_immune_glow.png"] = Point(-10,8)
Location["combat/icons/ds_icon_bonus_move_glow.png"] = Point(-13,-2)
Location["combat/icons/ds_icon_fire_immune_glow.png"] = Point(-10,8)
Location["effects/ds_laser_U.png"] = laser_loc
Location["effects/ds_laser_U1.png"] = laser_loc
Location["effects/ds_laser_U2.png"] = laser_loc
Location["effects/ds_laser_R.png"] = laser_loc
Location["effects/ds_laser_R1.png"] = laser_loc
Location["effects/ds_laser_R2.png"] = laser_loc
Location["effects/ds_laser_hit.png"] = laser_loc
Location["effects/ds_laser_start.png"] = laser_loc

modApi:createMechAnimations{
	ds_commando	=
		{ PosX = -12, PosY = -10 },
	ds_commando_ns =
		{},
	ds_commandoa =
		{ PosX = -12, PosY = -10, NumFrames = 4 },
	ds_commando_broken =
		{ PosX = -12, PosY = -10 },
	ds_commandow =
		{ PosX = -12, PosY = 6 },
	ds_commandow_broken =
		{ PosX = -12, PosY = 6 },
}

modApi:createMechAnimations{
	ds_gunslinger =
		{ PosX = -12, PosY = -4 },
	ds_gunslinger_ns =
		{},
	ds_gunslingera =
		{ PosX = -12, PosY = -4, NumFrames = 4 },
	ds_gunslinger_broken =
		{ PosX = -14, PosY = -2 },
	ds_gunslingerw =
		{ PosX = -14, PosY = 12 },
	ds_gunslingerw_broken =
		{ PosX = -14, PosY = 12 },
}

modApi:createMechAnimations{
	ds_swoop =
		{ PosX = -24, PosY = -14 },
	ds_swoop_ns =
		{},
	ds_swoopa =
		{ PosX = -24, PosY = -14, NumFrames = 4 },
	ds_swoop_broken =
		{ PosX = -24, PosY = -8 },
	ds_swoopw =
		{ PosX = -24, PosY = 6 },
	ds_swoopw_broken =
		{ PosX = -24, PosY = 6 },
}

modApi:createAnimations{
	ds_explo_smoke = {
		Base = "ExploAir2",
		Image = "effects/ds_explo_smoke.png",
	},
	ds_explo_plasma = {
		Base = "ExploAir1",
		Image = "effects/ds_explo_plasma.png",
	},
}
