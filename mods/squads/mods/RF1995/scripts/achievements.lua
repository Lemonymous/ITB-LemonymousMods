
local mod = mod_loader.mods[modApi.currentMod]
local modApiExt = LApi.library:fetch("modApiExt/modApiExt", nil, "ITB-ModUtils")
local squad = "RF1995"
local achievements = {
	monsterkill = modApi.achievements:add{
		id = "monsterkill",
		name = "Mo-mo-mo-monster Kill!",
		objective = {
			complete = true,
			easy = 0,
			normal = 0,
			hard = 0,
		},
		tooltip = "Kill 4 enemies with a single attack\n\n"..
			"Easy: $bronze\n"..
			"Normal: $silver\n"..
			"Hard: $gold",
		image = mod.resourcePath.."img/achievements/monsterkill.png",
		squad = squad,
	},

	untouchable = modApi.achievements:add{
		id = "untouchable",
		name = "Can't Touch This",
		objective = {
			complete = true,
			easy = 0,
			normal = 0,
			hard = 0,
		},
		tooltip = "Beat the game without taking any Mech damage\n\n"..
			"$status"..
			"Easy: $bronze\n"..
			"Normal: $silver\n"..
			"Hard: $gold",
		image = mod.resourcePath.."img/achievements/untouchable.png",
		squad = squad,
	},

	objective = modApi.achievements:add{
		id = "objective",
		name = "Eye on the Prize",
		objective = {
			complete = true,
			easy = 0,
			normal = 0,
			hard = 0,
		},
		tooltip = "Beat the game without failing an objective\n\n"..
			"$status"..
			"Easy: $bronze\n"..
			"Normal: $silver\n"..
			"Hard: $gold",
		image = mod.resourcePath.."img/achievements/objective.png",
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
		and GAME.lmn_RF1995 ~= nil
		and GAME.lmn_RF1995.achievementData ~= nil
end

local function gameData()
	if GAME.lmn_RF1995 == nil then
		GAME.lmn_RF1995 = {}
	end

	if GAME.lmn_RF1995.achievementData == nil then
		GAME.lmn_RF1995.achievementData = {}
	end

	return GAME.lmn_RF1995.achievementData
end

local difficultyIndices = {
	[DIFF_EASY] = "easy",
	[DIFF_NORMAL] = "normal",
	[DIFF_HARD] = "hard",
	default = "hard",
}

local COMPLETE = 1
local INCOMPLETE = 0

-- monsterkill
local monsterkillEnemyCount = nil

local getTooltip = achievements.monsterkill.getTooltip
achievements.monsterkill.getTooltip = function(self)
	local result = getTooltip(self)
	local progress = self:getProgress()

	local bronze = progress.easy == COMPLETE and "Complete" or "-"
	local silver = progress.normal == COMPLETE and "Complete" or "-"
	local gold = progress.hard == COMPLETE and "Complete" or "-"

	result = result:gsub("%$bronze", bronze)
	result = result:gsub("%$silver", silver)
	result = result:gsub("%$gold", gold)

	return result
end

modApi.events.onModsLoaded:subscribe(function()
	modApiExt:addSkillStartHook(function(mission, pawn, weaponId, p1, p2)
		local exit = false
			or isMissionBoard() == false
			or isSquad() == false
			or pawn:IsEnemy()
			or monsterkillEnemyCount ~= nil

		if exit then
			return
		end

		local enemies = Board:GetPawns(TEAM_ENEMY)
		monsterkillEnemyCount = enemies:size()
	end)
end)

modApi.events.onMissionUpdate:subscribe(function()
	local exit = false
		or isMission() == false
		or isSquad() == false
		or Board:IsBusy()
		or monsterkillEnemyCount == nil

	if exit then
		return
	end

	local difficulty = GetRealDifficulty()
	local objective = difficultyIndices[difficulty] or difficultyIndices.default
	local enemyKills = monsterkillEnemyCount - Board:GetPawns(TEAM_ENEMY):size()
	local achievementCompleted = true
		and enemyKills >= 4
		and achievements.monsterkill:getProgress()[objective] == INCOMPLETE

	if achievementCompleted then
		achievements.monsterkill:addProgress{ [objective] = COMPLETE }
		achievements.monsterkill:addProgress{ complete = false }
		achievements.monsterkill:addProgress{ complete = true }
	end

	monsterkillEnemyCount = nil
end)

-- untouchable
local EVENT_MECH_DAMAGED = 24

local getTooltip = achievements.untouchable.getTooltip
achievements.untouchable.getTooltip = function(self)
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
		local failed = gameData().untouchableFailed
		local eligible = failed and "Failed" or "Eligible"

		status = "Status: "..eligible.."\n\n"
	end

	result = result:gsub("%$status", status)
	result = result:gsub("%$bronze", bronze)
	result = result:gsub("%$silver", silver)
	result = result:gsub("%$gold", gold)

	return result
end

modApi.events.onPostStartGame:subscribe(function()
	gameData().untouchableFailed = false
end)

modApi.events.onMissionUpdate:subscribe(function(mission)
	local exit = false
		or isSquad() == false
		or isMission() == false
		or gameData().untouchableFailed

	if exit then
		return
	end

	if Game:GetEventCount(EVENT_MECH_DAMAGED) > 0 then
		gameData().untouchableFailed = true
	end
end)

modApi.events.onGameVictory:subscribe(function(difficulty, islandsSecured, squad_id)
	local exit = false
		or isSquad() == false
		or gameData().untouchableFailed

	if exit then
		return
	end

	local objective = difficultyIndices[difficulty] or difficultyIndices.default
	local chievo = achievements.untouchable
	local progress = shallow_copy(chievo:getProgress())

	if progress[objective] < islandsSecured then
		progress.complete = true
		progress[objective] = islandsSecured
		chievo:addProgress{ complete = false }
		chievo:setProgress(progress)
	end
end)

-- objective
local EVENT_POD_DESTROYED = 37

local getTooltip = achievements.objective.getTooltip
achievements.objective.getTooltip = function(self)
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
		local failed = gameData().objectiveFailed
		local eligible = failed and "Failed" or "Eligible"

		status = "Status: "..eligible.."\n\n"
	end

	result = result:gsub("%$status", status)
	result = result:gsub("%$bronze", bronze)
	result = result:gsub("%$silver", silver)
	result = result:gsub("%$gold", gold)

	return result
end

modApi.events.onPostStartGame:subscribe(function()
	gameData().objectiveFailed = false
end)

modApi.events.onMissionUpdate:subscribe(function(mission)
	local exit = false
		or isSquad() == false
		or isMission() == false
		or gameData().objectiveFailed

	if exit then
		return
	end

	if Game:GetEventCount(EVENT_POD_DESTROYED) > 0 then
		gameData().objectiveFailed = true
	end
end)

modApi.events.onMissionEnd:subscribe(function(mission)
	local exit = false
		or isSquad() == false
		or isMission() == false
		or gameData().objectiveFailed

	if exit then
		return
	end

	local objectives = mission:BaseCompletedObjectives()

	for _, obj in ipairs(objectives) do
		if obj.rep < obj.potential then
			gameData().objectiveFailed = true
		end
	end
end)

modApi.events.onGameVictory:subscribe(function(difficulty, islandsSecured, squad_id)
	local exit = false
		or isSquad() == false
		or gameData().objectiveFailed

	if exit then
		return
	end

	local objective = difficultyIndices[difficulty] or difficultyIndices.default
	local chievo = achievements.objective
	local progress = shallow_copy(chievo:getProgress())

	if progress[objective] < islandsSecured then
		progress.complete = true
		progress[objective] = islandsSecured
		chievo:addProgress{ complete = false }
		chievo:setProgress(progress)
	end
end)
