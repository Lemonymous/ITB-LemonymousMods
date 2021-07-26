
local path = mod_loader.mods[modApi.currentMod].resourcePath
local utils = require(path .."scripts/utils")
local pathfinder = require(path .."scripts/springseed_pathing")
local artiArrows = require(path .."scripts/artiArrows/artiArrows")
local pawnSpace = require(path .."scripts/pawnSpace")
local this = {}

Mission_lmn_SpringseedBoss = Mission_Boss:new{
	BossPawn = "lmn_SpringseedBoss",
	MapTags = {"lmn_jungle_leader"},
	SpawnStartMod = 0,
	SpawnMod = 0,
	BossText = "Destroy the Springseed Leader"
}

lmn_SpringseedBoss = lmn_Springseed2:new{
	Name = "Springseed Leader",
	Health = 6,
	MoveSpeed = 6,
	Image = "lmn_SpringseedB",
	lmn_PetalsOnDeath = "lmn_Emitter_SpringseedBd",
	SkillList = { "lmn_SpringseedAtkB" },
	Massive = true,
	Tier = TIER_BOSS,
	Portrait = "enemy/lmn_SpringseedBoss",
}

lmn_SpringseedAtkB = lmn_SpringseedAtk2:new{
	Name = "Spring-time!",
	Description = "Jump three times and drop spines of A.C.I.D. on the tiles below.",
	Damage = 5,
	Jumps = 3,
	Icon = "weapons/lmn_SpringseedAtkB.png",
	CustomTipImage = "lmn_SpringseedAtkB_Tip",
	TipImage = {
		Unit = Point(3,1),
		Building1 = Point(3,2),
		Building2 = Point(2,3),
		Building3 = Point(1,2),
		Enemy = Point(2,0),
		Target = Point(3,1),
		CustomPawn = "lmn_SpringseedBoss"
	}
}

function lmn_SpringseedAtkB:GetTargetArea(p)
	local ret = PointList()
	ret:push_back(p)
	return ret
end

local isTargetScore
function lmn_SpringseedAtkB:GetTargetScore(p1, p2)

	local mission = GetCurrentMission()
	if not mission then return 0 end
	
	local shooter = Board:GetPawn(p1)
	if not shooter then return 0 end
	
	local id = shooter:GetId()
	local pid = p2idx(p1)
	
	mission.lmn_springseedBoss = mission.lmn_springseedBoss or {}
	local m = mission.lmn_springseedBoss
	
	m[id] = m[id] or {}
	m = m[id]
	m.data = m.data or {}
	
	m.data[pid] = {
		offsets = {},
		score = 0
	}
	
	isTargetScore = true
	Skill.GetTargetScore(self, p1, p2)
	isTargetScore = nil
	
	return m.data[pid].score
end

