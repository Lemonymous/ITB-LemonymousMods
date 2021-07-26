
local this = {
	desc = "Adds the Scarab Leader",
	sMission = "Mission_ScarabBoss",
	islandLock = 2,
}

Mission_ScarabBoss = Mission_Boss:new{
	BossPawn = "ScarabBoss",
	SpawnStartMod = 0,
	SpawnMod = -1,
	BossText = "Destroy the Scarab Leader"
}

local AtkInfo = {}
local UpdateGameVars = false

local function IsScarabBoss(pawn)
	return list_contains(_G[pawn:GetType()].SkillList, "lmn_ScarabAtkB")
end

-- returns true if list is empty.
local function list_isEmpty(list)
	for _,_ in pairs(list) do
		return false
	end
	return true
end

ScarabBoss = Pawn:new{
	Name = "Scarab Leader",
	Health = 6,
	MoveSpeed = 3,
	Image = "scarab",
	ImageOffset = 2,
	SkillList = { "lmn_ScarabAtkB" },
	Ranged = 1,
	SoundLocation = "/enemy/scarab_2/",
	Massive = true,
	ImpactMaterial = IMPACT_FLESH,
	DefaultTeam = TEAM_ENEMY,
	Portrait = "enemy/ScarabB",
	Tier = TIER_BOSS,
}

lmn_ScarabAtkB = SelfTarget:new{
	Name = "Spitting Glands",
	Description = "Lob powerful artillery shots at up to 3 separate tiles.",
	Damage = 4,
	Targets = 3,
	Class = "Enemy",
	Icon = "weapons/enemy_scarabB.png",
	Projectile = "effects/shotup_antB.png",
	LaunchSound = "",
	sExplosion = "ExploArt2",
	sImpactSound = "/impact/generic/explosion",
	CustomTipImage = "lmn_ScarabAtkB_Tip",
	TipImage = {
		Unit = Point(2,4),
		Building = Point(0,1),
		Building2 = Point(4,2),
		Enemy = Point(2,0),
		Target = Point(2,4),
		CustomPawn = "ScarabBoss"
	}
}

function lmn_ScarabAtkB:GetTileScore(tile)
	local effect = SkillEffect()
	effect:AddQueuedDamage(SpaceDamage(tile, self.Damage))
	return self:ScoreList(effect.q_effect, true)
end

function lmn_ScarabAtkB:GetTargetScore(p1, p2)
	
	-- prepare an AtkInfo table which contains
	-- targets and their respecive TargetScores
	local tileId = p2idx(p1)
	AtkInfo[tileId] = {}
	AtkInfo[tileId].offsets = {}
	AtkInfo[tileId].score = 0
	
	this.isTargetScore = true
	local ret = Skill.GetTargetScore(self, p1, p2)
	this.isTargetScore = nil
	
	return AtkInfo[tileId].score
end

function lmn_ScarabAtkB:Flip(id)
	local mission = GetCurrentMission()
	if
		not mission								or
		not mission[this.scarabs]				or
		not mission[this.scarabs][id]			or
		not mission[this.scarabs][id].offsets
	then
		return
	end
	
	for _, offset in ipairs(mission[this.scarabs][id].offsets) do
		offset.x = -offset.x
		offset.y = -offset.y
	end
end

