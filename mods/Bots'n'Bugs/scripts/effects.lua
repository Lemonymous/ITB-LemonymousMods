
local mod = mod_loader.mods[modApi.currentMod]
local path = mod.resourcePath
local a = ANIMS

-- roach
modApi:appendAsset("img/effects/lmn_roachpush_U.png", path .."img/effects/acidpush_U.png")
modApi:appendAsset("img/effects/lmn_roachpush_R.png", path .."img/effects/acidpush_R.png")
modApi:appendAsset("img/effects/lmn_roachpush_D.png", path .."img/effects/acidpush_D.png")
modApi:appendAsset("img/effects/lmn_roachpush_L.png", path .."img/effects/acidpush_L.png")
modApi:appendAsset("img/effects/smoke/lmn_roach.png", path .."img/effects/smoke/roach.png")
modApi:appendAsset("img/effects/lmn_explo_roach.png", path .."img/effects/explo_roach.png")
modApi:appendAsset("img/effects/shotup_acid_roach.png", path .."img/effects/shotup_roach.png")
modApi:appendAsset("img/effects/shot_roach_U.png", path .."img/effects/shot_roach_U.png")
modApi:appendAsset("img/effects/shot_roach_R.png", path .."img/effects/shot_roach_R.png")

lmn_Emitter_Roach = Emitter_Pod:new{
	image = "effects/smoke/lmn_roach.png",
	birth_rate = 0.05,
	gravity = false,
	speed = 0.02,
	max_particles = 128,
}

a.lmn_exploout_roach_0 = a.exploout0_0:new{Image = "effects/lmn_roachpush_U.png"}
a.lmn_exploout_roach_1 = a.exploout0_1:new{Image = "effects/lmn_roachpush_R.png"}
a.lmn_exploout_roach_2 = a.exploout0_2:new{Image = "effects/lmn_roachpush_D.png"}
a.lmn_exploout_roach_3 = a.exploout0_3:new{Image = "effects/lmn_roachpush_L.png"}

a.lmn_ExploRoach = a.ExploAcid1:new{Image = "effects/lmn_explo_roach.png"}

-- spitter
modApi:appendAsset("img/effects/lmn_spitter_needle_R.png", path .."img/effects/needle_R.png")
modApi:appendAsset("img/effects/lmn_spitter_needle_U.png", path .."img/effects/needle_U.png")
modApi:appendAsset("img/effects/lmn_spitter_needle_explo.png", path .."img/effects/needle_explo.png")

modApi:appendAsset("img/effects/lmn_spitter_spit_U.png", path .."img/effects/spitU.png")
modApi:appendAsset("img/effects/lmn_spitter_spit_R.png", path .."img/effects/spitR.png")
modApi:appendAsset("img/effects/lmn_spitter_spit_D.png", path .."img/effects/spitD.png")
modApi:appendAsset("img/effects/lmn_spitter_spit_L.png", path .."img/effects/spitL.png")

a.lmn_spitter_spit_0 = a.Animation:new{
	Image = "effects/lmn_spitter_spit_U.png",
	NumFrames = 6,
	Time = .08,
	PosX = 6,
	PosY = -25
}

a.lmn_spitter_spit_1 = a.lmn_spitter_spit_0:new{
	Image = "effects/lmn_spitter_spit_R.png",
	PosX = -6,
	PosY = 12
}

a.lmn_spitter_spit_2 = a.lmn_spitter_spit_0:new{
	Image = "effects/lmn_spitter_spit_D.png",
	PosX = -53,
	PosY = 12
}

a.lmn_spitter_spit_3 = a.lmn_spitter_spit_0:new{
	Image = "effects/lmn_spitter_spit_L.png",
	PosX = -55,
	PosY = -25
}

a.lmn_spitter_explo = a.ExploFirefly1:new{
	Image = "effects/lmn_spitter_needle_explo.png",
	PosY = -6
}

-- crusher
modApi:appendAsset("img/effects/lmn_crusher_kaizer_U1.png", path .."img/effects/kaizerU1.png")
modApi:appendAsset("img/effects/lmn_crusher_kaizer_U2.png", path .."img/effects/kaizerU2.png")
modApi:appendAsset("img/effects/lmn_crusher_kaizer_R1.png", path .."img/effects/kaizerR1.png")
modApi:appendAsset("img/effects/lmn_crusher_kaizer_R2.png", path .."img/effects/kaizerR2.png")
modApi:appendAsset("img/effects/lmn_crusher_kaizer_D1.png", path .."img/effects/kaizerD1.png")
modApi:appendAsset("img/effects/lmn_crusher_kaizer_D2.png", path .."img/effects/kaizerD2.png")
modApi:appendAsset("img/effects/lmn_crusher_kaizer_L1.png", path .."img/effects/kaizerL1.png")
modApi:appendAsset("img/effects/lmn_crusher_kaizer_L2.png", path .."img/effects/kaizerL2.png")

a.lmn_explo_crusher_kaizerA_0 = a.Animation:new{
	Image = "effects/lmn_crusher_kaizer_U1.png",
	NumFrames = 6,
	Time = .04,
	PosX = -27,
	PosY = 7
}

