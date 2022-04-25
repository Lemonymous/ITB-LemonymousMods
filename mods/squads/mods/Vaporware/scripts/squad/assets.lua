
modApi:appendMechAssets("img/mechs", "vw_")
modApi:appendEffectAssets("img/effects", "vw_")
modApi:appendWeaponAssets("img/weapons", "vw_")
modApi:appendCombatAssets("img/combat", "vw_")
modApi:appendCombatIconAssets("img/combat/icons", "vw_")

modApi:copyAsset(
	"img/combat/icons/icon_smoke_glow.png", 
	"img/combat/icons/vw_icon_smoke_glow.png"
)
modApi:copyAsset(
	"img/combat/icons/icon_smoke_immune_glow.png", 
	"img/combat/icons/vw_icon_smoke_immune_glow.png"
)
modApi:copyAsset(
	"img/combat/arrow_hit.png", 
	"img/combat/vw_arrow_hit.png"
)

Location["combat/icons/vw_icon_smoke_glow.png"] = Point(-10,8)
Location["combat/icons/vw_icon_smoke_immune_glow.png"] = Point(-10,8)
Location["combat/icons/vw_icon_zephyr_destroy.png"] = Point(-10,8)
Location["combat/vw_arrow_hit+smoke.png"] = Point(-15,6)
Location["combat/vw_arrow_hit.png"] = Point(-15,6)

modApi:createMechAnimations{
	vw_shroud =
		{ CenterX = 15, CenterY = 26 },
	vw_shroud_ns =
		{},
	vw_shrouda =
		{ CenterX = 15, CenterY = 26, NumFrames = 4 },
	vw_shroud_broken =
		{ CenterX = 15, CenterY = 26 },
	vw_shroudw =
		{ CenterX = 15, CenterY = 13 },
	vw_shroudw_broken =
		{ CenterX = 15, CenterY = 13 },
}

modApi:createMechAnimations{
	vw_zephyr =
		{ CenterX = 20, CenterY = 24 },
	vw_zephyr_ns =
		{},
	vw_zephyra =
		{ CenterX = 20, CenterY = 24, NumFrames = 4 },
	vw_zephyr_broken =
		{ CenterX = 20, CenterY = 18 },
	vw_zephyrw =
		{ CenterX = 20, CenterY = 13 },
	vw_zephyrw_broken =
		{ CenterX = 20, CenterY = 7 },
}

modApi:createMechAnimations{
	vw_vortex =
		{ CenterX = 18, CenterY = 27 },
	vw_vortex_ns =
		{},
	vw_vortexa =
		{ CenterX = 18, CenterY = 27, NumFrames = 4 },
	vw_vortex_broken =
		{ CenterX = 18, CenterY = 27 },
	vw_vortexw =
		{ CenterX = 18, CenterY = 16 },
	vw_vortexw_broken =
		{ CenterX = 18, CenterY = 13 },
}

modApi:createAnimations{
	vw_smoke_move_0 = {
		Image = "effects/vw_smoke_move_D.png",
		PosX = -51,
		PosY = -21,
		Time = 0.016,
		NumFrames = 14,
	},
	vw_whirl = {
		Image = "effects/vw_whirl.png",
		NumFrames = 11,
		Time = 0.06,
		PosX = -35,
		PosY = -19,
		Layer = LAYER_BACK,
	},
}

modApi:createAnimations{
	vw_smoke_move_1 = {
		Base = "vw_smoke_move_0",
		Image = "effects/vw_smoke_move_L.png",
	},
	vw_smoke_move_2 = {
		Base = "vw_smoke_move_0",
		Image = "effects/vw_smoke_move_U.png",
	},
	vw_smoke_move_3 = {
		Base = "vw_smoke_move_0",
		Image = "effects/vw_smoke_move_R.png",
	},
}
