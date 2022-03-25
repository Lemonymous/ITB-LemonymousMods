
modApi:appendMechAssets("img/mechs", "aa_")
modApi:appendEffectAssets("img/effects", "aa_")
modApi:appendWeaponAssets("img/weapons", "aa_")
modApi:appendCombatIconAssets("img/combat/icons", "aa_")

modApi:copyAsset(
	"img/combat/icons/people.png",
	"img/combat/icons/aa_people.png"
)

Location["combat/icons/aa_people.png"] = Point(-35,-17)
Location["combat/icons/aa_people_none.png"] = Point(-35,-17)

modApi:createMechAnimations{
	aa_devastator	=
		{ PosX = -16, PosY = 1 },
	aa_devastator_ns =
		{},
	aa_devastatora =
		{ PosX = -16, PosY = 1, NumFrames = 4 },
	aa_devastator_broken =
		{ PosX = -16, PosY = 1 },
	aa_devastatorw =
		{ PosX = -16, PosY = 9 },
	aa_devastatorw_broken =
		{ PosX = -16, PosY = 9 },
}

modApi:createMechAnimations{
	aa_bomber =
		{ PosX = -20, PosY = -10 },
	aa_bomber_ns =
		{},
	aa_bombera =
		{ PosX = -20, PosY = -10, NumFrames = 4 },
	aa_bomber_broken =
		{ PosX = -21, PosY = 2 },
	aa_bomberw =
		{ PosX = -21, PosY = 9 },
	aa_bomberw_broken =
		{ PosX = -21, PosY = 9},
}

modApi:createMechAnimations{
	aa_apc =
		{ PosX = -19, PosY = 3 },
	aa_apc_ns =
		{},
	aa_apca =
		{ PosX = -19, PosY = 3, NumFrames = 4 },
	aa_apc_broken =
		{ PosX = -19, PosY = 3 },
	aa_apcw =
		{ PosX = -19, PosY = 13 },
	aa_apcw_broken =
		{ PosX = -19, PosY = 13 },
}

modApi:createAnimations{
	aa_bombdrop = {
		Image = "effects/aa_explo_bomb.png",
		NumFrames = 10,
		Time = 0.032, --multiple of 0.008
		PosX = -18,
		PosY = -12
	},
}
