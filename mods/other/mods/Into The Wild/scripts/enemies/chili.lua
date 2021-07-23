
local path = mod_loader.mods[modApi.currentMod].resourcePath
local utils = require(path .."scripts/utils")
local achvApi = require(path .."scripts/achievements/api")

local this = {
	plant_leaders = {
		"lmn_ChiliBoss",
		"lmn_ChomperBoss",
		"lmn_SunflowerBoss",
		"lmn_SpringseedBoss",
		"lmn_SequoiaBoss"
	}
}

function this:init(mod)
	WeakPawns.lmn_Chili = false
	Spawner.max_pawns.lmn_Chili = 2
	
	local writePath = "img/units/aliens/"
	local readPath = path .. "img/units/aliens/"
	local imagePath = writePath:sub(5,-1)
	utils.appendAssets{
		writePath = writePath,
		readPath = readPath,
		{"lmn_chili1.png", "chili1.png"},
		{"lmn_chili1a.png", "chili1a.png"},
		{"lmn_chili1_emerge.png", "chili1e.png"},
		{"lmn_chili1_death.png", "chili1d.png"},
		{"lmn_chili1w.png", "chili1.png"},
		
		{"lmn_chili2.png", "chili2.png"},
		{"lmn_chili2a.png", "chili2a.png"},
		{"lmn_chili2_emerge.png", "chili2e.png"},
		{"lmn_chili2_death.png", "chili2d.png"},
		{"lmn_chili2w.png", "chili2.png"},
	}
	
	utils.appendAssets{
		writePath = "img/",
		readPath = path .."img/",
		{"portraits/enemy/lmn_Chili1.png", "portraits/chili1.png"},
		{"portraits/enemy/lmn_Chili2.png", "portraits/chili2.png"},
		{"portraits/enemy/lmn_ChiliBoss.png", "portraits/chiliB.png"},
		{"portraits/pilots/Pilot_lmn_Chili.png", "portraits/chili.png"},
		{"weapons/lmn_ChiliAtk1.png", "weapons/chiliAtk1.png"},
		{"weapons/lmn_ChiliAtk2.png", "weapons/chiliAtk2.png"},
		{"weapons/lmn_ChiliAtkB.png", "weapons/chiliAtkB.png"},
	}
	
	local a = ANIMS
	local base = a.BaseUnit:new{Image = imagePath .."lmn_chili1.png", PosX = -12, PosY = 0}
	local alpha = a.BaseUnit:new{Image = imagePath .."lmn_chili2.png", PosX = -12, PosY = 2}
	local baseEmerge = a.BaseEmerge:new{Image = imagePath .."lmn_chili1_emerge.png", PosX = -23, PosY = 0, Height = 1}
	local alphaEmerge = a.BaseEmerge:new{Image = imagePath .."lmn_chili2_emerge.png", PosX = -23, PosY = 0, Height = 1}
	
	a.lmn_Chili1 = base
	a.lmn_Chili1a = base:new{Image = imagePath .."lmn_chili1a.png", NumFrames = 4}
	a.lmn_Chili1e = baseEmerge
	a.lmn_Chili1d = base:new{Image = imagePath .."lmn_chili1_death.png", PosX = -23, PosY = -10, Loop = false, NumFrames = 10, Time = .14}
	a.lmn_Chili1w = base:new{Image = imagePath .."lmn_chili1w.png"}
	
	a.lmn_Chili2 = alpha
	a.lmn_Chili2a = alpha:new{Image = imagePath .."lmn_chili2a.png", NumFrames = 4}
	a.lmn_Chili2e = alphaEmerge
	a.lmn_Chili2d = alpha:new{Image = imagePath .."lmn_chili2_death.png", PosX = -23, PosY = -11, Loop = false, NumFrames = 10, Time = .14}
	a.lmn_Chili2w = alpha:new{Image = imagePath .."lmn_chili2w.png"}
	
	utils.appendAssets{
		writePath = "img/units/player/",
		readPath = path .."img/units/aliens/",
		
		{"lmn_chili.png", "chili.png"},
		{"lmn_chili_a.png", "chilia.png"},
		{"lmn_chili_broken.png", "chilid.png"},
		{"lmn_chili_w.png", "chiliw.png"},
		{"lmn_chili_w_broken.png", "chiliwd.png"},
		{"lmn_chili_ns.png", "chilins.png"},
		{"lmn_chili_h.png", "chilih.png"},
	}
	
	local imagePath = "units/player/"
	local base = a.MechUnit:new{Image = imagePath .."lmn_chili.png", PosX = -12, PosY = 0}
	
	a.lmn_Chili = base
	a.lmn_Chilia = base:new{Image = imagePath .."lmn_chili_a.png", NumFrames = 4}
	a.lmn_Chili_broken = base:new{Image = imagePath .."lmn_chili_broken.png", PosX = -27}
	a.lmn_Chiliw = base:new{Image = imagePath .."lmn_chili_w.png", PosY = 8}
	a.lmn_Chiliw_broken = base:new{Image = imagePath .."lmn_chili_w_broken.png", PosX = -27, PosY = 8}
	a.lmn_Chili_ns = a.MechIcon:new{Image = imagePath .."lmn_chili_ns.png"}
	
	CreatePilot{
		Id = "Pilot_lmn_Chili",
		Personality = "Vek",
		Sex = SEX_VEK,
		Skill = "Survive_Death",
		Rarity = 0,
	}
	
	lmn_Chili1 = Pawn:new{
		Name = "Chili",
		Health = 3,
		MoveSpeed = 4,
		Ranged = 1,
		Image = "lmn_Chili1",
		SkillList = { "lmn_ChiliAtk1" },
		SoundLocation = "/enemy/centipede_1/",
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_FLESH,
		IgnoreFire = true,
		Portrait = "enemy/lmn_Chili1",
	}
	
	lmn_Chili2 = lmn_Chili1:new{
		Name = "Alpha Chili",
		Health = 5,
		Image = "lmn_Chili2",
		SkillList = { "lmn_ChiliAtk2" },
		SoundLocation = "/enemy/centipede_2/",
		Portrait = "enemy/lmn_Chili2",
		Tier = TIER_ALPHA,
	}
	
	lmn_ChiliAtk1 = Skill:new{
		Name = "Chili Breath",
		Icon = "weapons/lmn_ChiliAtk1.png",
		Description = "Light two tiles on fire, and damage the first target hit.",
		Class = "Enemy",
		Projectile = false,
		PathSize = 1,
		Damage = 1,
		ScoreEnemy = 5,
		ScoreBuilding = 5,
		ExtraRange = 1,
		LaunchSound = "",
		--Anim_Impact = "lmn_ExploChili",
		Art_Projectile = "effects/shot_mechtank", -- TODO: firey projectile
		Sound_Launch = "/enemy/firefly_soldier_1/attack", -- TODO
		Sound_Impact = "/impact/dynamic/enemy_projectile", -- TODO
		--CustomTipImage = "lmn_ChiliAtk1_Tip",
		TipImage = {
			Unit = Point(2,3),
			Enemy1 = Point(2,2),
			Enemy2 = Point(2,1),
			Target = Point(2,2),
			CustomPawn = "lmn_Chili1"
		}
	}
	
	lmn_ChiliAtk2 = lmn_ChiliAtk1:new{
		Damage = 3,
		Icon = "weapons/lmn_ChiliAtk2.png",
		--Anim_Impact = "lmn_ExploChili",
		Art_Projectile = "effects/shot_mechtank", -- TODO: firey projectile
		--CustomTipImage = "lmn_ChiliAtk2_Tip",
		TipImage = {
			Unit = Point(2,3),
			Enemy1 = Point(2,2),
			Enemy2 = Point(2,1),
			Target = Point(2,2),
			CustomPawn = "lmn_Chili2"
		}
	}
	
	function lmn_ChiliAtk1:GetTargetArea(p, ...)
		local ret = Skill.GetTargetArea(self, p, ...)
		
		if self.Destruct then
			ret:push_back(p)
		end
		
		return ret
	end
	
	local isTargetScore
	function lmn_ChiliAtk1:GetTargetScore(p1, p2, ...)
		isTargetScore = true
		local ret = Skill.GetTargetScore(self, p1, p2, ...)
		isTargetScore = nil
		--LOG(Board:GetPawn(p1):GetId() .." considers attacking ".. p1:GetString() .." > ".. p2:GetString() .." with score ".. ret)
		
		return ret
	end
	
	function lmn_ChiliAtk1:Achievement(p2)
		local pawn = Board:GetPawn(p2)
		if pawn and not pawn:IsFire() and list_contains(this.plant_leaders, pawn:GetType()) then
			achvApi:TriggerChievo("chili")
		end
	end
	
	function lmn_ChiliAtk1:GetSkillEffect(p1, p2)
		local ret = SkillEffect()
		
		if p1 == p2 then
			if self.Destruct then
				local d = SpaceDamage(p2, DAMAGE_DEATH)
				d.sAnimation = "explo_fire1"
				d.iFire = 1
				ret:AddQueuedBounce(p2, 3)
				ret:AddQueuedDamage(d)
				
				for i = DIR_START, DIR_END do
					local curr = p2 + DIR_VECTORS[i]
					
					local d = SpaceDamage(curr, DAMAGE_DEATH)
					d.sSound = "/impact/generic/explosion"
					d.sAnimation = "exploout2_".. i
					d.iFire = 1
					ret:AddQueuedDamage(d)
					ret:AddQueuedBounce(curr, 2)
				end
			end
			
			return ret
		end
		
		local dir = GetDirection(p2 - p1)
		local adjacent = p1 + DIR_VECTORS[dir]
		local target
		local doneDamage
		local fireEnd
		
		if self.Projectile then
			target = GetProjectileEnd(p1, adjacent)
		else
			target = adjacent
		end
		
		if self.Projectile then
			local d = SpaceDamage(target)
			d.sSound = self.Sound_Impact
			
			ret:AddQueuedSound(self.Sound_Launch)
			ret:AddQueuedProjectile(d, self.Art_Projectile)
		end
		
		-- find last tile we can burn.
		for k = 0, self.ExtraRange do
			fireEnd = target + DIR_VECTORS[dir] * k
			
			local terrain = Board:GetTerrain(fireEnd)
			
			if terrain == TERRAIN_MOUNTAIN or terrain == TERRAIN_BUILDING then
				break
			end
			
			if not Board:IsValid(fireEnd + DIR_VECTORS[dir]) then
				break
			end
		end
		
		local distance = target:Manhattan(fireEnd)
		local damage = SpaceDamage()
		damage.iFire = 1
		
		ret:AddQueuedSound("/weapons/flamethrower")
		
		for k = 0, distance do
			damage.loc = target + DIR_VECTORS[dir] * k
			
			if doneDamage then
				damage.iDamage = 0
				damage.iPush = DIR_NONE
			elseif Board:IsBlocked(damage.loc, PATH_PROJECTILE) then
				doneDamage = true
				damage.iDamage = self.Damage
				damage.iPush = self.Push == 1 and dir or DIR_NONE
			end
			
			if k == distance then
				damage.sAnimation = "flamethrower".. (distance + 1) .."_".. dir
			end
			
			if not isTargetScore then
				-- actual damage.
				ret:AddQueuedScript(string.format("lmn_ChiliAtk1:Achievement(%s)", damage.loc:GetString()))
				ret:AddQueuedDamage(damage)
			elseif damage.iDamage > 0 then
				-- only score tiles we damage.
				ret:AddQueuedDamage(damage)
			end
			
			if k < distance then
				ret:AddQueuedDelay(0.1)
			end
		end
		
		return ret
	end
	
	lmn_Chili = Pawn:new{
		Name = "Techno-Chili",
		Class = "TechnoVek",
		Health = 3,
		MoveSpeed = 4,
		Image = "lmn_Chili",
		ImageOffset = 8,
		SkillList = { "lmn_ChiliAtk" },
		SoundLocation = "/enemy/firefly_soldier_1/",
		DefaultTeam = TEAM_PLAYER,
		ImpactMaterial = IMPACT_FLESH,
		Massive = true,
		IgnoreFire = true,
	}
	
	lmn_ChiliAtk = Skill:new{
		Name = "Chili Breath",
		Icon = "weapons/lmn_ChiliAtk1.png",
		Description = "Breathe fire on two tiles, pushing the first target hit.",
		Class = "TechnoVek",
		Damage = 0,
		ExtraRange = 1,
		Push = 1,
		LaunchSound = "",
		Sound_Launch = "/enemy/firefly_soldier_1/attack", -- TODO
		Sound_Impact = "/impact/dynamic/enemy_projectile", -- TODO
		PowerCost = 1,
		Upgrades = 2,
		UpgradeCost = {1, 1},
		UpgradeList = { "Range", "Self-Destruct" },
		TipImage = {
			Unit = Point(2,3),
			Enemy1 = Point(2,2),
			Target = Point(2,2),
			CustomPawn = "lmn_Chili"
		}
	}
	
	function lmn_ChiliAtk:GetTargetArea(p)
		local ret = PointList()
		
		for i = DIR_START, DIR_END do
			local step = DIR_VECTORS[i]
			
			for k = 1, (1 + self.ExtraRange) do
				local curr = p + step * k
				
				if not Board:IsValid(curr) then
					break
				end
				
				ret:push_back(curr)
				
				local terrain = Board:GetTerrain(curr)
				if terrain == TERRAIN_BUILDING or terrain == TERRAIN_MOUNTAIN then
					break
				end
			end
		end
		
		if self.Destruct then
			ret:push_back(p)
		end
		
		return ret
	end
	
	function lmn_ChiliAtk:GetSkillEffect(p1, p2)
		local ret = lmn_ChiliAtk1.GetSkillEffect(self, p1, p2, lmn_ChiliAtk1)
		ret.effect = ret.q_effect
		ret.q_effect = SkillEffect().q_effect
		
		return ret
	end
	
	lmn_ChiliAtk_A = lmn_ChiliAtk:new{
		UpgradeDescription = "Increases range by 1.",
		ExtraRange = 2,
	}
	
	lmn_ChiliAtk_B = lmn_ChiliAtk:new{
		UpgradeDescription = "Allows Mech to explode in a fiery spectacle, killing itself and anything adjacent to Mech.",
		Destruct = true,
		TipImage = {
			Unit = Point(2,2),
			Target = Point(2,2),
			Enemy = Point(2,1),
			Enemy2 = Point(1,2),
			Enemy3 = Point(3,2),
			CustomPawn = "lmn_Chili"
		}
	}
	
	lmn_ChiliAtk_AB = lmn_ChiliAtk:new{
		ExtraRange = 2,
		Destruct = true,
		TipImage = {
			Unit = Point(2,3),
			Target = Point(2,2),
			Enemy = Point(2,2),
			Enemy2 = Point(1,3),
			Enemy3 = Point(3,3),
			Second_Origin = Point(2,3),
			Second_Target = Point(2,3),
			CustomPawn = "lmn_Chili"
		}
	}
end

function this:load(mod, options, version)
end

return this