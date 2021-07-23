
local path = mod_loader.mods[modApi.currentMod].resourcePath
local utils = require(path .."scripts/utils")
local this = {}

function this:init(mod)
	WeakPawns.lmn_Shambler = false
	Spawner.max_pawns.lmn_Shambler = 1
	Spawner.max_level.lmn_Shambler = 1
	
	local writePath = "img/units/aliens/"
	local readPath = path .. "img/units/aliens/"
	local imagePath = writePath:sub(5,-1)
	utils.appendAssets{
		writePath = writePath,
		readPath = readPath,
		{"lmn_shambler1.png", "shambler1.png"},
		{"lmn_shambler1a.png", "shambler1a.png"},
		{"lmn_shambler1_emerge.png", "shambler1e.png"},
		{"lmn_shambler1_death.png", "shambler1.png"},
		{"lmn_shambler1w.png", "shambler1.png"},
	}
	
	local a = ANIMS
	local base = a.BaseUnit:new{Image = imagePath .."lmn_shambler1.png", PosX = -15, PosY = -21}
	local baseEmerge = a.BaseEmerge:new{Image = imagePath .."lmn_shambler1_emerge.png", PosX = -23, PosY = -20, Height = 1}
	
	a.lmn_Shambler1 = base
	a.lmn_Shambler1a = base:new{Image = imagePath .."lmn_shambler1a.png", NumFrames = 6}
	a.lmn_Shambler1e = baseEmerge
	a.lmn_Shambler1d = base:new{Image = imagePath .."lmn_shambler1_death.png", Loop = false}
	a.lmn_Shambler1w = base:new{Image = imagePath .."lmn_shambler1w.png"}
	
	lmn_Shambler1 = Pawn:new{
		Name = "Shambler",
		Health = 5,
		MoveSpeed = 2,
		Image = "lmn_Shambler1",
		SkillList = { "lmn_ShamblerAtk1" },
		SoundLocation = "/enemy/digger_1/", -- TODO: find correct soundbase
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_FLESH,
		IsPortrait = false,
		--Portrait = "enemy/lmn_Shambler1", -- TODO: add portrait
	}
	
	lmn_ShamblerAtk1 = Skill:new{
		Name = "Headbutt",
		Description = "Headbutt a target.",
		Class = "Enemy",
		PathSize = 1,
		Damage = 2,
		Anim_Impact = "SwipeClaw1",
		Sound_Impact = "/enemy/scorpion_soldier_1/attack",
		TipImage = {
			Unit = Point(2,3),
			Enemy = Point(2,2),
			Target = Point(2,2),
			CustomPawn = "lmn_Shambler1"
		}
	}
	
	function lmn_ShamblerAtk1:GetSkillEffect(p1, p2) -- TODO
		local ret = SkillEffect()
		
		local d = SpaceDamage(p2, self.Damage)
		d.sAnimation = self.Anim_Impact
		d.sSound = self.Sound_Impact
		ret:AddQueuedMelee(p1, d)
		
		return ret
	end
end

function this:load(mod, options, version)
end

return this