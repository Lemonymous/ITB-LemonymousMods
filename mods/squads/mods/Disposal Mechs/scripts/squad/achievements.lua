
local mod = mod_loader.mods[modApi.currentMod]
local modApiExt = LApi.library:fetch("modApiExt/modApiExt", nil, "ITB-ModUtils")
local switch = LApi.library:fetch("switch")
local squad = "lmn_Disposal_Mechs"
local achievements = {
	teamwork = modApi.achievements:add{
		id = "teamwork",
		name = "Team Spirit",
		objective = {
			complete = true,
			easy = 0,
			normal = 0,
			hard = 0,
		},
		tooltip = "Move allied mechs with attacks 10 times in a single mission.\n\n"..
			"$status"..
			"Easy: $bronze\n"..
			"Normal: $silver\n"..
			"Hard: $gold",
		image = mod.resourcePath.."img/achievements/teamwork.png",
		squad = squad,
	},

	garbage = modApi.achievements:add{
		id = "garbage",
		name = "Garbage Day",
		objective = {
			complete = true,
			easy = 0,
			normal = 0,
			hard = 0,
		},
		tooltip = "Kill 10 enemies inflicted with A.C.I.D. in a single mission. (7 on Easy)\n\n"..
			"$status"..
			"Easy: $bronze\n"..
			"Normal: $silver\n"..
			"Hard: $gold",
		image = mod.resourcePath.."img/achievements/garbage.png",
		squad = squad,
	},

	cleaner = modApi.achievements:add{
		id = "cleaner",
		name = "Expert Cleaner",
		objective = {
			complete = true,
			easy = 0,
			normal = 0,
			hard = 0,
		},
		tooltip = "Win a game with at least 250 kills. (200 on Easy)\n\n"..
			"$status"..
			"Easy: $bronze\n"..
			"Normal: $silver\n"..
			"Hard: $gold",
		image = mod.resourcePath.."img/achievements/cleaner.png",
		squad = squad,
	},
}

local function isGame()
	return true
		and Game ~= nil
		and GAME ~= nil
end

local function isSquad()
	return true
		and isGame()
		and GAME.additionalSquadData.squad == squad
end

local function isMission()
	local mission = GetCurrentMission()

	return true
		and isGame()
		and mission ~= nil
		and mission ~= Mission_Test
end

local function isMissionBoard()
	return true
		and isMission()
		and Board ~= nil
		and Board:IsTipImage() == false
end

local function isGameData()
	return true
		and GAME ~= nil
		and GAME.lmn_Disposal_Mechs ~= nil
		and GAME.lmn_Disposal_Mechs.achievementData ~= nil
end

local function gameData()
	if GAME.lmn_Disposal_Mechs == nil then
		GAME.lmn_Disposal_Mechs = {}
	end

	if GAME.lmn_Disposal_Mechs.achievementData == nil then
		GAME.lmn_Disposal_Mechs.achievementData = {}
	end

	return GAME.lmn_Disposal_Mechs.achievementData
end

local function isMissionData()
	local mission = GetCurrentMission()

	return true
		and mission ~= nil
		and mission.lmn_Disposal_Mechs ~= nil
		and mission.lmn_Disposal_Mechs.achievementData ~= nil
end

local function missionData()
	local mission = GetCurrentMission()

	if mission.lmn_Disposal_Mechs == nil then
		mission.lmn_Disposal_Mechs = {}
	end

	if mission.lmn_Disposal_Mechs.achievementData == nil then
		mission.lmn_Disposal_Mechs.achievementData = {}
	end

	return mission.lmn_Disposal_Mechs.achievementData
end

local difficultyIndices = switch{
	[DIFF_EASY] = "easy",
	[DIFF_NORMAL] = "normal",
	[DIFF_HARD] = "hard",
	default = "hard"
}

local COMPLETE = 1
local INCOMPLETE = 0

-- teamwork
local TEAMWORK_TARGET = 10
local teamworkMechLocations = nil

local getTooltip = achievements.teamwork.getTooltip
achievements.teamwork.getTooltip = function(self)
	local result = getTooltip(self)
	local progress = self:getProgress()

	local bronze = progress.easy == COMPLETE and "Complete" or "-"
	local silver = progress.normal == COMPLETE and "Complete" or "-"
	local gold = progress.hard == COMPLETE and "Complete" or "-"
	local status = ""

	if isMission() then
		local progress = missionData().teamworkMoves.."/"..TEAMWORK_TARGET
		status = "Progress: "..progress.."\n\n"
	end

	result = result:gsub("%$status", status)
	result = result:gsub("%$bronze", bronze)
	result = result:gsub("%$silver", silver)
	result = result:gsub("%$gold", gold)

	return result
end

local function resetAchievementTeamwork()
	missionData().teamworkMoves = 0
end

modApi.events.onMissionStart:subscribe(resetAchievementTeamwork)
modApi.events.onMissionNextPhaseCreated:subscribe(resetAchievementTeamwork)

modApi.events.onModsLoaded:subscribe(function()
	modApiExt:addSkillStartHook(function(mission, pawn, weaponId, p1, p2)
		local exit = false
			or isMissionBoard() == false
			or isSquad() == false
			or teamworkMechLocations ~= nil
			or pawn:IsEnemy()

		if exit then
			return
		end

		local pawnId = pawn:GetId()
		local mechs = Board:GetPawns(TEAM_MECH)
		teamworkMechLocations = {}

		for i = 1, mechs:size() do
			local mechId = mechs:index(i)
			local mech = Board:GetPawn(mechId)

			if mechId ~= pawnId then
				teamworkMechLocations[mechId] = mech:GetSpace()
			end
		end
	end)
end)

