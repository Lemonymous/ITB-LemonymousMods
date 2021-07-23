
local path = mod_loader.mods[modApi.currentMod].resourcePath
local utils = require(path .."scripts/utils")
local this = {}

function this:init(mod)
	--WeakPawns.lmn_Copter = false
	--Spawner.max_pawns.lmn_Copter = 3
	
	local writePath = "img/units/aliens/"
	local readPath = path .. "img/units/aliens/"
	local imagePath = writePath:sub(5,-1)
	utils.appendAssets{
		writePath = writePath,
		readPath = readPath,
		{"lmn_copter1.png", "copter1.png"},
		{"lmn_copter1a.png", "copter1a.png"},
		{"lmn_copter1_emerge.png", "copter1.png"},
		{"lmn_copter1_death.png", "copter1d.png"},
		{"lmn_copter1w.png", "copter1.png"},
		
		{"lmn_copter2.png", "copter2.png"},
		{"lmn_copter2a.png", "copter2a.png"},
		{"lmn_copter2_emerge.png", "copter2.png"},
		{"lmn_copter2_death.png", "copter2d.png"},
		{"lmn_copter2w.png", "copter2.png"},
	}
	
	utils.appendAssets{
		writePath = "img/effects/emitters/",
		readPath = path .."img/effects/emitters/",
		{"lmn_petal_copter1.png", "petal_copter1.png"},
		{"lmn_petal_copter2.png", "petal_copter2.png"},
	}
	
	utils.appendAssets{
		writePath = "img/",
		readPath = path .."img/",
		{"portraits/enemy/lmn_Copter1.png", "portraits/copter1.png"},
		{"portraits/enemy/lmn_Copter2.png", "portraits/copter2.png"},
	}
	
	local a = ANIMS
	local base = a.BaseUnit:new{Image = imagePath .."lmn_copter1.png", PosX = -15, PosY = -15}
	local alpha = a.BaseUnit:new{Image = imagePath .."lmn_copter2.png", PosX = -15, PosY = -15}
	local baseEmerge = base:new{Image = imagePath .."lmn_copter1_emerge.png", Loop = false}
	local alphaEmerge = alpha:new{Image = imagePath .."lmn_copter2_emerge.png", Loop = false}
	
	a.lmn_Copter1 = base
	a.lmn_Copter1a = base:new{Image = imagePath .."lmn_copter1a.png", NumFrames = 4}
	a.lmn_Copter1e = baseEmerge
	a.lmn_Copter1d = base:new{Image = imagePath .."lmn_copter1_death.png", NumFrames = 10, Time = .14, Loop = false}
	a.lmn_Copter1w = base:new{Image = imagePath .."lmn_copter1w.png"}
	
	a.lmn_Copter2 = alpha
	a.lmn_Copter2a = alpha:new{Image = imagePath .."lmn_copter2a.png", NumFrames = 4}
	a.lmn_Copter2e = alphaEmerge
	a.lmn_Copter2d = alpha:new{Image = imagePath .."lmn_copter2_death.png", NumFrames = 10, Time = .14, Loop = false}
	a.lmn_Copter2w = alpha:new{Image = imagePath .."lmn_copter2w.png"}
	
	lmn_Copter1 = Pawn:new{
		Name = "Copter",
		Health = 1,
		MoveSpeed = 3,
		Minor = true,
		Image = "lmn_Copter1",
		lmn_PetalsOnDeath = "lmn_Emitter_Copter1d",
		SkillList = { "lmn_CopterAtk1" },
		SoundLocation = "/enemy/hornet_1/",
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_FLESH,
		Flying = true,
		Portrait = "enemy/lmn_Copter1",
	}
	
	lmn_Copter2 = lmn_Copter1:new{
		Name = "Alpha Copter",
		Health = 1,
		Image = "lmn_Copter2",
		lmn_PetalsOnDeath = "lmn_Emitter_Copter2d",
		SkillList = { "lmn_CopterAtk2" },
		SoundLocation = "/enemy/hornet_2/",
		Portrait = "enemy/lmn_Copter2",
		Tier = TIER_ALPHA,
	}
	
	lmn_CopterAtk1 = Skill:new{
		Name = "Stinger",
		Description = "Stab the target.",
		Icon = "weapons/enemy_hornet1.png",
		Class = "Enemy",
		Damage = 1,
		PathSize = 1,
		TipImage = {
			Unit = Point(2,2),
			Enemy = Point(2,1),
			Target = Point(2,1),
			CustomPawn = "lmn_Copter1"
		}
	}
	
	lmn_CopterAtk2 = lmn_CopterAtk1:new{
		Name = "Stinger",
		Description = "Stab the target.",
		Icon = "weapons/enemy_hornet2.png",
		Damage = 2,
		TipImage = {
			Unit = Point(2,2),
			Enemy = Point(2,1),
			Target = Point(2,1),
			CustomPawn = "lmn_Copter2"
		}
	}
	
	function lmn_CopterAtk1:GetSkillEffect(p1, p2)
		local ret = SkillEffect()
		local direction = GetDirection(p2 - p1)
		
		local damage = SpaceDamage(p2,self.Damage)
		damage.sAnimation = "explohornet_"..direction
		
		ret:AddQueuedMelee(p1,damage, 0.25)
		
		return ret
	end
	
	lmn_Emitter_Copter1d = Emitter:new{
		image = "effects/emitters/lmn_petal_copter1.png",
		image_count = 1,
		max_alpha = 1.0,
		min_alpha = 0.0,
		rot_speed = 5347,
		x = -1, y = -2, variance_x = 0, variance_y = 0,
		angle = 20, angle_variance = 220,
		timer = 0,
		burst_count = 1, speed = 1.00, lifespan = 2.0, birth_rate = 0,
		max_particles = 16,
		gravity = false,
		layer = LAYER_FRONT
	}
	
	lmn_Emitter_Copter2d = lmn_Emitter_Copter1d:new{ image = "effects/emitters/lmn_petal_copter2.png" }
end

function this:load(mod, options, version)
end

return this