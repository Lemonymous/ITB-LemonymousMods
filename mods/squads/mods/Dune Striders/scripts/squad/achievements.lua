
local mod = mod_loader.mods[modApi.currentMod]
local modApiExt = LApi.library:fetch("modApiExt/modApiExt", nil, "ITB-ModUtils")
local squad = "lmn_dune_striders"
local achievements = {
	dust = modApi.achievements:add{
		id = "dust",
		name = "Dust Storm",
		objective = {
			complete = true,
			easy = 0,
			normal = 0,
			hard = 0,
		},
		tooltip = "End a battle with 14 tiles covered in smoke\n\n"..
			"Easy: $bronze\n"..
			"Normal: $silver\n"..
			"Hard: $gold",
		image = mod.resourcePath.."img/achievements/dust.png",
		squad = squad,
	},

	artificial = modApi.achievements:add{
		id = "artificial",
		name = "Artificial Victory",
		objective = {
			complete = true,
			easy = 0,
			normal = 0,
			hard = 0,
		},
		tooltip = "Beat the game with only AI pilots\n\n"..
			"$status"..
			"Easy: $bronze\n"..
			"Normal: $silver\n"..
			"Hard: $gold",
		image = mod.resourcePath.."img/achievements/artificial.png",
		squad = squad,
	},

	pacifist = modApi.achievements:add{
		id = "pacifist",
		name = "A Light Touch",
		objective = {
			complete = true,
			easy = 0,
			normal = 0,
			hard = 0,
		},
		tooltip = "Beat the game having killed fewer than 20 enemies during your turns\n\n"..
			"$status"..
			"Easy: $bronze\n"..
			"Normal: $silver\n"..
			"Hard: $gold",
		image = mod.resourcePath.."img/achievements/pacifist.png",
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
		and GAME.lmn_Dune_Striders ~= nil
		and GAME.lmn_Dune_Striders.achievementData ~= nil
end

local function gameData()
	if GAME.lmn_Dune_Striders == nil then
		GAME.lmn_Dune_Striders = {}
	end

	if GAME.lmn_Dune_Striders.achievementData == nil then
		GAME.lmn_Dune_Striders.achievementData = {}
	end

	return GAME.lmn_Dune_Striders.achievementData
end

local difficultyIndices = {
	[DIFF_EASY] = "easy",
	[DIFF_NORMAL] = "normal",
	[DIFF_HARD] = "hard",
	default = "hard",
}

local COMPLETE = 1
local INCOMPLETE = 0

-- dust
local SMOKE_TILES = 2

local getTooltip = achievements.dust.getTooltip
achievements.dust.getTooltip = function(self)
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

modApi.events.onMissionEnd:subscribe(function(mission)
	local exit = false
		or isSquad() == false
		or isMissionBoard() == false

	if exit then
		return
	end

	local smoke_total = 0

	for _, p in ipairs(Board) do
		if Board:IsSmoke(p) then
			smoke_total = smoke_total + 1
		end
	end

	if smoke_total >= SMOKE_TILES then
		local difficulty = GetRealDifficulty()
		local objective = difficultyIndices[difficulty] or difficultyIndices.default

		if achievements.dust:getProgress()[objective] == INCOMPLETE then
			achievements.dust:addProgress{ [objective] = COMPLETE }
			achievements.dust:addProgress{ complete = false }
			achievements.dust:addProgress{ complete = true }
		end
	end
end)

-- artificial
local getTooltip = achievements.artificial.getTooltip
achievements.artificial.getTooltip = function(self)
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
		local failed = gameData().artificialFailed
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
	gameData().artificialFailed = false
end)

modApi.events.onMissionStart:subscribe(function(mission)
	local exit = false
		or isSquad() == false
		or isMissionBoard() == false
		or gameData().artificialFailed

	if exit then
		return
	end

	for pawnId = 0, 2 do
		local mech = Game:GetPawn(pawnId)
		if mech and mech:GetPilotName(1) ~= "A.I. Unit" then
			gameData().artificialFailed = true
		end
	end
end)

modApi.events.onGameVictory:subscribe(function(difficulty, islandsSecured, squad_id)
	local exit = false
		or isSquad() == false
		or gameData().artificialFailed

	if exit then
		return
	end

	local objective = difficultyIndices[difficulty] or difficultyIndices.default

	if achievements.artificial:getProgress()[objective] < islandsSecured then
		achievements.artificial:addProgress{ [objective] = islandsSecured }
		achievements.artificial:addProgress{ complete = false }
		achievements.artificial:addProgress{ complete = true }
	end
end)

-- pacifist
local PACIFIST_TARGET = 20
local EVENT_ENEMY_KILLED = 21
local EVENT_MINOR_ENEMY_KILLED = 12
local EVENT_PLAYER_TURN = 5

local getTooltip = achievements.pacifist.getTooltip
achievements.pacifist.getTooltip = function(self)
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
		local kills = gameData().pacifistKills
		local progress = kills.."/"..PACIFIST_TARGET
		local failed = kills < PACIFIST_TARGET and "" or " (failed)"

		status = "Kills: "..progress..failed.."\n\n"
	end

	result = result:gsub("%$status", status)
	result = result:gsub("%$bronze", bronze)
	result = result:gsub("%$silver", silver)
	result = result:gsub("%$gold", gold)

	return result
end

modApi.events.onPostStartGame:subscribe(function()
	gameData().pacifistKills = 0
end)

modApi.events.onMissionUpdate:subscribe(function(mission)
	local exit = false
		or isSquad() == false
		or isMission() == false
		or isGameData() == false
		or Game:GetEventCount(EVENT_PLAYER_TURN) == 0

	if exit then
		return
	end

	local gameData = gameData()

	gameData.pacifistKills = 0
		+ gameData.pacifistKills
		+ Game:GetEventCount(EVENT_ENEMY_KILLED)
		+ Game:GetEventCount(EVENT_MINOR_ENEMY_KILLED)
end)

modApi.events.onGameVictory:subscribe(function(difficulty, islandsSecured, squad_id)
	local exit = false
		or isSquad() == false
		or gameData().pacifistKills >= PACIFIST_TARGET

	if exit then
		return
	end

	local objective = difficultyIndices[difficulty] or difficultyIndices.default

	if achievements.pacifist:getProgress()[objective] < islandsSecured then
		achievements.pacifist:addProgress{ [objective] = islandsSecured }
		achievements.pacifist:addProgress{ complete = false }
		achievements.pacifist:addProgress{ complete = true }
	end
end)
