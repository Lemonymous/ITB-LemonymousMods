
local path = mod_loader.mods[modApi.currentMod].resourcePath
local utils = require(path .."scripts/utils")
local switch = LApi.library:fetch("switch")
local customEmitter = require(path .."scripts/customEmitter")
local teamTurn = require(path .."scripts/teamTurn")
local tutorialTips = LApi.library:fetch("tutorialTips")
local getModUtils = require(path .."scripts/getModUtils")
local this = {}

local Evolution = switch{
	[1] = function(pawnType)
		local evolution = pawnType:sub(1,-2) .."2"
		return _G[evolution] and evolution
	end,
	[2] = function(pawnType)
		local evolution = pawnType:sub(1,-2) .."Boss"
		return _G[evolution] and evolution
	end,
	default = function()
		return nil end
}

local function GetEvolution(pawnType)
	return Evolution:case(tonumber(pawnType:sub(-1,-1)), pawnType)
end

local function isValidTarget(loc)
	local mission = GetCurrentMission()
	if not mission then return false end
	mission.lmn_infusedPawns = mission.lmn_infusedPawns or {}
	
	local pawn = Board:GetPawn(loc)
	if pawn and pawn:GetTeam() == TEAM_ENEMY then
		local pawnId = pawn:GetId()
		if not mission.lmn_infusedPawns[pawnId] then
			return GetEvolution(pawn:GetType())
		end
	end
	
	return false
end

