
local this = {
	desc = "Adds the Blobber Leader",
	sMission = "Mission_BlobberBoss",
	islandLock = 3
}

Mission_BlobberBoss = Mission_Boss:new{
	BossPawn = "BlobberBoss",
	SpawnStartMod = -1,
	SpawnMod = -3,
	BossText = "Destroy the Blobber Leader"
}

BlobberBoss = Pawn:new{
	Name = "Blobber Leader",
	Health = 6,
	MoveSpeed = 2,
	Image = "blobber",
	ImageOffset = 2,
	SkillList = { "lmn_BlobberAtkB" },
	Ranged = 1,
	SoundLocation = "/enemy/blobber_2/",
	Massive = true,
	ImpactMaterial = IMPACT_BLOB,
	DefaultTeam = TEAM_ENEMY,
	Portrait = "enemy/BlobberB",
	Tier = TIER_BOSS,
}

lmn_BlobberAtkB = SelfTarget:new{
	Name = "Explosive Growths",
	Description = "Throws multiple monstrous blobs that will explode.",
	ScoreNothing = 0,
	MyPawn = "lmn_BlobB",
	OnlyEmpty = true,
	Class = "Enemy",
	Icon = "weapons/enemy_blobberB.png",
	Projectile =  "effects/shotup_blobberB.png",
	LaunchSound = "",
	sImpactSound = "/impact/generic/blob",
	CustomTipImage = "BlobberAtkB_Tip",
	TipImage = {
		Unit = Point(2,4),
		Building = Point(1,1),
		Building2 = Point(2,1),
		Enemy = Point(3,2),
		Target = Point(2,4),
		Second_Origin = Point(2,4),
		Second_Target = Point(2,4),
		CustomPawn = "BlobberBoss"
	}
}

lmn_BlobB = Pawn:new{
	Name = "Leader Blob",
	Health = 1,
	MoveSpeed = 0,
	Image = "blob",
	ImageOffset = 2,
	Minor = true,
	SkillList = { "lmn_BlobAtkB" },
	SoundLocation = "/enemy/blob_2/",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_BLOB,
	Portrait = "enemy/BlobB",
	Tier = TIER_ALPHA,
}

lmn_BlobAtkB = BlobAtk1:new{
	Name = "Explosive Guts",
	Description = "Explode, killing itself and damaging adjacent tiles. Kill it first to stop it.",
	Explosion = "explo_fire1",
	Damage = 2,
	InnerDamage = DAMAGE_DEATH,
	OuterDamage = 2,
	OuterExplosion = "exploout2_",
	BombSize = 1,
	Class = "Enemy",
	Icon = "weapons/enemy_blobB.png",
	TipImage = {
		Unit = Point(2,2),
		Target = Point(2,2),
		Enemy = Point(2,1),
		Building = Point(1,2),
		Enemy2 = Point(2,3),
		CustomPawn = "lmn_BlobB"
	}
}

local AtkInfo = {}

local function GetBlobCount()
	local list = {
		[DIFF_EASY] =		{minBlobs = 1, maxBlobs = 2, maxEnemies = 3},
		[DIFF_NORMAL] =		{minBlobs = 1, maxBlobs = 3, maxEnemies = 4},
		[DIFF_HARD] =		{minBlobs = 2, maxBlobs = 3, maxEnemies = 5},
		[DIFF_VERY_HARD] =	{minBlobs = 2, maxBlobs = 4, maxEnemies = 6},
		[DIFF_IMPOSSIBLE] = {minBlobs = 3, maxBlobs = 4, maxEnemies = 6}
	}
	
	local diff = GetDifficulty()
	if not list[diff] then
		diff = DIFF_NORMAL
	end
	
	local enemies = #extract_table(Board:GetPawns(TEAM_ENEMY))
	local minBlobs = list[diff].minBlobs
	local maxBlobs = list[diff].maxBlobs
	local maxEnemies = list[diff].maxEnemies
	
	return math.max(minBlobs, math.min(maxBlobs, maxEnemies - enemies))
end

local function BlobB_TargetScore(self, p2)
	local effect = SkillEffect()
	
	if
		p2.x == 0 or
		p2.x == 7 or
		p2.y == 0 or
		p2.y == 7
	then
		return -10
	end
	
	if not Board:IsSafe(p2) then return -10 end
	
	local damage = SpaceDamage(p2)
	damage.sPawn = self.MyPawn
	effect:AddDamage(damage)
	for i = DIR_START, DIR_END do
		for k = 1, lmn_BlobAtkB.BombSize do
			local curr = p2 + DIR_VECTORS[i] * k
			if not Board:IsValid(curr) then
				break
			end
			effect:AddQueuedDamage(SpaceDamage(p2 + DIR_VECTORS[i] * k, lmn_BlobAtkB.OuterDamage))
		end
	end
	
	return self:ScoreList(effect.effect, false) + self:ScoreList(effect.q_effect, true)
