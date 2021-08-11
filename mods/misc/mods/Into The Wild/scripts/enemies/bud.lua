
local path = mod_loader.mods[modApi.currentMod].resourcePath
local utils = require(path .."scripts/utils")
local worldConstants = LApi.library:fetch("worldConstants")
local teamTurn = require(path .."scripts/teamTurn")
local this = {}

function this:init(mod)
	WeakPawns.lmn_Bud = false
	Spawner.max_pawns.lmn_Bud = 2
	
	local writePath = "img/units/aliens/"
	local readPath = path .. "img/units/aliens/"
	local imagePath = writePath:sub(5,-1)
	utils.appendAssets{
		writePath = writePath,
		readPath = readPath,
		{"lmn_bud1.png", "bud1.png"},
		{"lmn_bud1a.png", "bud1a.png"},
		{"lmn_bud1_emerge.png", "bud1e.png"},
		{"lmn_bud1_death.png", "bud1d.png"},
		{"lmn_bud1w.png", "bud1.png"},
		
		{"lmn_bud2.png", "bud2.png"},
		{"lmn_bud2a.png", "bud2a.png"},
		{"lmn_bud2_emerge.png", "bud2e.png"},
		{"lmn_bud2_death.png", "bud2d.png"},
		{"lmn_bud2w.png", "bud2.png"},
	}
	
	utils.appendAssets{
		writePath = "img/",
		readPath = path .."img/",
		{"portraits/enemy/lmn_Bud1.png", "portraits/bud1.png"},
		{"portraits/enemy/lmn_Bud2.png", "portraits/bud2.png"},
		{"effects/shotup_lmn_copter1.png", "effects/copter_shotup1.png"},
		{"effects/shotup_lmn_copter2.png", "effects/copter_shotup2.png"},
		{"weapons/lmn_BudAtk1.png", "weapons/budAtk1.png"},
		{"weapons/lmn_BudAtk2.png", "weapons/budAtk2.png"},
	}
	
	local a = ANIMS
	local base = a.BaseUnit:new{Image = imagePath .."lmn_bud1.png", PosX = -18, PosY = -5}
	local alpha = a.BaseUnit:new{Image = imagePath .."lmn_bud2.png", PosX = -18, PosY = -11}
	local baseEmerge = a.BaseEmerge:new{Image = imagePath .."lmn_bud1_emerge.png", PosX = -23, PosY = -4, Height = 1}
	local alphaEmerge = a.BaseEmerge:new{Image = imagePath .."lmn_bud2_emerge.png", PosX = -23, PosY = -11, Height = 1}
	
	a.lmn_Bud1 = base
	a.lmn_Bud1a = base:new{Image = imagePath .."lmn_bud1a.png", NumFrames = 4}
	a.lmn_Bud1e = baseEmerge
	a.lmn_Bud1d = base:new{Image = imagePath .."lmn_bud1_death.png", PosX = -19, Loop = false, NumFrames = 10, Time = .14}
	a.lmn_Bud1w = base:new{Image = imagePath .."lmn_bud1w.png"}
	
	a.lmn_Bud2 = alpha
	a.lmn_Bud2a = alpha:new{Image = imagePath .."lmn_bud2a.png", NumFrames = 4}
	a.lmn_Bud2e = alphaEmerge
	a.lmn_Bud2d = alpha:new{Image = imagePath .."lmn_bud2_death.png", PosX = -19, Loop = false, NumFrames = 10, Time = .14}
	a.lmn_Bud2w = alpha:new{Image = imagePath .."lmn_bud2w.png"}
	
	lmn_Bud1 = Pawn:new{
		Name = "Bud",
		Health = 3,
		MoveSpeed = 0,
		Image = "lmn_Bud1",
		lmn_PetalsOnDeath = "lmn_Emitter_Bud1d",
		SkillList = { "lmn_BudAtk1" },
		SoundLocation = "/enemy/jelly/",
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_FLESH,
		Ranged = 1,
		IgnoreSmoke = true,
		Pushable = false,
		Portrait = "enemy/lmn_Bud1",
	}
	AddPawnName("lmn_Bud1")
	
	lmn_Bud2 = lmn_Bud1:new{
		Name = "Alpha Bud",
		Health = 5,
		Image = "lmn_Bud2",
		lmn_PetalsOnDeath = "lmn_Emitter_Bud2d",
		SkillList = { "lmn_BudAtk2" },
		SoundLocation = "/enemy/jelly/",
		Portrait = "enemy/lmn_Bud2",
		Tier = TIER_ALPHA,
	}
	AddPawnName("lmn_Bud2")
	
	lmn_BudAtk1 = Skill:new{
		Name = "Chucker",
		Description = "Lose 1 health and chuck a Copter onto the board.",
		Class = "Enemy",
		Icon = "weapons/lmn_BudAtk1.png",
		SelfDamage = 1,
		PathSize = 4,
		ScoreNothing = 5,
		ScoreEnemy = 0,
		ScoreBuilding = 0,
		MyPawn = "lmn_Copter1",
		LaunchSound = "",
		Projectile = "effects/shotup_lmn_copter1.png",
		CustomTipImage = "lmn_BudAtk1_Tip",
		Explosion = "",
		TipImage = {
			Unit = Point(3,3),
			Building = Point(1,1),
			Target = Point(3,1),
			Second_Origin = Point(2,1),
			Second_Target = Point(1,1),
			CustomPawn = "lmn_Bud1"
		}
	}
	
	-- area artillery
	function lmn_BudAtk1:GetTargetArea(p)
		local list = Board:GetReachable(p, self.PathSize, PATH_FLYER)
		
		local ret = PointList()
		for _, loc in ipairs(extract_table(list)) do
			-- sometimes 0 movement units don't wait for the previous pawn
			-- to finish it's attack. Need to check if the location is targeted,
			-- to avoid several copters aimed at the same tile.
			if not Board:IsTargeted(loc) then
				ret:push_back(loc)
			end
		end
		
		return ret
	end
	
	lmn_BudAtk2 = lmn_BudAtk1:new{
		Icon = "weapons/lmn_BudAtk2.png",
		Description = "Lose 1 health and chuck an Alpha Copter onto the board.",
		MyPawn = "lmn_Copter2",
		Projectile = "effects/shotup_lmn_copter2.png",
		CustomTipImage = "lmn_BudAtk2_Tip",
		TipImage = {
			Unit = Point(3,3),
			Building = Point(1,1),
			Target = Point(1,3),
			Second_Origin = Point(2,1),
			Second_Target = Point(1,1),
			CustomPawn = "lmn_Bud2"
		}
	}
	
	function lmn_BudAtk1:GetSkillEffect(p1, p2)
		local ret = SkillEffect()
		
		local seed = SpaceDamage(p2)
		seed.sPawn = self.MyPawn
		ret:AddDamage(SpaceDamage(p1, self.SelfDamage))
		ret:AddSound("enemy/hornet_1/move")
		
		worldConstants:setHeight(ret, 20)
		ret:AddArtillery(p1, seed, self.Projectile, NO_DELAY)
		worldConstants:resetHeight(ret)
		
		-- seriously dumb hack to prevent several copters aimed at the same tile.
		-- units with move speed 0 doesn't always seem to be willing to wait for the
		-- previous unit to finish it's attack before starting it's own.
		-- we're marking a our target as targeted to prevent others to use the same tile.
		local dummy = SpaceDamage(p2, 1)
		dummy.bHide = true
		ret:AddQueuedArtillery(dummy, "", NO_DELAY)
		
		-- clear queued target shortly thereafter.
		ret:AddDelay(0.1)
		ret:AddScript(string.format("Board:GetPawn(%s):ClearQueued()", p1:GetString()))
		
		return ret
	end
	
	lmn_BudAtk1_Tip = lmn_BudAtk1:new{}
	lmn_BudAtk2_Tip = lmn_BudAtk2:new{}
	
	function lmn_BudAtk1_Tip.GetSkillEffect(self, p1, p2, ...)
		local ret = lmn_BudAtk1.GetSkillEffect(self, p1, p2, ...)
		
		local copter = {
			p1 = self.TipImage.Target,
			p2 = self.TipImage.Second_Origin
		}
		
		ret:AddQueuedScript(string.format("Board:GetPawn(%s):Move(%s)", copter.p1:GetString(), copter.p2:GetString()))		
		return ret
	end
	
	lmn_BudAtk2_Tip.GetSkillEffect = lmn_BudAtk1_Tip.GetSkillEffect
	
	modApi:appendAsset("img/effects/emitters/lmn_petal_bud1.png", path .."img/effects/emitters/petal_bud1.png")
	modApi:appendAsset("img/effects/emitters/lmn_petal_bud2.png", path .."img/effects/emitters/petal_bud2.png")
	modApi:appendAsset("img/effects/emitters/lmn_petal_budB.png", path .."img/effects/emitters/petal_budB.png")
	lmn_Emitter_Bud1d = Emitter:new{
		image = "effects/emitters/lmn_petal_bud1.png",
		image_count = 1,
		max_alpha = 1.0,
		min_alpha = 0.0,
		rot_speed = 100,
		x = 5, y = 10, variance_x = 20, variance_y = 15,
		angle = 20, angle_variance = 220,
		timer = 0.1,
		burst_count = 10, speed = 1.50, lifespan = 1.0, birth_rate = 0.1,
		max_particles = 16,
		gravity = true,
		layer = LAYER_BACK
	}
	
	lmn_Emitter_Bud2d = lmn_Emitter_Bud1d:new{image = "effects/emitters/lmn_petal_bud2.png"}
	lmn_Emitter_BudBd = lmn_Emitter_Bud1d:new{image = "effects/emitters/lmn_petal_budB.png"}
end

function this:load(mod, options, version)
	
end

return this