function lmn_SpringseedAtkB:GetSkillEffect(p1, p2, parentSkill, isTipImage)
	local ret = SkillEffect()
	
	local mission = GetCurrentMission()
	if not mission then return ret end
	
	local shooter = Board:GetPawn(p1)
	if not shooter then return ret end
	
	local id = shooter:GetId()
	local pid = p2idx(p1)
	
	mission.lmn_springseedBoss = mission.lmn_springseedBoss or {}
	local m = mission.lmn_springseedBoss
	
	m[id] = m[id] or {}
	m = m[id]
	m.data = m.data or {}
	m.data[pid] = m.data[pid] or {}
	
	if isTargetScore then
		-- scoring in progress, request target lock when scoring is done.
		m.lockIn = true
		
		-- run pathfinder to find path with most damage.
		local bestPath, score = pathfinder.GetBest(p1, self.Jumps)
		local offsets = {}
		
		for _, loc in ipairs(bestPath) do
			offsets[#offsets+1] = loc - p1
		end
		
		-- store data
		m.data[pid] = {
			offsets = offsets,
			score = score
		}
		
		return ret
	elseif m.lockIn then
		-- scoring complete, lock in target offsets for pawn.
		m.lockIn = false
		m.offsets = m.data[pid].offsets
	end
	
	-- actual attack, based on locked in target data.
	local q1 = p1
	local move = PointList()
	move:push_back(p1)
	for k, off in ipairs(m.offsets or {}) do
		local q2 = p1 + off
		local dir = GetDirection(q2 - q1)
		local target = q1 + DIR_VECTORS[dir]
		
		if not Board:IsBlocked(q2, PATH_FLYER) then
			ret:AddScript(string.format("Board:SetDangerous(%s)", q2:GetString()))
			
			local d = SpaceDamage(q1)
			d.sImageMark = artiArrows.ColorUp(dir)
			ret:AddQueuedDamage(d)
			
			-- actual leap via script to hide preview.
			ret:AddQueuedScript(string.format([[
				local leap = PointList();
				leap:push_back(%s);
				leap:push_back(%s);
				fx = SkillEffect();
				fx:AddLeap(leap, NO_DELAY);
				Board:AddEffect(fx);
			]], q1:GetString(), q2:GetString()))
			
			ret:AddQueuedDelay(.25) -- short delay before dealing damage mid leap.
			ret:AddQueuedSound(self.Sound_Impact)
			ret:AddQueuedScript(string.format("Board:AddAnimation(%s, '%s', ANIM_NO_DELAY)", target:GetString(), self.Anim_Launch .. dir))
			ret:AddQueuedDelay(.25)
			
			local damage = SpaceDamage(target, self.Damage)
			damage.iAcid = 1
			ret:AddQueuedDamage(damage)
			ret:AddQueuedDelay(0.3)
			
			q1 = q2
		else
			local d = SpaceDamage(q1)
			d.sImageMark = artiArrows.WhiteUp(dir)
			ret:AddQueuedDamage(d)
			ret:AddQueuedScript("Board:AddAlert(".. q1:GetString() ..", 'ATTACK BLOCKED')")
			
			break
		end
		
		move:push_back(q2)
		
		local d = SpaceDamage(q2)
		d.sImageMark = artiArrows.ColorDown(dir)
		ret:AddQueuedDamage(d)
		
		if utils.IsPit(q2) then
			break
		end
	end
	
	pawnSpace.QueuedClearSpace(ret, p1)
	ret:AddQueuedMove(move, NO_DELAY)
	pawnSpace.QueuedRewind(ret)
	
	return ret
end

-- hardcoded tipimage.
lmn_SpringseedAtkB_Tip = lmn_SpringseedAtkB:new{}
function lmn_SpringseedAtkB_Tip:GetSkillEffect(p1, p2, parentSkill)
	local ret = SkillEffect()
	
	local move = PointList()
	move:push_back(p1)
	local q1 = p1
	local q2
	
	ret:AddQueuedDelay(0.25)
	ret:AddQueuedScript(string.format("Board:GetPawn(%s):Move(Point(1,1))", self.TipImage.Enemy:GetString()))
	ret:AddQueuedDelay(0.50)
	
	for k = 1, 3 do
		local target = self.TipImage["Building".. k]
		local dir = GetDirection(target - q1)
		q2 = target + DIR_VECTORS[dir]
		
		local d = SpaceDamage(q1)
		d.sImageMark = artiArrows.ColorUp(dir)
		ret:AddQueuedDamage(d)
		
		if k < 3 then
			ret:AddQueuedScript(string.format([[
				local leap = PointList();
				leap:push_back(%s);
				leap:push_back(%s);
				fx = SkillEffect();
				fx:AddLeap(leap, NO_DELAY);
				Board:AddEffect(fx);
			]], q1:GetString(), q2:GetString()))
			
			ret:AddQueuedDelay(0.25) -- short delay before dealing damage mid leap.
			ret:AddQueuedScript(string.format("Board:AddAnimation(%s, '%s', ANIM_NO_DELAY)", target:GetString(), self.Anim_Launch .. dir))
			ret:AddQueuedDelay(0.25)
			
			local damage = SpaceDamage(target, self.Damage)
			damage.iAcid = 1
			ret:AddQueuedDamage(damage)
			ret:AddQueuedDelay(0.3)
			
			q1 = q2
		end
		
		move:push_back(q2)
		
		local d = SpaceDamage(q2)
		d.sImageMark = artiArrows.ColorDown(dir)
		ret:AddQueuedDamage(d)
	end
	
	pawnSpace.QueuedClearSpace(ret, p1)
	ret:AddQueuedMove(move, NO_DELAY)
	pawnSpace.QueuedRewind(ret)
	
	ret:AddQueuedDelay(0.75)
	ret:AddQueuedScript("Board:AddAlert(".. q1:GetString() ..", 'ATTACK BLOCKED')")
	
	return ret
end

local writePath = "img/units/aliens/"
local readPath = path .. "img/units/aliens/"
local imagePath = writePath:sub(5,-1)
utils.appendAssets{
	writePath = writePath,
	readPath = readPath,
	{"lmn_springseedB.png", "springseedB.png"},
	{"lmn_springseedBa.png", "springseedBa.png"},
	{"lmn_springseedB_emerge.png", "springseedBe.png"},
	{"lmn_springseedB_death.png", "springseedBd.png"},
	{"lmn_springseedBw.png", "springseedBw.png"}
}

local a = ANIMS
a.lmn_SpringseedB = a.BaseUnit:new{Image = imagePath .."lmn_springseedB.png", PosX = -21, PosY = -10}
a.lmn_SpringseedBa = a.lmn_SpringseedB:new{Image = imagePath .."lmn_springseedBa.png", NumFrames = 6}
a.lmn_SpringseedBe = a.BaseEmerge:new{Image = imagePath .."lmn_springseedB_emerge.png", PosX = -23, PosY = -7, Height = 1}
a.lmn_SpringseedBd = a.lmn_SpringseedB:new{Image = imagePath .."lmn_springseedB_death.png", Loop = false, NumFrames = 10, Time = .14}
a.lmn_SpringseedBw = a.lmn_SpringseedB:new{Image = imagePath .."lmn_springseedBw.png", PosX = -22, PosY = 8}

function this:init(mod)
end

function this:load(mod, options, version)
end

return this