end

local isTargetScore = false
function lmn_BlobberAtkB:GetTargetScore(p1, p2)
	
	-- Prepare an AtkInfo table which contains
	--  targets and their respecive TargetScores
	local tileId = p2idx(p1)
	AtkInfo[tileId] = {}
	AtkInfo[tileId].offsets = {}
	AtkInfo[tileId].score = 0
	
	isTargetScore = true
	self:GetSkillEffect(p1, p2)
	isTargetScore = false
	
	return AtkInfo[tileId].score
end

function lmn_BlobberAtkB:GetSkillEffect(p1, p2, parentSkill, isTipImage)
	local ret = SkillEffect()
	local tileId = p2idx(p1)
	
	if isTargetScore then
		-- Enter here whenever lmn_BlobberAtkB:GetTargetScore()
		--  is checking the score of a potential target tile.
		
		-- get all valid points in a diamond shape around target.
		local size = Board:GetSize()
		local range = math.ceil((size.x + size.y) / 2)
		local targetArea = extract_table(general_DiamondTarget(p1, range))
		
		local bestTargets = {}
		for _, tile in ipairs(targetArea) do
			-- filter out tiles near shooter
			local distance = p1:Manhattan(tile)
			if distance > 1 then
				table.insert(bestTargets, {point = tile, score = BlobB_TargetScore(self, tile)})
			end
		end
		
		-- sort list of points from lowest to highest TargetScore.
		table.sort(bestTargets, function(a,b) return a.score < b.score end)
		
		for k = 1, GetBlobCount() do
			if #bestTargets == 0 then
				break
			end
			
			local minIndex = #bestTargets
			
			-- give points with equal TargetScore equal chance to be chosen.
			for i = #bestTargets, 0, -1 do
				if	i == 0													or
					bestTargets[#bestTargets].score ~= bestTargets[i].score	then
					
					minIndex = i + 1
					break
				end
			end
			local targetIndex = math.random(minIndex, #bestTargets)
			
			-- pick the best points and save them to the AtkInfo table.
			table.insert(AtkInfo[tileId].offsets, bestTargets[targetIndex].point - p1)
			AtkInfo[tileId].score = AtkInfo[tileId].score + bestTargets[targetIndex].score
			
			table.remove(bestTargets, targetIndex)
		end
	end
	
	if isTipImage then
		local targets = GetDifficulty() == DIFF_EASY	and
			{Point(0,1), Point(2,0)}					or
			{Point(0,1), Point(2,0), Point(3,1)}
			
		if Board:IsPawnSpace(targets[1]) then
			for _, target in ipairs(targets) do
				for _, v in ipairs(extract_table(lmn_BlobAtkB:GetSkillEffect(target, target).q_effect)) do
					ret.q_effect:push_back(v)
				end
			end
		else
			for _, target in ipairs(targets) do
				local damage = SpaceDamage(target)
				damage.sPawn = self.MyPawn
				ret:AddArtillery(damage, self.Projectile, 0.32)
			end
		end
	else
		for _, offset in ipairs(AtkInfo[tileId].offsets) do
			if Board:IsValid(p1 + offset) then
				ret:AddScript([[Game:TriggerSound("/enemy/blobber_2/attack")]])
				
				local damage = SpaceDamage(p1 + offset, self.Damage)
				damage.sPawn = self.MyPawn
				damage.sSound = self.sImpactSound
				ret:AddArtillery(damage, self.Projectile, 0.32)
			end
		end
	end
	
	return ret
end

BlobberAtkB_Tip = lmn_BlobberAtkB:new{}

function BlobberAtkB_Tip:GetSkillEffect(p1, p2, parentSkill)
	return lmn_BlobberAtkB.GetSkillEffect(self, p1, p2, parentSkill, true)
end

function this:init(mod)
	self.boss = require(mod.scriptPath .."boss")
	self.boss:Add(self)
	
	modApi:appendAsset("img/weapons/enemy_blobB.png", mod.resourcePath .."img/weapons/enemy_blobB.png")
	modApi:appendAsset("img/weapons/enemy_blobberB.png", mod.resourcePath .."img/weapons/enemy_blobberB.png")
	modApi:appendAsset("img/effects/shotup_blobberB.png", mod.resourcePath .."img/effects/shotup_blobberB.png")
end

function this:load()
	self.boss:ResetSpawnsWhenKilled(self)
	self.boss:SetSpawnsForDifficulty(
		self,
		{
			difficulty = DIFF_EASY,
			SpawnStartMod = -3,
			SpawnMod = -3
		},
		{
			difficulty = DIFF_NORMAL,
			SpawnStartMod = -2,
			SpawnMod = -3
		}
	)
end

return this