a.lmn_explo_crusher_kaizerB_0 = a.lmn_explo_crusher_kaizerA_0:new{
	Image = "effects/lmn_crusher_kaizer_U2.png",
	PosX = -42,
	PosY = 0
}

a.lmn_explo_crusher_kaizerA_1 = a.lmn_explo_crusher_kaizerA_0:new{
	Image = "effects/lmn_crusher_kaizer_R1.png",
	PosX = -42,
	PosY = 0
}

a.lmn_explo_crusher_kaizerB_1 = a.lmn_explo_crusher_kaizerA_0:new{
	Image = "effects/lmn_crusher_kaizer_R2.png",
	PosX = -27,
	PosY = -10
}

a.lmn_explo_crusher_kaizerA_2 = a.lmn_explo_crusher_kaizerA_0:new{
	Image = "effects/lmn_crusher_kaizer_D1.png",
	PosX = -33,
	PosY = -10
}

a.lmn_explo_crusher_kaizerB_2 = a.lmn_explo_crusher_kaizerA_0:new{
	Image = "effects/lmn_crusher_kaizer_D2.png",
	PosX = -16,
	PosY = 0
}

a.lmn_explo_crusher_kaizerA_3 = a.lmn_explo_crusher_kaizerA_0:new{
	Image = "effects/lmn_crusher_kaizer_L1.png",
	PosX = -16,
	PosY = 0
}

a.lmn_explo_crusher_kaizerB_3 = a.lmn_explo_crusher_kaizerA_0:new{
	Image = "effects/lmn_crusher_kaizer_L2.png",
	PosX = -33,
	PosY = 7
}

-- wyrm
modApi:appendAsset("img/combat/lmn_wyrm_arrow_0.png", mod.resourcePath .."img/combat/projectile_close_02.png")
modApi:appendAsset("img/combat/lmn_wyrm_arrow_1.png", mod.resourcePath .."img/combat/projectile_close_13.png")
modApi:appendAsset("img/combat/lmn_wyrm_arrow_2.png", mod.resourcePath .."img/combat/projectile_close_02.png")
modApi:appendAsset("img/combat/lmn_wyrm_arrow_3.png", mod.resourcePath .."img/combat/projectile_close_13.png")

Location["combat/lmn_wyrm_arrow_0.png"] = Point(-27, 15)
Location["combat/lmn_wyrm_arrow_1.png"] = Point(-28, -6)
Location["combat/lmn_wyrm_arrow_2.png"] = Point(1, -6)
Location["combat/lmn_wyrm_arrow_3.png"] = Point(0, 15)

-- colony
modApi:appendAsset("img/effects/lmn_colony.png", mod.resourcePath .."img/effects/colony.png")

a.lmn_ExploColony = a.Animation:new{
	Image = "effects/lmn_colony.png",
	NumFrames = 4,
	Frames = {0,1,2,3,3,2,1,0},
	Time = .04,
	PosX = -5,
	PosY = 4
}

-- creep
for i = 0, 3 do
	a["lmn_creep_back_".. i] = a.CreepBack:new{
		Image = "combat/creep_strip4.png",
		-- play specific frame 0-3
		Frames = {i},
		-- increase this number if the animation appears blinking.
		Time = 0.03,
		Loop = false,
		Layer = LAYER_BACK,
	}

	a["lmn_creep_front_".. i] = a["lmn_creep_back_".. i]:new{
		Image = "combat/creepfront_strip4.png",
		PosY = 21,
		Layer = LAYER_FRONT,
	}
end

a.lmn_creep_back_start = a.lmn_creep_back_0:new{
	Image = "combat/creep_starting.png",
	NumFrames = 1,
	Layer = LAYER_BACK,
}

a.lmn_creep_front_start = a.lmn_creep_back_start:new{
	Image = "combat/creepfront_starting.png",
	NumFrames = 1,
	Layer = LAYER_FRONT,
}

-- tipimage creep
a.lmn_creep_front_init_tip = a.CreepFront:new{
	Frames = {0,1,2,3,0,1,2,3,0,1,2,3,0,1,2,3,4,0,1,2,3,0,1}, -- amounts to 4.25 seconds
	Time = 0.25,
	Loop = false,
	Layer = LAYER_FRONT,
}

a.lmn_creep_front_tip = a.CreepFront:new{
	Frames = {0,1,2,3,0,1,2,3,0,1,2,3,0}, -- amounts to 3.25 seconds
	Time = 0.25,
	Loop = false,
	Layer = LAYER_FRONT,
}

a.lmn_creep_back_init_tip = a.CreepBack:new{
	Frames = {0,1,2,3,0,1,2,3,0,1,2,3,0,1,2,3,4,0,1,2,3,0,1}, -- amounts to 4.25 seconds
	Time = 0.25,
	Loop = false,
	Layer = LAYER_BACK,
}

a.lmn_creep_back_tip = a.CreepBack:new{
	Frames = {0,1,2,3,0,1,2,3,0,1,2,3,0}, -- amounts to 3.25 seconds
	Time = 0.25,
	Loop = false,
	Layer = LAYER_FRONT,
}
