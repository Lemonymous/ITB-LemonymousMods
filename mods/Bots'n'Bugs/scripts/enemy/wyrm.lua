
local mod = mod_loader.mods[modApi.currentMod]
local path = mod.resourcePath
local pawnSpace = require(path .."scripts/libs/pawnSpace")
local worldConstants = mod.libs.worldConstants
local tips = mod.libs.tutorialTips
local a = ANIMS
local writepath = "img/units/aliens/"
local readpath = path .. writepath
local imagepath = writepath:sub(5,-1)
local this = {}

modApi:appendAsset(writepath .."lmn_wyrm.png", readpath .."wyrm.png")
modApi:appendAsset(writepath .."lmn_wyrma.png", readpath .."wyrma.png")
modApi:appendAsset(writepath .."lmn_wyrm_death.png", readpath .."wyrm_death.png")
modApi:appendAsset(writepath .."lmn_wyrm_emerge.png", readpath .."wyrm_emerge.png")

modApi:appendAsset("img/portraits/enemy/lmn_Wyrm1.png", path .."img/portraits/enemy/Wyrm1.png")
modApi:appendAsset("img/portraits/enemy/lmn_Wyrm2.png", path .."img/portraits/enemy/Wyrm2.png")
modApi:appendAsset("img/portraits/enemy/lmn_WyrmB.png", path .."img/portraits/enemy/WyrmB.png")

local base = a.EnemyUnit:new{Image = imagepath .."lmn_wyrm.png", PosX = -18, PosY = -21, Time = 0.24}
local baseEmerge = a.BaseEmerge:new{Image = imagepath .."lmn_wyrm_emerge.png", PosX = -23, PosY = -13, Lengths = {
	.15,
	.10,
	.15,
	.15,
	.15,
	.10,
	.20,
	.15,
	.20,
	.15,
}}

a.lmn_wyrm  =	base
a.lmn_wyrme =	baseEmerge
a.lmn_wyrma =	base:new{ Image = "units/aliens/lmn_wyrma.png", NumFrames = 5 }
a.lmn_wyrmd =	base:new{ Image = "units/aliens/lmn_wyrm_death.png", PosX = -20, NumFrames = 8, Time = 0.14, Loop = false}

local function IsWyrm(pawn)
	local pawn_type = _G[pawn:GetType()]

	if type(pawn_type.IsLmnWyrm) == "function" then
		return pawn_type:IsLmnWyrm(pawn) == true
	end

	return pawn_type.LmnWyrm == true
end

lmn_Wyrm1 = Pawn:new{
	Name = "Wyrm",
	Health = 3,
	MoveSpeed = 4,
	Image = "lmn_wyrm",
	ImageOffset = 0,
	SkillList = { "lmn_WyrmAtk1" },
	SoundLocation = "/enemy/hornet_1/",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_INSECT,
	Portrait = "enemy/lmn_Wyrm1",
	Flying = true,
	LmnWyrm = true,
}
AddPawnName("lmn_Wyrm1")

lmn_Wyrm2 = lmn_Wyrm1:new{
	Name = "Alpha Wyrm",
	Health = 5,
	MoveSpeed = 4,
	Image = "lmn_wyrm",
	ImageOffset = 1,
	SkillList = { "lmn_WyrmAtk2" },
	SoundLocation = "/enemy/hornet_2/",
	Tier = TIER_ALPHA,
	Portrait = "enemy/lmn_Wyrm2",
}
AddPawnName("lmn_Wyrm2")

lmn_WyrmBoss = lmn_Wyrm1:new{
	Name = "Wyrm Leader",
	Health = 7,
	MoveSpeed = 3,
	Image = "lmn_wyrm",
	ImageOffset = 2,
	SkillList = { "lmn_WyrmAtkB" },
	SoundLocation = "/enemy/hornet_2/",
	Tier = TIER_BOSS,
	Portrait = "enemy/lmn_WyrmB",
	Massive = true,
}
AddPawnName("lmn_WyrmBoss")

lmn_WyrmAtk1 = Skill:new{
	Name = "Glaive Wurm",
	Description = "Point blank shot which bounces each time it hits a target. \n\n The bounce prioritizes units and halves the damage each jump.",
	--Description = "Fire a shot at point blank. The shot bounces to nearby objects, favoring units; halving the damage each jump.",
	Icon = "weapons/lmn_wyrm.png",
	Class = "Enemy",
	PathSize = 1,
	Damage = 2,
	Bounces = 1,
	LaunchSound = "",
	CustomTipImage = "lmn_WyrmAtk1_Tip",
	TipImage = {
		CustomPawn = "lmn_Wyrm1",
		Unit = Point(2,2),
		Enemy = Point(2,1),
		Building = Point(1,1),
		Target = Point(2,1),
	}
}

