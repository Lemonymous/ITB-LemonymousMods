
local this = {
	desc = "Adds the Leaper Leader",
	sMission = "Mission_LeaperBoss",
	islandLock = 3
}

Mission_LeaperBoss = Mission_Boss:new{
	BossPawn = "LeaperBoss",
	SpawnStartMod = -1,
	SpawnMod = -2,
	BossText = "Destroy the Leaper Leader"
}

LeaperBoss = Pawn:new{
	Name = "Leaper Leader",
	Health = 5,
	MoveSpeed = 5,
	Image = "leaper",
	ImageOffset = 2,
	Jumper = true,
	SkillList = { "lmn_LeaperAtkB" },
	SoundLocation = "/enemy/leaper_2/",
	Massive = true,
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_FLESH,
	Portrait = "enemy/LeaperB",
	Tier = TIER_BOSS,
}

lmn_LeaperAtkB = LeaperAtk1:new{
	Name = "Razor Sharp Fangs",
	Description = "Web the target, preparing to bite it.",
	Class = "Enemy",
	Damage = 5,
	Icon = "weapons/enemy_leaperB.png",
	SoundBase = "/enemy/leaper_2",
	TipImage = {
		Unit = Point(2,2),
		Enemy = Point(2,1),
		Target = Point(2,1),
		CustomPawn = "LeaperBoss"
	}
}

local function IsLeaperBoss(pawn)
	return pawn:GetType() == _G[this.sMission].BossPawn
end

local oldGetStatusTooltip = GetStatusTooltip
function GetStatusTooltip(id, ...)
	if id == "evasive" then
		return {"Evasive", "If this unit survives damage, it will reposition and attack somewhere else."}
	end
	return oldGetStatusTooltip(id, ...)
end

local function SetEvasive(tile, flag)
	if Board:IsValid(tile) then
		Board:SetTerrainIcon(tile, flag and "evasive" or "")
	end
end

local function CustomLeap(pawn)
	local mission = GetCurrentMission()
	if not mission then return end
	
	-- Disable functionality if the source of the damage
	-- was presumably from a modified 'Move' skill,
	-- to avoid coding in what to do
	-- if the player does undo movement.
	
	-- IsUndoPossible is bugged, and will fail
	-- if a pawn is clicked on while already selected.
	
	if
		pawn:GetHealth() <= 0										or
		(this.lastSelected and this.lastSelected:IsUndoPossible())	or
		pawn:IsFrozen()
	then
		return
	end
	
	local PawnBackup = Pawn; Pawn = pawn
	local p1 = pawn:GetSpace()
	local weapon = _G[_G[pawn:GetType()].SkillList[1]]
	
	local actions = {}
	local reachable = extract_table(Board:GetReachable(p1, pawn:GetMoveSpeed(), pawn:GetPathProf()))
	
	-- create a list of all possible moves.
	for _, loc in ipairs(reachable) do
		-- move score
		local moveScore = ScorePositioning(loc, pawn)
		
		targets = extract_table(weapon:GetTargetArea(loc))
		for _, target in ipairs(targets) do
			if Board:IsValid(target) then
				-- attack score
				local attackScore = weapon:GetTargetScore(loc, target)
				
				table.insert(
					actions,
					{
						loc = loc,
						target = target,
						score = moveScore + attackScore
					}
				)
			end
		end
	end
	Pawn = PawnBackup
	
	if #actions == 0 then
		return
	end
	
	-- sort scores from high to low.
	table.sort(actions, function(a,b) return a.score > b.score end)
	
	-- count #indices with same top score.
	local i = 1
	while(actions[i+1] and actions[i+1].score == actions[1].score) do
		i = i + 1
	end
	
	-- pick one top score at random.
	local bestAction = actions[math.random(1, i)]
	
	local id = pawn:GetId()
	mission[this.leapers] = mission[this.leapers] or {}
	mission[this.leapers][id] = mission[this.leapers][id] or {}
	mission[this.leapers][id].leapTo = bestAction.loc
	mission[this.leapers][id].target = bestAction.target
	
	local move = PointList()
	move:push_back(p1)
	move:push_back(bestAction.loc)
	
	local effect = SkillEffect()
	effect:AddLeap(move, FULL_DELAY)
	Board:AddEffect(effect)
end

function this:init(mod)
	self.leapers = mod.id .."_leapers"
	
	self.boss = require(mod.scriptPath .."boss")
	self.boss:Add(self)
	
	modApi:appendAsset("img/weapons/enemy_leaperB.png",mod.resourcePath.."img/weapons/enemy_leaperB.png")
	modApi:appendAsset("img/combat/icons/icon_evasive.png",mod.resourcePath.."img/combat/icons/icon_evasive.png")
	modApi:appendAsset("img/combat/icons/icon_evasive_glow.png",mod.resourcePath.."img/combat/icons/icon_evasive_glow.png")
	
	Location["combat/icons/icon_evasive_glow.png"] = Point(0,0)
	
	Global_Texts.lmn_Evasive_Text = "When the Leaper Leader survives damage, it will reposition and attack somewhere else."
	Global_Texts.lmn_Evasive_Title = "Evasive"
	
	sdlext.addGameExitedHook(function()
		self.lastSelected = nil
	end)
