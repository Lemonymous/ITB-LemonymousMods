
local path = mod_loader.mods[modApi.currentMod].resourcePath
local utils = require(path .."scripts/utils")
local trait = LApi.library:fetch("trait")
local achvApi = require(path .."scripts/achievements/api")
local getModUtils = require(path .."scripts/getModUtils")
local tutorialTips = LApi.library:fetch("tutorialTips")
local this = {
	sprouts = {"lmn_Sprout1", "lmn_Sprout2", "lmn_SproutEv", "lmn_SproutBud1", "lmn_SproutBud2"}
}

function this:init(mod)
	WeakPawns.lmn_Sprout = true
	Spawner.max_pawns.lmn_Sprout = 3
	
	local writePath = "img/units/aliens/"
	local readPath = path .. "img/units/aliens/"
	local imagePath = writePath:sub(5,-1)
	utils.appendAssets{
		writePath = writePath,
		readPath = readPath,
		{"lmn_sprout1.png", "sprout1.png"},
		{"lmn_sprout1a.png", "sprout1a.png"},
		{"lmn_sprout1_emerge.png", "sprout1e.png"},
		{"lmn_sprout1_death.png", "sprout1d.png"},
		{"lmn_sprout1w.png", "sprout1.png"},
		{"lmn_sprout1g.png", "sprout1g.png"},
		
		{"lmn_sprout2.png", "sprout2.png"},
		{"lmn_sprout2a.png", "sprout2a.png"},
		{"lmn_sprout2_emerge.png", "sprout2e.png"},
		{"lmn_sprout2_death.png", "sprout2d.png"},
		{"lmn_sprout2w.png", "sprout2.png"},
		{"lmn_sprout2g.png", "sprout2g.png"},
		
		{"lmn_sprout2ev.png", "sprout2ev.png"},
		
		{"lmn_sprout1g.png", "sprout1g.png"},
		{"lmn_sprout1ga.png", "sprout1ga.png"},
		{"lmn_sprout1g_death.png", "sprout1gd.png"},
		
		{"lmn_sprout2g.png", "sprout2g.png"},
		{"lmn_sprout2ga.png", "sprout2ga.png"},
		{"lmn_sprout2g_death.png", "sprout2gd.png"},
	}
	
	utils.appendAssets{
		writePath = "img/effects/emitters/",
		readPath = path .."img/effects/emitters/",
		{"lmn_petal_sprout1.png", "petal_sprout1.png"},
		{"lmn_petal_sprout2.png", "petal_sprout2.png"},
	}
	
	utils.appendAssets{
		writePath = "img/",
		readPath = path .."img/",
		{"portraits/enemy/lmn_Sprout1.png", "portraits/sprout1.png"},
		{"portraits/enemy/lmn_Sprout2.png", "portraits/sprout2.png"},
		{"weapons/lmn_SproutAtk1.png", "weapons/sproutAtk1.png"},
		{"weapons/lmn_SproutAtk2.png", "weapons/sproutAtk2.png"},
	}
	
	local a = ANIMS
	
	-- sprout1
	a.lmn_Sprout1 = a.BaseUnit:new{Image = imagePath .."lmn_sprout1.png", PosX = -13, PosY = 3}
	a.lmn_Sprout1a = a.lmn_Sprout1:new{Image = imagePath .."lmn_sprout1a.png", NumFrames = 4}
	a.lmn_Sprout1e = a.BaseEmerge:new{Image = "units/aliens/lmn_sprout1_emerge.png", PosX = -23, PosY = -2, Height = 1, Time = 0.1}
	a.lmn_Sprout1d = a.lmn_Sprout1:new{Image = "units/aliens/lmn_sprout1_death.png", PosX = -16, PosY = 11, NumFrames = 10, Time = .14, Loop = false}
	a.lmn_Sprout1w = a.lmn_Sprout1:new{Image = "units/aliens/lmn_sprout1w.png"}
	a.lmn_Sprout1pop = a.lmn_Sprout1e:new{Frames = {4,5,6,7,8,9}, Time = .075}
	
	--sprout2
	a.lmn_Sprout2 = a.BaseUnit:new{Image = "units/aliens/lmn_sprout2.png", PosX = -13, PosY = -1}
	a.lmn_Sprout2a = a.lmn_Sprout2:new{Image = "units/aliens/lmn_sprout2a.png", NumFrames = 4}
	a.lmn_Sprout2e = a.BaseEmerge:new{Image = "units/aliens/lmn_sprout2_emerge.png", PosX = -23, PosY = -6, NumFrames = 22, Height = 1, Time = 0.1,
		Lenghts = {.1,.1,.1,.1,.1,.1,.075,.075,.075,.075,.075,.075,.075,.075,.075,.075,.075,.075,.075,.075,.075,.075}
	}
	a.lmn_Sprout2d = a.lmn_Sprout2:new{Image = "units/aliens/lmn_sprout2_death.png", PosX = -16, PosY = 11, NumFrames = 10, Time = .14, Loop = false}
	a.lmn_Sprout2w = a.lmn_Sprout2:new{Image = "units/aliens/lmn_sprout2w.png"}
	a.lmn_Sprout2pop = a.lmn_Sprout2e:new{Frames = {16,17,18,19,20,21}, Time = .075}
	
	--sprout1 evolve to sprout2
	a.lmn_Sprout2ev = a.lmn_Sprout2e:new{Image = "units/aliens/lmn_sprout2ev.png", NumFrames = 17, Time = .075}
	
	--sprout1 bud, growing to sprout1
	a.lmn_Sprout1g = a.lmn_Sprout1:new{Image = "units/aliens/lmn_sprout1g.png", PosX = -23, PosY = 6}
	a.lmn_Sprout1ga = a.lmn_Sprout1g:new{Image = "units/aliens/lmn_sprout1ga.png", NumFrames = 4}
	a.lmn_Sprout1ge = a.lmn_Sprout1e:new{Frames = {0,1,2,3,4}, Time = .1}
	a.lmn_Sprout1gd = a.lmn_Sprout1g:new{Image = "units/aliens/lmn_sprout1g_death.png", NumFrames = 10, Time = .14, Loop = false}
	a.lmn_Sprout1gw = a.lmn_Sprout1g:new{Image = "units/aliens/lmn_sprout1g.png", NumFrames = 1}
	
	--sprout2 bud, growing to sprout2
	a.lmn_Sprout2g = a.lmn_Sprout2:new{Image = "units/aliens/lmn_sprout2g.png", PosX = -23, PosY = 6}
	a.lmn_Sprout2ga = a.lmn_Sprout2g:new{Image = "units/aliens/lmn_sprout2ga.png", NumFrames = 4}
	a.lmn_Sprout2ge = a.lmn_Sprout2e:new{
		Frames = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16},
		Lenghts = {.1,.1,.1,.1,.1,.1,.075,.075,.075,.075,.075,.075,.075,.075,.075,.075,.075},
		Time = .1,
	}
	a.lmn_Sprout2gd = a.lmn_Sprout2g:new{Image = "units/aliens/lmn_sprout2g_death.png", NumFrames = 10, Time = .14, Loop = false}
	a.lmn_Sprout2gw = a.lmn_Sprout2g:new{Image = "units/aliens/lmn_sprout2g.png", NumFrames = 1}
	
	--sprout1 evolving to sprout2
	a.lmn_SproutEv = a.lmn_Sprout1g
	a.lmn_SproutEva = a.lmn_Sprout1ga
	a.lmn_SproutEve = a.lmn_Sprout1e:new{Frames = {9,8,7,6,5,4}}
	a.lmn_SproutEvd = a.lmn_Sprout1gd
	a.lmn_SproutEvw = a.lmn_Sprout1gw
	
	trait:add{
		pawnType = "lmn_Sprout1",
		icon = path.."img/combat/bloom.png",
		icon_offset = Point(0,0),
		desc_title = "Bloom",
		desc_text = "Can choose to bloom to its alpha stage instead of attacking."
	}

	tutorialTips:add{
		id = "evolve",
		title = "Bloom",
		text = "This unit can choose to spend its turn blooming to its alpha stage instead of attacking."
	}

	tutorialTips:add{
		id = "sprout_Hotseat",
		title = "Evolve",
		text = "Sprouts can evolve to Alpha Sprouts by targeting their own tile."
	}

	lmn_Sprout1 = Pawn:new{
		Name = "Sprout",
		Health = 1,
		MoveSpeed = 3,
		SpawnLimit = false,
		Image = "lmn_Sprout1",
		lmn_PetalsOnDeath = "lmn_Emitter_Sprout1d",
		SkillList = { "lmn_SproutAtk1" },
		DefaultTeam = TEAM_ENEMY,
		SoundLocation = "/enemy/spider_soldier_1/",
		ImpactMaterial = IMPACT_FLESH,
		Portrait = "enemy/lmn_Sprout1"
	}
	AddPawnName("lmn_Sprout1")
	
	lmn_Sprout2 = lmn_Sprout1:new{
		Name = "Alpha Sprout",
		Health = 2,
		MoveSpeed = 3,
		Image = "lmn_Sprout2",
		lmn_PetalsOnDeath = "lmn_Emitter_Sprout2d",
		SkillList = { "lmn_SproutAtk2" },
		SoundLocation = "/enemy/spider_soldier_2/",
		Tier = TIER_ALPHA,
		Portrait = "enemy/lmn_Sprout2"
	}
	AddPawnName("lmn_Sprout2")
	
	lmn_SproutEv = lmn_Sprout1:new{
		Name = "Evolving Sprout",
		--IgnoreSmoke = true,
		MoveSpeed = 0,
		Image = "lmn_SproutEv",
		SkillList = {"lmn_SproutEvolve"},
		Pushable = false,
	}
	
	lmn_SproutEvolve = SelfTarget:new{
		Name = "Evolve",
		Description = "Evolve to alpha stage",
		-- Icon = TODO
		Class = "Enemy",
		LaunchSound = "",
		GrowAnim = "lmn_Sprout2ev",
		MyPawn = "lmn_Sprout2",
		lmn_PetalsOnDeath = "lmn_Emitter_Sprout1gd",
		TipImage = {
			Unit = Point(2,2),
			Target = Point(2,2),
			CustomPawn = "lmn_SproutEv",
			Length = 4,
		}
	}
	
	function lmn_SproutEvolve:GetSkillEffect(p1, p2)
		local ret = SkillEffect()
		local shooter = Board:GetPawn(p1)
		if not shooter then return ret end
		
		local status = {
			hp = shooter:GetHealth(),
			isAcid = shooter:IsAcid(),
			isFire = shooter:IsFire()
		}

		ret:AddScript(string.format([[
			local tutorialTips = LApi.library:fetch("tutorialTips", "lmn_into_the_wild");
			tutorialTips:trigger("evolve", %s);
		]], p1:GetString()))
		
		ret:AddQueuedScript(string.format("Board:RemovePawn(%s)", p1:GetString()))
		ret:AddQueuedAnimation(p1, self.GrowAnim)
		ret.q_effect:index(ret.q_effect:size()).bHide = true
		
		local delay = 0
		local time = ANIMS[self.GrowAnim].Time
		local numFrames = ANIMS[self.GrowAnim].NumFrames
		local frames = ANIMS[self.GrowAnim].Frames
		local lengths = ANIMS[self.GrowAnim].Lenghts
		
		if frames then
			for _, i in ipairs(frames) do
				local dt = lengths and lengths[i] or time
				delay = delay + dt
			end
		else
			if lengths then
				for i = 1, numFrames do
					local dt = lengths and lengths[i] or time
					delay = delay + dt
				end
			else
				delay = numFrames * time
			end
		end
		
		ret:AddQueuedDelay(delay)
		ret:AddQueuedScript(string.format("Board:AddPawn('%s', %s)", self.MyPawn, p1:GetString()))
		local hpDiff = _G[self.MyPawn].Health - status.hp
		if hpDiff > 0 then
			local dmg = hpDiff
			ret:AddQueuedScript(string.format("Board:GetPawn(%s):SetHealth(%s)", p1:GetString(), hpDiff))
		end
		if status.isAcid then
			ret:AddQueuedScript(string.format("Board:GetPawn(%s):SetAcid(true)", p1:GetString()))
		end
		if status.isFire then
			ret:AddQueuedScript(string.format("modApiExt_internal:getMostRecent().pawn:setFire(Board:GetPawn(%s), true)", p1:GetString()))
		end
		
		return ret
	end
	
	lmn_SproutAtk1 = Skill:new{
		Name = "Leaf Slam",
		Description = "Slam an adjacent tile.",
		Icon = "weapons/lmn_SproutAtk1.png",
		Class = "Enemy",
		PathSize = 1,
		Damage = 1,
		MyPawn = "lmn_SproutEv",
		LaunchSound = "",
		TipImage = {
			Unit = Point(2,2),
			Enemy = Point(2,1),
			Target = Point(2,1),
			CustomPawn = "lmn_Sprout1",
		}
	}
	
	function lmn_SproutAtk1:GetTargetArea(p)
		local ret = Board:GetSimpleReachable(p, self.PathSize, self.CornersAllowed)
		ret:push_back(p) -- if we attack this spot, we evolve.
		
		return ret
	end
	
	local isTargetScore
	function lmn_SproutAtk1:GetTargetScore(p1, p2)
		if p1 == p2 then return 1 end -- target self to evolve. low score of 1.
		
		return Skill.GetTargetScore(self, p1, p2)
	end
	
	function lmn_SproutAtk1:GetSkillEffect(p1, p2)
		local ret = SkillEffect()
		if p1 == p2 then
			-- evolve
			
			-- rem pawn
			ret:AddScript("Board:RemovePawn(Board:GetPawn(".. p1:GetString() .."))")
			
			-- add evolve pawn
			local d = SpaceDamage(p1)
			d.sPawn = self.MyPawn
			ret:AddDamage(d)
		else
			local d = SpaceDamage(p2, self.Damage)
			d.sSound = "enemy/spiderling_1/attack"
			d.sAnimation = "SwipeClaw1" -- TODO: Knock animation.
			ret:AddQueuedMelee(p1, d)
		end
		return ret
	end
	
	lmn_SproutAtk2 = lmn_SproutAtk1:new{
		Name = "Petal Slam",
		Icon = "weapons/lmn_SproutAtk2.png",
		Damage = 3,
		TipImage = {
			Unit = Point(2,2),
			Enemy = Point(2,1),
			Target = Point(2,1),
			CustomPawn = "lmn_Sprout2",
		}
	}
	
	lmn_SproutAtk2.GetTargetArea = Skill.GetTargetArea -- make it unable to evolve.
	
	lmn_SproutBud1 = lmn_Sprout1:new{
		MoveSpeed = 0,
		Image = "lmn_Sprout1g",
		lmn_PetalsOnDeath = "lmn_Emitter_Sprout1gd",
		--IgnoreSmoke = true,
		SkillList = {"lmn_SproutGrow1"},
		Pushable = false,
	}
	
	lmn_SproutBud2 = lmn_Sprout2:new{
		MoveSpeed = 0,
		Image = "lmn_Sprout2g",
		lmn_PetalsOnDeath = "lmn_Emitter_Sprout2gd",
		--IgnoreSmoke = true,
		SkillList = {"lmn_SproutGrow2"},
		Pushable = false,
	}
	
	lmn_SproutGrow1 = lmn_SproutEvolve:new{
		GrowAnim = "lmn_Sprout1pop",
		MyPawn = "lmn_Sprout1",
	}
	
	lmn_SproutGrow2 = lmn_SproutEvolve:new{
		GrowAnim = "lmn_Sprout2pop",
		MyPawn = "lmn_Sprout2",
	}
	
	function lmn_SproutGrow1:GetTargetScore() return 5 end
	function lmn_SproutGrow2:GetTargetScore() return 5 end
	
	lmn_Emitter_Sprout1d = Emitter:new{
		image = "effects/emitters/lmn_petal_sprout1.png",
		image_count = 1,
		max_alpha = 1.0,
		min_alpha = 0.0,
		rot_speed = 100,
		x = 0, y = 10, variance_x = 0, variance_y = 0,
		angle = 20, angle_variance = 220,
		timer = 0,
		burst_count = 1, speed = 1.00, lifespan = 1.0, birth_rate = 0,
		max_particles = 16,
		gravity = true,
		layer = LAYER_FRONT
	}
	
	lmn_Emitter_Sprout2d = Emitter:new{
		image = "effects/emitters/lmn_petal_sprout2.png",
		image_count = 1,
		max_alpha = 1.0,
		min_alpha = 0.0,
		rot_speed = 100,
		x = 0, y = 10, variance_x = 6, variance_y = 4,
		angle = 20, angle_variance = 220,
		timer = 0,
		burst_count = 5, speed = 1.00, lifespan = 1.0, birth_rate = 0,
		max_particles = 16,
		gravity = true,
		layer = LAYER_FRONT
	}
	
	lmn_Emitter_Sprout1gd = lmn_Emitter_Sprout1d:new{x = 0, y = 14}
	lmn_Emitter_Sprout2gd = lmn_Emitter_Sprout2d:new{x = 0, y = 14}
end

local hook_registered
function this:load(mod, options, version)
	local modUtils = getModUtils()
	
	modUtils:addPawnKilledHook(function(mission, pawn)
		if list_contains(self.sprouts, pawn:GetType()) then
			achvApi:TriggerChievo("sprout", {progress = 1})
		end
	end)
	
	local hotseat = mod_loader.mods["lmn_hotseat"]
	if not hook_registered and type(Hotseat) == 'table' then
		hook_registered = true
		Hotseat.addVekTurnStartHook(function()
			if not hotseat.installed then
				return
			end
			
			local tip_id = "sprout_Hotseat"
			if modApi:readProfileData(tip_id) then
				return
			end
			
			for _, pawnId in ipairs(extract_table(Board:GetPawns(TEAM_PLAYER))) do
				local pawn = Board:GetPawn(pawnId)
				if pawn:GetType() == "lmn_Sprout1" then
					tutorialTips:trigger(tip_id, pawn:GetSpace())
					break
				end
			end
		end)
	end
end

return this