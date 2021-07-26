
local this = {}

local function shouldWeb(pawn)
	GAME.lmn_EnableWeb = GAME.lmn_EnableWeb or {}
	return not this.delay_web or GAME.lmn_EnableWeb[pawn:GetId()]
end

-- based on of ScorpionAtk1.GetSkillEffect
local function webSingle(self, p1, p2, bool)
	local ret = SkillEffect()
	local direction = GetDirection(p2 - p1)
	local push = self.Push == 1 and direction or DIR_NONE
	
	local shouldWeb = Pawn and shouldWeb(Pawn) or true
	
	if self.Web == 1 and shouldWeb then
		local sound = SpaceDamage(p2)
		ret:AddDamage(SoundEffect(p2, self.SoundBase .."/attack_web"))
		ret:AddGrapple(p1, p2, "hold")
	end
	
	local damage = SpaceDamage(p2, self.Damage, push)
	damage.sAnimation = "SwipeClaw2"
	damage.iAcid = self.Acid
	damage.sSound = self.SoundBase .."/attack"
	
	ret:AddQueuedMelee(p1,damage)
	
	return ret
end

-- based on ScorpionAtkB.GetSkillEffect
local function webMulti(self, p1, p2, bool)
	local ret = SkillEffect()
	
	for dir = DIR_START, DIR_END do 
		local damage = SpaceDamage(p1 + DIR_VECTORS[dir], self.Damage, dir)
		damage.sAnimation = "SwipeClaw2"
		damage.sSound = self.SoundBase .."/attack"
		ret:AddQueuedMelee(p1, damage, 0.35)
		
		local shouldWeb = Pawn and shouldWeb(Pawn) or true
		
		if shouldWeb then
			ret:AddDamage(SoundEffect(p1 + DIR_VECTORS[dir], self.SoundBase .."/attack_web"))
			ret:AddGrapple(p1, p1 + DIR_VECTORS[dir], "hold")
		end
	end
	
	return ret
end


-- base on SpiderAtk1.GetSkillEffect
local function webArti(self, p1, p2, bool)
	local ret = SkillEffect()
	local damage = SpaceDamage(p2)
	damage.sPawn = self.MyPawn
	ret:AddArtillery(damage, self.MyArtillery)
	
	local shouldWeb = Pawn and shouldWeb(Pawn) or true
	
	if shouldWeb then
		for dir = DIR_START, DIR_END do
			ret:AddGrapple(p2, p2 + DIR_VECTORS[dir], "hold")
		end
	end
	
	return ret
end

local function ReplaceGetSkillEffect(func, newGetSkillEffect)
	if type(func) == 'table' then
		func.GetSkillEffect = newGetSkillEffect
	end
end

ReplaceGetSkillEffect(ScorpionAtk1, webSingle)
ReplaceGetSkillEffect(ScorpionAtk2, webSingle)
ReplaceGetSkillEffect(ScorpionAtkB, webMulti)
ReplaceGetSkillEffect(LeaperAtk1, webSingle)
ReplaceGetSkillEffect(LeaperAtk2, webSingle)
ReplaceGetSkillEffect(LeaperAtkB, webSingle)
ReplaceGetSkillEffect(SpiderAtk1, webArti)
ReplaceGetSkillEffect(SpiderAtk2, webArti)

local function enableWeb()
	local ids = extract_table(Board:GetPawns(TEAM_ENEMY))
	
	GAME.lmn_EnableWeb = GAME.lmn_EnableWeb or {}
	for _, id in ipairs(ids) do
		GAME.lmn_EnableWeb[id] = true
	end
end

function this:load(options)
	this.delay_web = options["option_delay_web"].enabled
	
	if this.delay_web then
		modApi:addMissionStartHook(function()
			GAME.lmn_EnableWeb = {}
			enableWeb()
		end)
		
		if modApi:isVersion("2.3.0") then
			modApi:addTestMechEnteredHook(function()
				GAME.lmn_EnableWeb = {}
				enableWeb()
			end)
		end
		
		modApi:addNextTurnHook(function()
			if Game:GetTeamTurn() == TEAM_PLAYER then
				enableWeb()
			end
		end)
	end
end

return this