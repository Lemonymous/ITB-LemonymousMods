
modApi:appendMechAssets("img/mechs", "rf_")
modApi:appendEffectAssets("img/effects", "rf_")
modApi:appendWeaponAssets("img/weapons", "rf_")
modApi:appendCombatAssets("img/combat", "rf_")
modApi:appendCombatIconAssets("img/combat/icons", "rf_")

Location["combat/rf_mine_small.png"] = Point(-8,3)
Location["combat/rf_mark_mine_small.png"] = Point(-8,3)
Location["combat/icons/rf_icon_minesweeper_glow.png"] = Location["combat/icons/icon_mine_glow.png"]
Location["combat/icons/rf_icon_strikeout.png"] = Point(-13,10)

for i = 1, 4 do
	Location["combat/rf_preview_arrow_".. i ..".png"] = Point(-16, 0)
end

for i = 1, 2 do
	Location["combat/rf_faded_".. i ..".png"] = Point(-9,10)
end

modApi:createMechAnimations{
	rf_helicopter =
		{ PosX = -15, PosY = 0 },
	rf_helicopter_ns =
		{},
	rf_helicoptera =
		{ PosX = -15, PosY = 0, NumFrames = 4 },
	rf_helicopter_broken =
		{ PosX = -15, PosY = 9 },
	rf_helicopterw =
		{ PosX = -15, PosY = 14 },
	rf_helicopterw_broken =
		{ PosX = -15, PosY = 14 },
}

modApi:createMechAnimations{
	rf_jeep =
		{ PosX = -11, PosY = 6 },
	rf_jeep_ns =
		{},
	rf_jeepa =
		{ PosX = -11, PosY = 5, NumFrames = 2 },
	rf_jeep_broken =
		{ PosX = -11, PosY = 6 },
	rf_jeepw =
		{ PosX = -11, PosY = 13 },
	rf_jeepw_broken =
		{ PosX = -11, PosY = 13 },
}

modApi:createMechAnimations{
	rf_minelayer =
		{ PosX = -14, PosY = 7 },
	rf_minelayer_ns =
		{},
	rf_minelayera =
		{ PosX = -14, PosY = 7, NumFrames = 4 },
	rf_minelayer_broken =
		{ PosX = -14, PosY = 7 },
	rf_minelayerw =
		{ PosX = -14, PosY = 14 },
	rf_minelayerw_broken =
		{ PosX = -14, PosY = 14 },
}

modApi:createMechAnimations{
	rf_tank =
		{ PosX = -15, PosY = 9 },
	rf_tank_ns =
		{},
	rf_tanka =
		{ PosX = -15, PosY = 9, NumFrames = 2 },
	rf_tank_broken =
		{ PosX = -15, PosY = 9 },
	rf_tankw =
		{ PosX = -15, PosY = 17 },
	rf_tankw_broken =
		{ PosX = -15, PosY = 17 },
}