end

function this:load(modApiExt)
	modApi:addMissionStartHook(function() this.lastSelected = nil end)
	modApi:addMissionNextPhaseCreatedHook(function() this.lastSelected = nil end)
	modApiExt:addPawnSelectedHook(function(mission, pawn) self.lastSelected = pawn end)
	
	modApiExt:addPawnTrackedHook(function(mission, pawn)
		if not IsLeaperBoss(pawn) then return end
		
		mission[self.leapers] = mission[self.leapers] or {}
		local id = pawn:GetId()
		mission[self.leapers][id] = {}
		mission[self.leapers][id].iconLoc = Point(-1, -1)
		mission[self.leapers][id].loc = pawn:GetSpace()
		mission[self.leapers][id].curHealth = pawn:GetHealth()
		mission[self.leapers][id].maxHealth = lmn_MB_CUtils.GetMaxHealth(pawn)
		
		local hasSeenTip = modApi:readProfileData("lmn_Evasive")
		if not hasSeenTip then
			Game:AddTip("lmn_Evasive", mission[self.leapers][id].loc)
			modApi:writeProfileData("lmn_Evasive", true)
		end
	end)
	
	modApi:addNextTurnHook(function(mission)
		mission[self.leapers] = mission[self.leapers] or {}
		
		for id, leaper in pairs(mission[self.leapers]) do
			leaper.AttackCanceled = false
		end
	end)
	
	modApi:addMissionUpdateHook(function(mission)
		local rem = {}
		
		mission[self.leapers] = mission[self.leapers] or {}
		for id, leaper in pairs(mission[self.leapers]) do
			local pawn = Board:GetPawn(id)
			if not pawn then
				table.insert(rem, id)
			else
				local curr = pawn:GetSpace()
				
				if	SmokeCancelsAttack	and
					Board:IsSmoke(curr)	then
					
					leaper.AttackCanceled = true
				end
				
				if	lmn_MB_CUtils.GetMaxHealth(pawn) == leaper.maxHealth	and
					pawn:GetHealth() < leaper.curHealth			and
					pawn:GetHealth() > 0						and
					Board:GetBusyState() ~= 6					then
					
					leaper.markedForLeap = true
					leaper.attack =	this.lastSelected							and
									this.lastSelected:GetTeam() == TEAM_PLAYER	and	-- Only attack from player initiated damage.
									_G[pawn:GetType()].SkillList ~= nil			and
									_G[_G[pawn:GetType()].SkillList[1]] ~= nil	and -- Check for valid weapon in slot 1.
									not leaper.AttackCanceled
				end
				
				-- if we have been issued to leap
				-- keep trying to leap until we can.
				if	leaper.markedForLeap		and
					Board:GetBusyState() == 0	and
					pawn:GetHealth() > 0		and
					not pawn:IsBusy()			then
					
					leaper.markedForLeap = nil
					leaper.markedForLanding = true
					CustomLeap(pawn)
				end
				
				-- check if our leap has arrived at new location.
				if	leaper.markedForLanding		and
					Board:GetBusyState() == 0	and
					pawn:GetHealth() > 0		and
					not pawn:IsBusy()			then
					
					if leaper.attack and leaper.target then
						local effect = SkillEffect()
						effect:AddDelay(0.08)
						effect:AddScript([[
							Game:GetPawn(]].. pawn:GetId() .."):FireWeapon(".. leaper.target:GetString() ..[[, 1);
						]])
						Board:AddEffect(effect)
					end
					
					leaper.markedForLanding = nil
				end
				
				leaper.loc = curr
				leaper.curHealth = pawn:GetHealth()
				leaper.maxHealth = lmn_MB_CUtils.GetMaxHealth(pawn)
				
				-- update evasive icon location.
				if curr ~= leaper.iconLoc then
					SetEvasive(leaper.iconLoc, false)
					SetEvasive(curr, true)
					leaper.iconLoc = curr
				end
			end
		end
		
		for _, id in ipairs(rem) do
			SetEvasive(mission[self.leapers][id].iconLoc, false)
			mission[self.leapers][id] = nil
		end
	end)
	
	self.boss:ResetSpawnsWhenKilled(self)
	self.boss:SetSpawnsForDifficulty(
		self,
		{
			difficulty = DIFF_EASY,
			SpawnStartMod = -2,
			SpawnMod = -2
		}
	)
end

function this:smokeCancel(flag)
	SmokeCancelsAttack = flag
end

function this:ResetTips()
	modApi:writeProfileData("lmn_Evasive", false)
end

return this