function this:init(mod)
	WeakPawns.lmn_Infuser = false
	Spawner.max_pawns.lmn_Infuser = 1
	Spawner.max_level.lmn_Infuser = 1
	
	local writePath = "img/units/aliens/"
	local readPath = path .. "img/units/aliens/"
	local imagePath = writePath:sub(5,-1)
	utils.appendAssets{
		writePath = writePath,
		readPath = readPath,
		{"lmn_infuser1.png", "infuser1.png"},
		{"lmn_infuser1a.png", "infuser1a.png"},
		{"lmn_infuser1_emerge.png", "infuser1e.png"},
		{"lmn_infuser1_death.png", "infuser1d.png"},
		{"lmn_infuser1w.png", "infuser1.png"},
	}
	
	utils.appendAssets{
		writePath = "img/",
		readPath = path .."img/",
		{"portraits/enemy/lmn_Infuser1.png", "portraits/infuser1.png"},
		{"effects/lmn_explo_fragrance.png", "effects/explo_fragrance.png"},
		{"effects/smoke/lmn_infuser_petal.png", "effects/smoke/infuser_petal.png"},
		{"weapons/lmn_InfuserAtk.png", "weapons/infuserAtk.png"},
	}
	
	local a = ANIMS
	local base = a.BaseUnit:new{Image = imagePath .."lmn_infuser1.png", PosX = -14, PosY = -8}
	local baseEmerge = a.BaseEmerge:new{Image = imagePath .."lmn_infuser1_emerge.png", PosX = -23, PosY = -8, Height = 1}
	
	a.lmn_Infuser1 = base
	a.lmn_Infuser1a = base:new{Image = imagePath .."lmn_infuser1a.png", NumFrames = 4}
	a.lmn_Infuser1e = baseEmerge
	a.lmn_Infuser1d = base:new{Image = imagePath .."lmn_infuser1_death.png", Loop = false, NumFrames = 10, Time = .14}
	a.lmn_Infuser1w = base:new{Image = imagePath .."lmn_infuser1w.png"}
	
	a.lmn_ExploFragrance = a.ExploAir2:new{Image = "effects/lmn_explo_fragrance.png"}
	
	a.lmn_Infuser_Evolve = Animation:new{
		Image = "combat/icons/powerup.png",
		PosX = 5, PosY = 15,
		NumFrames = 8,
		Time = 0.1,
		Loop = true
	}
	
	lmn_Infuser_Petal_Evolving = Emitter:new{
		image = "effects/smoke/lmn_infuser_petal.png",
		max_alpha = 1, min_alpha = 0.0,
		x = 0, y = 0, variance_x = 20, variance_y = 15,
		angle = 60, angle_variance = 60,
		timer = 0.1, birth_rate = 3, burst_count = 0, max_particles = 128,
		speed = 0.20, lifespan = 1, rot_speed = 40, gravity = true,
		layer = LAYER_FRONT
	}
	
	lmn_Infuser_Petal_Evolving_Tip = lmn_Infuser_Petal_Evolving:new{ timer = 3, birth_rate = 1 }
	
	-- angles matching the board directions,
	-- with variance going an equal amount to either side.
	local angle_variance = 30
	local angle_0 = 323 + angle_variance / 2
	local angle_1 = 37 + angle_variance / 2
	local angle_2 = 142 + angle_variance / 2
	local angle_3 = 218 + angle_variance / 2
	
	lmn_Infuser_Petal_Spray_0 = Emitter:new{
		image = "effects/smoke/lmn_infuser_petal.png",
		max_alpha = 1, min_alpha = 0.0,
		x = -26, y = 28, variance_x = 20, variance_y = 15,
		angle = angle_0, angle_variance = angle_variance,
		timer = 0.5, birth_rate = 0.1, burst_count = 30, max_particles = 128,
		speed = 3.00, lifespan = 1.0, rot_speed = 20, gravity = false,
		layer = LAYER_FRONT
	}
	lmn_Infuser_Petal_Spray_1 = lmn_Infuser_Petal_Spray_0:new{x = -26, y = -8, angle = angle_1}
	lmn_Infuser_Petal_Spray_2 = lmn_Infuser_Petal_Spray_0:new{x = 26, y = -8, angle = angle_2}
	lmn_Infuser_Petal_Spray_3 = lmn_Infuser_Petal_Spray_0:new{x = 26, y = 28, angle = angle_3}
	
	lmn_Infuser1 = Pawn:new{
		Name = "Infuser",
		Health = 2,
		MoveSpeed = 2,
		Image = "lmn_Infuser1",
		SkillList = { "lmn_InfuserAtk1" },
		SoundLocation = "/enemy/crab_1/", -- TODO: find correct soundbase enemy/centipede_1
		lmn_PetalsOnDeath = "lmn_Emitter_Infuser1d",
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_FLESH,
		Portrait = "enemy/lmn_Infuser1", -- TODO: add portrait
	}
	AddPawnName("lmn_Infuser1")
	
	lmn_InfuserAtk1 = Skill:new{
		Name = "Infuse",
		Icon = "weapons/lmn_InfuserAtk.png",
		Class = "Enemy",
		--Description = "Infuse a friend, evolving it to a stronger unit next turn.",
		Description = "Infuse a friend; evolving normal units to alphas, and alphas to bosses.",
		PathSize = 1,
		LaunchSound = "",
		Anim_Impact = "lmn_ExploFragrance",
		Sound_Impact = "/props/smoke_cloud",
		CustomTipImage = "lmn_InfuserAtk1_Tip",
		TipImage = {
			Unit = Point(2,3),
			Friendly = Point(2,2),
			Target = Point(2,2),
			CustomPawn = "lmn_Infuser1"
		}
	}
	
	function lmn_InfuserAtk1:GetTargetScore(p1, p2)
		--local score = Skill.GetTargetScore(self, p1, p2)
		
		if isValidTarget(p2) then
			return 5
		end
		
		return -10
	end
	
	function lmn_InfuserAtk1:Infuse(p2)
		local mission = GetCurrentMission()
		local pawn = Board:GetPawn(p2)
		
		if not mission then return end
		if not pawn then return end
		
		local pawnId = pawn:GetId()
		customEmitter:Add(nil, pawnId, "lmn_Infuser_Petal_Evolving")--, {"Evolving", "This unit will evolve to a stronger unit next turn."})
		
		mission.lmn_infusedPawns = mission.lmn_infusedPawns or {}
		mission.lmn_infusedPawns[pawnId] = Game:GetTurnCount()
	end
	
	function lmn_InfuserAtk1:Evolve(pawnId)
		local pawn = Board:GetPawn(pawnId)
		local pawnType = pawn:GetType()
		local evolutionType = GetEvolution(pawnType)
		if not evolutionType then return end
		
		local fx = SkillEffect()
		local loc = pawn:GetSpace()
		local locIsValid = Board:IsValid(loc)
		local status = {
			damage = _G[pawnType].Health - pawn:GetHealth(),
			isAcid = pawn:IsAcid(),
			isFire = pawn:IsFire(),
			isShield = pawn:IsShield()
		}
		
		if locIsValid then
			fx:AddAnimation(loc, self.Anim_Impact)
			fx:AddScript(string.format("Board:AddAlert(%s, 'EVOLUTION COMPLETE')", loc:GetString()))
		end
		
		fx:AddSound(self.Sound_Impact)
		fx:AddDelay(.5)
		fx:AddSound("ui/general/level_up")
		
		if locIsValid then
			fx:AddScript(string.format("Board:Ping(%s, GL_Color(255,255,255))", loc:GetString()))
		end
		
		-- swap pawns and update hp and status effects.
		fx:AddScript(string.format("Board:RemovePawn(Board:GetPawn(%s))", pawnId))
		fx:AddScript(string.format([[
			local evolutionType, loc, status = '%s', %s, %s;
			
			local pawn = PAWN_FACTORY:CreatePawn(evolutionType);
			Board:AddPawn(pawn);
			pawn:SetSpace(loc);
			
			if status.damage > 0 then
				pawn:SetHealth(_G[evolutionType].Health - status.damage);
			end
			if status.isAcid then
				pawn:SetAcid(true);
			end
			if status.isFire then
				modApiExt_internal:getMostRecent().pawn:setFire(pawn, true);
			end
			if status.isShield then
				pawn:SetShield(true);
			end
		]], evolutionType, loc:GetString(), save_table(status)))
		
		Board:AddEffect(fx)
	end
	
	function lmn_InfuserAtk1:GetSkillEffect(p1, p2, parentSkill, isTipImage)
		local ret = SkillEffect()
		local dir = GetDirection(p2 - p1)
		
		
		ret:AddSound("enemy/shared/moved")
		ret:AddEmitter(p2, "lmn_Infuser_Petal_Spray_".. dir)
		ret:AddDelay(0.5)
		
		if not isTipImage then
			ret:AddScript(string.format("lmn_InfuserAtk1:Infuse(%s)", p2:GetString()))
		end
		
		return ret
	end
	
	lmn_InfuserAtk1_Tip = lmn_InfuserAtk1:new{}
	function lmn_InfuserAtk1_Tip:GetSkillEffect(p1, p2, parentSkill)
		local ret = lmn_InfuserAtk1.GetSkillEffect(self, p1, p2, parentSkill, isTipImage)
		local evolutionType
		
		local pawn = Board:GetPawn(p2)
		if pawn then
			evolutionType = GetEvolution(pawn:GetType())
		end
		
		ret:AddEmitter(p2, "lmn_Infuser_Petal_Evolving_Tip")
		ret:AddDelay(3)
		ret:AddAnimation(p2, self.Anim_Impact)
		ret:AddScript(string.format("Board:AddAlert(%s, 'EVOLUTION COMPLETE')", p2:GetString()))
		ret:AddDelay(.5)
		
		if evolutionType then
			-- swap pawns.
			ret:AddScript(string.format("Board:RemovePawn(%s)", p2:GetString()))
			ret:AddScript(string.format("Board:AddPawn('%s', %s)", evolutionType, p2:GetString()))
		end
		
		ret:AddDelay(2)
		
		return ret
	end
	
	lmn_Emitter_Infuser1d = Emitter:new{
		image = "effects/smoke/lmn_infuser_petal.png",
		max_alpha = 1, min_alpha = 0.0,
		x = 0, y = 0, variance_x = 20, variance_y = 15,
		angle = 0, angle_variance = 360,
		timer = 0, birth_rate = 0, burst_count = 32, max_particles = 32,
		speed = 0.40, lifespan = 2, rot_speed = 40, gravity = false,
		layer = LAYER_FRONT
	}
	
	tutorialTips:add{
		id = "infuser",
		title = "Infuse",
		text = "This unit's attack can change normal units into alphas, and alphas into bosses."
	}
end

function this:load(mod, options, version)
	local modUtils = getModUtils()
	
	modUtils:addPawnTrackedHook(function(_, pawn)
		
		if pawn:GetType() == "lmn_Infuser1" then
			tutorialTips:trigger("infuser", pawn:GetSpace())
		end
	end)
	
	modApi:addNextTurnHook(function(mission)
		mission.lmn_infusedPawns = mission.lmn_infusedPawns or {}
		
		local rem = {}
		local isVekTurn = teamTurn.IsVekTurn()
		local turnCount = Game:GetTurnCount()
		
		for pawnId, evolveTurn in pairs(mission.lmn_infusedPawns) do
			local pawn = Board:GetPawn(pawnId)
			
			if pawn then
				local loc = pawn:GetSpace()
				local canEvolve = evolveTurn < (turnCount - (isVekTurn and 0 or 1))
				
				if canEvolve and not pawn:IsFrozen() and not pawn:IsDead() then
					lmn_InfuserAtk1:Evolve(pawnId)
				end
			else
				rem[#rem+1] = pawnId
			end
		end
		
		for _, pawnId in ipairs(rem) do
			mission.lmn_infusedPawns[pawnId] = nil
		end
	end)
end

return this