modApi.events.onMissionUpdate:subscribe(function()
	local exit = false
		or isMission() == false
		or isSquad() == false
		or teamworkMechLocations == nil
		or Board:IsBusy()

	if exit then
		return
	end

	local missionData = missionData()
	local difficulty = GetRealDifficulty()
	local objective = difficultyIndices[difficulty]

	for mechId, loc in pairs(teamworkMechLocations) do
		local mech = Board:GetPawn(mechId)

		if mech and mech:GetSpace() ~= loc then
			missionData.teamworkMoves = missionData.teamworkMoves + 1
		end
	end

	local achievementCompleted = true
		and missionData.teamworkMoves >= TEAMWORK_TARGET
		and achievements.teamwork:getProgress()[objective] == INCOMPLETE

	if achievementCompleted then
		achievements.teamwork:addProgress{ [objective] = COMPLETE }
		achievements.teamwork:addProgress{ complete = false }
		achievements.teamwork:addProgress{ complete = true }
	end

	teamworkMechLocations = nil
end)

-- garbage
local GARBAGE_TARGET = switch{
	[DIFF_EASY] = 7,
	default = 10
}

local getTooltip = achievements.garbage.getTooltip
achievements.garbage.getTooltip = function(self)
	local result = getTooltip(self)
	local progress = self:getProgress()

	local bronze = progress.easy == COMPLETE and "Complete" or "-"
	local silver = progress.normal == COMPLETE and "Complete" or "-"
	local gold = progress.hard == COMPLETE and "Complete" or "-"
	local status = ""

	if isMission() then
		local difficulty = GetRealDifficulty()
		local progress = missionData().garbageKills.."/"..GARBAGE_TARGET[difficulty]
		status = "Progress: "..progress.."\n\n"
	end

	result = result:gsub("%$status", status)
	result = result:gsub("%$bronze", bronze)
	result = result:gsub("%$silver", silver)
	result = result:gsub("%$gold", gold)

	return result
end

local function resetAchievementGarbage()
	missionData().garbageKills = 0
end

modApi.events.onMissionStart:subscribe(resetAchievementGarbage)
modApi.events.onMissionNextPhaseCreated:subscribe(resetAchievementGarbage)

modApi.events.onModsLoaded:subscribe(function()
	modApiExt:addPawnKilledHook(function(mission, pawn)
		local exit = false
			or isMission() == false
			or isSquad() == false

		if exit then
			return
		end

		if pawn:IsEnemy() and pawn:IsAcid() then
			local missionData = missionData()
			local difficulty = GetRealDifficulty()
			local objective = difficultyIndices[difficulty]

			missionData.garbageKills = missionData.garbageKills + 1

			local achievementCompleted = true
				and missionData.garbageKills >= GARBAGE_TARGET[difficulty]
				and achievements.garbage:getProgress()[objective] == INCOMPLETE

			if achievementCompleted then
				achievements.garbage:addProgress{ [objective] = COMPLETE }
				achievements.garbage:addProgress{ complete = false }
				achievements.garbage:addProgress{ complete = true }
			end
		end
	end)
end)

-- cleaner
local CLEANER_TARGET = switch{
	[DIFF_EASY] = 200,
	default = 250
}
local EVENT_ENEMY_KILLED = 21
local EVENT_MINOR_ENEMY_KILLED = 12

local getTooltip = achievements.cleaner.getTooltip
achievements.cleaner.getTooltip = function(self)
	local result = getTooltip(self)
	local progress = self:getProgress()
	local showStatus = true
		and isGame()
		and isGameData()

	local bronze = progress.easy > 0 and progress.easy.." islands" or "-"
	local silver = progress.normal > 0 and progress.normal.." islands" or "-"
	local gold = progress.hard > 0 and progress.hard.." islands" or "-"
	local status = ""

	if showStatus then
		local difficulty = GetRealDifficulty()
		local progress = gameData().cleanerKills.."/"..CLEANER_TARGET[difficulty]
		status = "Kills: "..progress.."\n\n"
	end

	result = result:gsub("%$status", status)
	result = result:gsub("%$bronze", bronze)
	result = result:gsub("%$silver", silver)
	result = result:gsub("%$gold", gold)

	return result
end

modApi.events.onPostStartGame:subscribe(function()
	gameData().cleanerKills = 0
end)

modApi.events.onMissionUpdate:subscribe(function()
	local exit = false
		or isMission() == false
		or isSquad() == false
		or isGameData() == false

	if exit then
		return
	end

	local gameData = gameData()

	gameData.cleanerKills = 0
		+ gameData.cleanerKills
		+ Game:GetEventCount(EVENT_ENEMY_KILLED)
		+ Game:GetEventCount(EVENT_MINOR_ENEMY_KILLED)
end)

modApi.events.onGameVictory:subscribe(function(difficulty, islandsSecured, squad_id)
	local exit = false
		or isSquad() == false
		or gameData().cleanerKills < CLEANER_TARGET[difficulty]

	if exit then
		return
	end

	local objective = difficultyIndices[difficulty]

	if achievements.cleaner:getProgress()[objective] < islandsSecured then
		achievements.cleaner:addProgress{ [objective] = islandsSecured }
		achievements.cleaner:addProgress{ complete = false }
		achievements.cleaner:addProgress{ complete = true }
	end
end)