-- returns an index associated with a point.
-- should work for points just outside of board as well without collisions.
local function p2idx(p)
	return p.y * 100 + p.x
end

local function IsEnemy(p1, p2)
	local pawn1 = Board:GetPawn(p1)
	local pawn2 = Board:GetPawn(p2)
	if pawn1 and pawn2 then
		-- allow dead mechs to pull shots as well.
		if pawn1:GetTeam() ~= pawn2:GetTeam() then
			return true
		end
	end

	return false
end

local function isValidTarget(origin, target, path)
	return
		Board:IsValid(target)			and
		origin ~= target				and
		not list_contains(path, target)	and

		-- allow destroyed buildings to pull shots as well.
		--(Board:IsBuilding(target) or IsEnemy(origin, target))

		-- target enemy units as well.
		--(Board:IsBuilding(target) or Board:IsPawnSpace(target))

		-- target every blocked tile.
		Board:IsBlocked(target, PATH_PROJECTILE)
end

function lmn_WyrmAtk1:GetSkillEffect(p1, p2)
	local ret = SkillEffect()

	-- Queued attacks are weird. Make sure
	-- we have the correct pawn.
	local pawn = Board:GetPawn(p1)
	if not pawn or not IsWyrm(pawn) then
		return ret
	end

	if not Board:IsTipImage() then
		ret:AddScript(string.format([[
			local tips = mod_loader.mods.lmn_bots_and_bugs.libs.tutorialTips;
			tips:trigger("Wyrm_Atk", %s);
		]], p1:GetString()))
	end

	local mission = GetCurrentMission()
	local id = pawn:GetId()
	local priority = {}
	local rng = {}

	if mission then
		-- retrieve priority list.
		mission.lmn_WyrmPriority = mission.lmn_WyrmPriority or {}
		mission.lmn_WyrmPriority[id] = mission.lmn_WyrmPriority[id] or {}
		priority = mission.lmn_WyrmPriority[id]
	end

	local path = {p2}
	if Board:IsBlocked(p2, PATH_PROJECTILE) then -- don't jump after hitting empty tile.
		for k = 1, self.Bounces or 0 do
			-- use offset from p1 to current node as identifier for priority list.
			local id = p2idx(path[k] - p1)

			-- gather adjacent targets.
			local targets = {}
			for dir = DIR_START, DIR_END do
				local loc = path[k] + DIR_VECTORS[dir]

				if isValidTarget(p1, loc, path) then
					targets[#targets+1] = {
						id = id,
						dir = dir,
						loc = loc
					}
				end
			end

			if #targets > 0 then
				-- sort list according to current direction priority,
				-- and randomize priority for newly seen targets.
				table.sort(targets, function(a,b)
					for _, dir in ipairs(priority[a.id] or {}) do
						if dir == a.dir then return true end	-- a is prioritized.
						if dir == b.dir then return false end	-- b is prioritized.
					end

					-- need fixed rng in sort.
					rng[a.id] = rng[a.id] or math.random()
					rng[b.id] = rng[b.id] or math.random()

					return rng[a.id] < rng[b.id]
				end)

				local priorityIndex = 1

				-- prioritize units above buildings.
				for i, target in ipairs(targets) do
					if Board:IsPawnSpace(target.loc) then
						priorityIndex = i
					end
				end

				local target = targets[priorityIndex]
				local id = target.id
				local dir = target.dir
				local loc = target.loc

				if not Board:IsTipImage() then
					-- store direction in priority list.
					priority[id] = priority[id] or {}
					if not list_contains(priority[id], dir) then
						table.insert(priority[id], dir)
					end
				end

				path[#path+1] = loc
			else
				-- no more targets.
				break
			end
		end
	end

	-- attack resolution.
	local dmg = self.Damage
	for i, loc in ipairs(path) do
		local d = SpaceDamage(loc, dmg)

		if i == 1 then
			-- attack sounds
			ret:AddQueuedSound("enemy/jelly/hurt")
			ret:AddQueuedSound("enemy/spider_soldier_1/hurt")
			ret:AddQueuedSound("impact/generic/web")

			worldConstants:queuedSetSpeed(ret, .3)
			ret:AddQueuedProjectile(d, "effects/shot_firefly2", NO_DELAY)
			worldConstants:queuedResetSpeed(ret)
			ret:AddQueuedDelay(0.20)
			ret:AddQueuedScript(string.format("Board:AddAnimation(%s, 'ExploFirefly2', NO_DELAY)", loc:GetString()))

			-- impact sounds
			ret:AddQueuedSound("enemy/centipede_1/attack")
			ret:AddQueuedSound("props/freezing_mine")
			ret:AddQueuedSound("impact/generic/web")
			ret:AddQueuedDelay(0.02)
		else
			local from = path[i-1]

			-- fire bouncing projectile.
			ret:AddQueuedScript(string.format("lmn_WyrmAtk1:Bounce(%s, %s, %s)", from:GetString(), loc:GetString(), id))

			local dir = GetDirection(loc - from)
			d.sImageMark = "combat/lmn_wyrm_arrow_".. dir ..".png"

			ret:AddQueuedDelay(0.12)
			ret:AddQueuedDamage(d)
			ret:AddQueuedScript(string.format("Board:AddAnimation(%s, 'ExploFirefly2', NO_DELAY)", loc:GetString()))

			-- impact sounds
			ret:AddQueuedSound("enemy/centipede_1/attack")
			ret:AddQueuedSound("props/freezing_mine")
			ret:AddQueuedSound("impact/generic/web")
			ret:AddQueuedDelay(0.02)
		end

		dmg = math.floor(dmg / 2)
	end

	-- additional slowdown after attack,
	-- to let the player register what happened.
	if #path > 1 then
		ret:AddQueuedDelay(0.7)
	end

	return ret
end

function lmn_WyrmAtk1:Bounce(p1, p2, iOwner)
	-- this projectile is only visual, so we can
	-- omit it if the board busystate is not 0.
	-- when scorpions lose their web (state 2),
	-- the projectile would be delayed
	-- until that animation is done.

	if Board:GetBusyState() == 2 then
		return
	end

	local fx = SkillEffect()
	fx.piOrigin = p1
	fx.iOwner = iOwner

	local d = SpaceDamage(p2)
	worldConstants:setSpeed(fx, .5)
	fx:AddProjectile(p1, d, "effects/shot_firefly2", NO_DELAY)
	worldConstants:resetSpeed(fx)

	Board:AddEffect(fx)
end

lmn_WyrmAtk2 = lmn_WyrmAtk1:new{
	Name = "Glaive Wurm",
	Damage = 4,
	Bounces = 2,
	CustomTipImage = "lmn_WyrmAtk2_Tip",
	TipImage = {
		CustomPawn = "lmn_Wyrm2",
		Unit = Point(2,2),
		Enemy = Point(2,1),
		Building = Point(1,1),
		Enemy2 = Point(0,1),
		Target = Point(2,1),
	}
}

lmn_WyrmAtkB = lmn_WyrmAtk1:new{
	Name = "Glaive Wurm",
	Damage = 6,
	Bounces = 2,
	CustomTipImage = "lmn_WyrmAtkB_Tip",
	TipImage = {
		CustomPawn = "lmn_WyrmBoss",
		Unit = Point(2,2),
		Enemy = Point(2,1),
		Building = Point(1,1),
		Enemy2 = Point(0,1),
		Target = Point(2,1),
	}
}

lmn_WyrmAtk1_Tip = lmn_WyrmAtk1:new{}
lmn_WyrmAtk2_Tip = lmn_WyrmAtk2:new{}
lmn_WyrmAtkB_Tip = lmn_WyrmAtkB:new{}

function lmn_WyrmAtk1_Tip:GetSkillEffect(p1, p2)
	return lmn_WyrmAtk1.GetSkillEffect(self, p1, p2)
end

lmn_WyrmAtk2_Tip.GetSkillEffect = lmn_WyrmAtk1_Tip.GetSkillEffect
lmn_WyrmAtkB_Tip.GetSkillEffect = lmn_WyrmAtk1_Tip.GetSkillEffect


function this:load()
	modApi:addNextTurnHook(function(m)
		if Game:GetTeamTurn() == TEAM_ENEMY then
			-- clear priority lists
			m.lmn_WyrmPriority = {}
		end
	end)
end

return this