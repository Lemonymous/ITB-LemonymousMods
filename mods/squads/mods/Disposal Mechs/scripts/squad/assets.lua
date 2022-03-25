
modApi:appendMechAssets("img/mechs", "dm_")
modApi:appendEffectAssets("img/effects", "dm_")
modApi:appendWeaponAssets("img/weapons", "dm_")
modApi:appendCombatAssets("img/combat", "dm_")

-- custom blank damage icons to cause blinking to happen without showing the skull when damaging.
-- we want to stay below 1000 damage so we don't overwrite DAMAGE_DEATH events.

-- damage reduced by armor
modApi:copyAsset(
	"img/empty.png",
	"img/combat/icons/damage_498.png"
)
-- normal damage
modApi:copyAsset(
	"img/empty.png",
	"img/combat/icons/damage_499.png"
)
-- acid on thrown pawn, armor on crushed pawn (or visa versa?)
modApi:copyAsset(
	"img/empty.png",
	"img/combat/icons/damage_996.png"
)
-- damage doubled by acid
modApi:copyAsset(
	"img/empty.png",
	"img/combat/icons/damage_998.png"
)

for i, dir in ipairs{"up", "right", "down", "left"} do
	Location["combat/dm_arrow_off_"..(i - 1)..".png"] = Location["combat/arrow_"..dir..".png"]
end

modApi:createMechAnimations{
	dm_stacker	=
		{ PosX = -17, PosY = 2 },
	dm_stacker_ns =
		{},
	dm_stackera =
		{ PosX = -17, PosY = 2, NumFrames = 4 },
	dm_stacker_broken =
		{ PosX = -17, PosY = 2 },
	dm_stackerw =
		{ PosX = -17, PosY = 10 },
	dm_stackerw_broken =
		{ PosX = -17, PosY = 10 },
}

modApi:createMechAnimations{
	dm_dozer =
		{ PosX = -19, PosY = 2 },
	dm_dozer_ns =
		{},
	dm_dozera =
		{ PosX = -19, PosY = 2, NumFrames = 3 },
	dm_dozer_broken =
		{ PosX = -19, PosY = 2 },
	dm_dozerw =
		{ PosX = -20, PosY = 11 },
	dm_dozerw_broken =
		{ PosX = -20, PosY = 11 },
}

modApi:createMechAnimations{
	dm_dissolver =
		{ PosX = -19, PosY = 0 },
	dm_dissolver_ns =
		{},
	dm_dissolvera =
		{ PosX = -19, PosY = 0, NumFrames = 4 },
	dm_dissolver_broken =
		{ PosX = -19, PosY = 0 },
	dm_dissolverw =
		{ PosX = -19, PosY = 8 },
	dm_dissolverw_broken =
		{ PosX = -19, PosY = 8 },
}

modApi:createAnimations{
	dm_exploforklift_0 = {
		Image = "effects/dm_forklift_U.png",
		NumFrames = 8,
		Layer = LAYER_BACK,
		Time = 0.06,
		PosX = -22,
		PosY = -9,
	},
	dm_acidthrower1_0 = Animation:new{
		Image = "effects/dm_acidthrower1_U.png",
		NumFrames = 9,
		Time = 0.07,
		PosX = -60,
		PosY = -8
	},
	dm_acidthrower1_1 = Animation:new{
		Image = "effects/dm_acidthrower1_R.png",
		NumFrames = 9,
		Time = 0.07,
		PosX = -62,
		PosY = -34,
	},
	dm_acidthrower1_2 = Animation:new{
		Image = "effects/dm_acidthrower1_D.png",
		NumFrames = 9,
		Time = 0.07,
		PosX = -25,
		PosY = -34,
	},
	dm_acidthrower1_3 = Animation:new{
		Image = "effects/dm_acidthrower1_L.png",
		NumFrames = 9,
		Time = 0.07,
		PosX = -22,
		PosY = -8,
	},
}

modApi:createAnimations{
	dm_exploforklift_1 = {
		Base = "dm_exploforklift_0",
		Image = "effects/dm_forklift_R.png",
	},
	dm_exploforklift_2 = {
		Base = "dm_exploforklift_0",
		Image = "effects/dm_forklift_D.png",
	},
	dm_exploforklift_3 = {
		Base = "dm_exploforklift_0",
		Image = "effects/dm_forklift_L.png",
	},
	dm_acidthrower2_0 = {
		Base = "dm_acidthrower1_0",
		Image = "effects/dm_acidthrower2_U.png",
	},
	dm_acidthrower3_0 = {
		Base = "dm_acidthrower1_0",
		Image = "effects/dm_acidthrower3_U.png",
	},
	dm_acidthrower2_1 = {
		Base = "dm_acidthrower1_1",
		Image = "effects/dm_acidthrower2_R.png",
	},
	dm_acidthrower3_1 = {
		Base = "dm_acidthrower1_1",
		Image = "effects/dm_acidthrower3_R.png",
	},
	dm_acidthrower2_2 = {
		Base = "dm_acidthrower1_2",
		Image = "effects/dm_acidthrower2_D.png",
	},
	dm_acidthrower3_2 = {
		Base = "dm_acidthrower1_2",
		Image = "effects/dm_acidthrower3_D.png",
	},
	dm_acidthrower2_3 = {
		Base = "dm_acidthrower1_3",
		Image = "effects/dm_acidthrower2_L.png",
	},
	dm_acidthrower3_3 = {
		Base = "dm_acidthrower1_3",
		Image = "effects/dm_acidthrower3_L.png",
	},
}
