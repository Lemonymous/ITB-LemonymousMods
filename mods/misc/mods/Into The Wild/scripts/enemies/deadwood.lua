
local path = mod_loader.mods[modApi.currentMod].resourcePath
local utils = require(path .."scripts/utils")
local pushArrows = require(path .."scripts/pushArrows")
local this = {}

function this:init(mod)
	WeakPawns.lmn_Deadwood = false
	Spawner.max_pawns.lmn_Deadwood = 2
	
	local writePath = "img/units/aliens/"
	local readPath = path .. "img/units/aliens/"
	local imagePath = writePath:sub(5,-1)
	utils.appendAssets{
		writePath = writePath,
		readPath = readPath,
		{"lmn_deadWood1.png", "deadWood1.png"},
		{"lmn_deadWood1a.png", "deadWood1.png"},
		{"lmn_deadWood1_emerge.png", "deadWood1.png"},
		{"lmn_deadWood1_death.png", "deadWood1.png"},
		{"lmn_deadWood1w.png", "deadWood1.png"},
		
		{"lmn_deadWood2.png", "deadWood2.png"},
		{"lmn_deadWood2a.png", "deadWood2.png"},
		{"lmn_deadWood2_emerge.png", "deadWood2.png"},
		{"lmn_deadWood2_death.png", "deadWood2.png"},
		{"lmn_deadWood2w.png", "deadWood2.png"},
	}
	
	local a = ANIMS
	local base = a.BaseUnit:new{Image = imagePath .."lmn_deadWood1.png", PosX = -25, PosY = -22}
	local alpha = a.BaseUnit:new{Image = imagePath .."lmn_deadWood2.png", PosX = -25, PosY = -22}
	local baseEmerge = a.BaseEmerge:new{Image = imagePath .."lmn_deadWood1_emerge.png", PosX = -25, PosY = -22, Height = 1, NumFrames = 1}
	local alphaEmerge = a.BaseEmerge:new{Image = imagePath .."lmn_deadWood2_emerge.png", PosX = -25, PosY = -22, Height = 1, NumFrames = 1}
	
	a.lmn_Deadwood1 = base
	a.lmn_Deadwood1a = base:new{Image = imagePath .."lmn_deadWood1a.png", NumFrames = 1}
	a.lmn_Deadwood1e = baseEmerge
	a.lmn_Deadwood1d = base:new{Image = imagePath .."lmn_deadWood1_death.png", Loop = false}
	a.lmn_Deadwood1w = base:new{Image = imagePath .."lmn_deadWood1w.png"}
	
	a.lmn_Deadwood2 = alpha
	a.lmn_Deadwood2a = alpha:new{Image = imagePath .."lmn_deadWood2a.png", NumFrames = 1}
	a.lmn_Deadwood2e = alphaEmerge
	a.lmn_Deadwood2d = alpha:new{Image = imagePath .."lmn_deadWood2_death.png", Loop = false}
	a.lmn_Deadwood2w = alpha:new{Image = imagePath .."lmn_deadWood2w.png"}
	
	lmn_Deadwood1 = Pawn:new{
		Name = "Sentree",
		Health = 4,
		MoveSpeed = 2,
		Image = "lmn_Deadwood1",
		SkillList = { "lmn_DeadwoodAtk1" },
		SoundLocation = "/enemy/digger_1/", -- TODO: find correct soundbase
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_ROCK,
		IsPortrait = false,
		--Portrait = "enemy/lmn_Deadwood1", -- TODO: add portrait
	}
	
	lmn_Deadwood2 = lmn_Deadwood1:new{
		Name = "Alpha Sentree",
		Health = 5,
		MoveSpeed = 2,
		Image = "lmn_Deadwood2",
		SkillList = { "lmn_DeadwoodAtk2" },
		SoundLocation = "/enemy/digger_2/", -- TODO: find correct soundbase
		--Portrait = "enemy/lmn_Deadwood2", -- TODO: add portrait
		Tier = TIER_ALPHA,
	}
	
	lmn_DeadwoodAtk1 = Skill:new{
		Name = "Smash",
		Description = "Smash the ground and push adjacent tiles.", -- TODO: messy and boring.
		Class = "Enemy",
		PathSize = 1,
		Range = 1,
		Damage = 2,
		Anim_Impact = "explosmash_",
		Sound_Impact = "/weapons/mercury_fist",
		TipImage = {
			Unit = Point(2,3),
			Enemy1 = Point(2,2),
			Enemy2 = Point(3,2),
			Target = Point(2,2),
			CustomPawn = "lmn_Deadwood1"
		}
	}
	
	local isTargetScore
	function lmn_DeadwoodAtk1:GetTargetScore(p1, p2)
		isTargetScore = true
		local ret = Skill.GetTargetScore(self, p1, p2)
		isTargetScore = nil
		
		return ret
	end
	
	function lmn_DeadwoodAtk1:GetSkillEffect(p1, p2)
		local ret = SkillEffect()
		local dir = GetDirection(p2 - p1)
		
		local d = SpaceDamage(p2)
		d.sAnimation = self.Anim_Impact .. dir
		d.sSound = self.Sound_Impact
		
		ret:AddQueuedDamage(d)
		
		ret:AddQueuedDelay(0.1)
		ret:AddQueuedBounce(p2, 3)
		ret:AddQueuedDelay(0.2)
		
		ret:AddQueuedDamage(SpaceDamage(p2, self.Damage))
		
		if not isTargetScore then
			for i = DIR_START, DIR_END do
				local curr = p2 + DIR_VECTORS[i]
				if curr ~= p1 and Board:IsValid(p2) then
					local d = SpaceDamage(curr, 0, i)
					if utils.IsPushable(curr) then
						local curr2 = p2 + DIR_VECTORS[i] * 2
						if Board:IsValid(curr2) and Board:IsBlocked(curr2, PATH_PROJECTILE) then
							d.sImageMark = pushArrows.Hit(i, curr)
						else
							d.sImageMark = pushArrows.Push(i, curr)
						end
					end
					ret:AddQueuedDamage(d)
				end
			end
		end
		
		return ret
	end
	
	lmn_DeadwoodAtk2 = lmn_DeadwoodAtk1:new{
		Damage = 4,
		Anim_Impact = "explosmash_",
		Sound_Impact = "/weapons/mercury_fist",
		TipImage = {
			Unit = Point(2,3),
			Enemy1 = Point(2,2),
			Enemy2 = Point(3,2),
			Target = Point(2,2),
			CustomPawn = "lmn_Deadwood2"
		}
	}
end

function this:load(mod, options, version)

end

return this