function lmn_ScarabAtkB:GetSkillEffect(p1, p2) -- p1 == p2
	local ret = SkillEffect()
	
	--[[
		Queued attacks are weird. We need to make sure
		we have the correct pawn.
		
		it is probably because other enemies are checking
		if a tile is being attacked before moving.
		maybe investigate this next update and fix it.
	--]]
	local pawn = Board:GetPawn(p1)
	if
		not pawn				or
		not IsScarabBoss(pawn)
	then
		return ret
	end
	
	local mission = GetCurrentMission()
	if not mission then
		return ret
	end
	
	local id = pawn:GetId()
	local tileId = p2idx(p1)
	mission[this.scarabs] = mission[this.scarabs] or {}
	mission[this.scarabs][id] = mission[this.scarabs][id] or {}
	
	if this.isTargetScore then
		-- Enter here whenever lmn_ScarabAtkB:GetTargetScore
		--  is checking the score of a potential target tile.
		
		-- request GAME vars update with new target score data.
		mission[this.scarabs][id].shouldUpdate = true
		
		-- get all valid points in a diamond shape around target.
		local size = Board:GetSize()
		local range = math.ceil((size.x + size.y) / 2)
		local targetArea = extract_table(general_DiamondTarget(p1, range))
		
		local bestTargets = {}
		for _, tile in ipairs(targetArea) do
			-- filter out tiles near shooter
			local distance = p1:Manhattan(tile)
			if distance > 1 then
				table.insert(bestTargets, {point = tile, score = self:GetTileScore(tile)})
			end
		end
		
		-- sort list of points from lowest to highest TargetScore.
		table.sort(bestTargets, function(a,b) return a.score < b.score end)
		
		for k = 1, self.Targets do
			if #bestTargets == 0 then
				break
			end
			
			local minIndex = #bestTargets
			
			-- find all tiles that has the same TargetScore
			for i = #bestTargets, 0, -1 do
				if i == 0
				or bestTargets[#bestTargets].score ~= bestTargets[i].score
				then
					minIndex = i + 1
					break
				end
			end
			-- and pick one randomly among them.
			local targetIndex = math.random(minIndex, #bestTargets)
			
			-- pick the best tiles and save them to the AtkInfo table.
			table.insert(AtkInfo[tileId].offsets, bestTargets[targetIndex].point - p1)
			AtkInfo[tileId].score = AtkInfo[tileId].score + bestTargets[targetIndex].score
			
			table.remove(bestTargets, targetIndex)
		end
	else
		if mission[this.scarabs][id].shouldUpdate then
			mission[this.scarabs][id].shouldUpdate = nil
			-- Enter here after lmn_ScarabAtkB:GetTargetScore
			--  has iterated all potential targets,
			--  and chosen a tile we are going to move to.
			
			-- This table holds the target offset
			--  we will use for the attack this turn.
			mission[this.scarabs][id].offsets = {}
			
			for _, offset in ipairs(AtkInfo[tileId].offsets) do
				table.insert(mission[this.scarabs][id].offsets, offset)
			end
		end
		
		if mission[this.scarabs][id].offsets then
			for i = #mission[this.scarabs][id].offsets, 1, -1 do
				local curr = p1 + mission[this.scarabs][id].offsets[i]
				if not Board:IsValid(curr) then
					table.remove(mission[this.scarabs][id].offsets, i)
				else
					ret:AddQueuedScript([[Game:TriggerSound("/enemy/scarab_2/attack")]])
					local damage = SpaceDamage(curr, self.Damage)
					damage.sSound = self.sImpactSound
					damage.sAnimation = self.sExplosion
					ret:AddQueuedArtillery(damage, self.Projectile, 0.12)
				end
			end
		end
	end
	
	return ret
end

lmn_ScarabAtkB_Tip = lmn_ScarabAtkB:new{}
function lmn_ScarabAtkB_Tip:GetTargetScore(p1, p2)
	return Skill.GetTargetScore(self, p1, p2)
end

function lmn_ScarabAtkB_Tip:GetSkillEffect(p1, p2)
	this.isTipImage = true
	
	local ret = SkillEffect()
	local targets = {Point(0,1), Point(2,0), Point(4,2)}
	for _, target in ipairs(targets) do
		local damage = SpaceDamage(target, self.Damage)
		damage.sAnimation = self.sExplosion
		ret:AddQueuedArtillery(damage, self.Projectile, 0.12)
	end
	
	this.isTipImage = nil
	return ret
end

function this:init(mod)
	self.scarabs = mod.id .."_scarabs"
	
	self.boss = require(mod.scriptPath .."boss")
	self.boss:Add(self)
	
	modApi:appendAsset("img/effects/shotup_antB.png", mod.resourcePath .."img/effects/shotup_antB.png")
	modApi:appendAsset("img/weapons/enemy_scarabB.png", mod.resourcePath .."img/weapons/enemy_scarabB.png")
end

function this:load(modApiExt)
	
	modApiExt:addPawnUntrackedHook(function(mission, pawn)
		if
			not IsScarabBoss(pawn)		or
			not mission[self.scarabs]
		then
			return
		end
		
		mission[self.scarabs][pawn:GetId()] = nil
		
		if list_isEmpty(mission[self.scarabs]) then
			mission[self.scarabs] = nil
		end
	end)
	
	modApiExt:addSkillBuildHook(function(mission, pawn, weaponId, p1, p2, skillEffect)
		local modifyEffect = false
		local ret = SkillEffect()
		for _, spaceDamage in ipairs(extract_table(skillEffect.effect)) do
			if	spaceDamage.iPush == DIR_FLIP					and
				Board:IsPawnSpace(spaceDamage.loc)				and
				IsScarabBoss(Board:GetPawn(spaceDamage.loc))	then
				
				ret:AddScript("lmn_ScarabAtkB:Flip(".. Board:GetPawn(spaceDamage.loc):GetId() ..")")
				modifyEffect = true
			end
			ret.effect:push_back(spaceDamage)
		end
		
		if modifyEffect then
			skillEffect.effect = ret.effect
		end
	end)
	
	self.boss:ResetSpawnsWhenKilled(self)
	self.boss:SetSpawnsForDifficulty(
		self,
		{
			difficulty = DIFF_EASY,
			SpawnStartMod = -1,
			SpawnMod = -1
		}
	)
end

return this