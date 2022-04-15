
-- requires
--	achievementExt
--		difficultyEvents
--	personalSavedata
--	squadEvents
--	eventifyModApiExtHooks
--	attackEvents


-- defs
local CREATOR = "Lemonymous"
local SQUAD_DUNE_STRIDERS = "Dune_Striders"
local DUST_TARGET = 14
local PACIFIST_TARGET = 20


local mod = modApi:getCurrentMod()
local game_savedata = GAME_savedata(CREATOR, SQUAD_DUNE_STRIDERS, "Achievements")


-- Helper functions
local function isRealMission()
	local mission = GetCurrentMission()

	return true
		and mission ~= nil
		and mission ~= Mission_Test
		and Board
		and Board:IsGameBoard()
end

local function isNotRealMission()
	return not isRealMission()
end

local function isGame()
	return Game ~= nil
end

local function isPlayerInitiatedAttack()
	local attackInfo = AttackEvents:getCurrentAttackInfo()
	if attackInfo == nil then
		return false
	end

	return attackInfo.pawn:GetTeam() == TEAM_PLAYER
end

local function failAchievement(achievementId)
	game_savedata[achievementId.."_failed"] = true
end

local function isAchievementFailed(achievementId)
	return game_savedata[achievementId.."_failed"]
end


-- Achievement: Dust Storm
local dust = modApi.achievements:addExt{
	id = "dust",
	name = "Dust Storm",
	tooltip = "End a battle with 14 tiles covered in smoke.",
	textDiffComplete = "$highscore smoke tiles",
	retoastHighscore = true,
	image = mod.resourcePath.."img/achievements/dust.png",
	squad = SQUAD_DUNE_STRIDERS,
}

local function getSmokeTileCount()
	local smokeTileCount = 0

	for _, p in ipairs(Board) do
		if Board:IsSmoke(p) then
			smokeTileCount = smokeTileCount + 1
		end
	end

	return smokeTileCount
end

function dust:getTextProgress()
	if isRealMission() then
		return getSmokeTileCount().." smoke tiles"
	end
end

local function dust_onMissionEnd(mission)
	if isNotRealMission() then
		return
	end

	local smokeTileCount = getSmokeTileCount()
	if smokeTileCount >= DUST_TARGET then
		dust:completeWithHighscore(smokeTileCount)
	end
end


-- Achievement: Artificial
game_savedata.artificial_failed = false
local artificial = modApi.achievements:addExt{
	id = "artificial",
	name = "Artificial Victory",
	tooltip = "Beat the game with only AI pilots.",
	textFailed = "non-AI pilot used",
	textDiffComplete = "$highscore islands",
	image = mod.resourcePath.."img/achievements/artificial.png",
	squad = SQUAD_DUNE_STRIDERS,
}

function artificial:isFailed()
	return isAchievementFailed("artificial")
end

local function artificial_onMissionStart(mission)
	if isNotRealMission() then
		return
	end

	for pawnId = 0, 2 do
		local mech = Game:GetPawn(pawnId)
		if mech and mech:GetPilotName(1) ~= "A.I. Unit" then
			failAchievement("artificial")
		end
	end
end

local function artificial_onGameVictory(difficulty, islandsSecured, squad_id)
	if artificial:isNotFailed() then
		artificial:completeWithHighscore(islandsSecured)
	end
end


-- Achievement: A Light Touch
game_savedata.pacifist_kills = 0
local pacifist = modApi.achievements:addExt{
	id = "pacifist",
	name = "A Light Touch",
	tooltip = "Beat the game having killed fewer than 20 enemies during your turns.",
	textDiffComplete = "$highscore islands",
	retoastHighscore = true,
	image = mod.resourcePath.."img/achievements/pacifist.png",
	squad = SQUAD_DUNE_STRIDERS,
}

function pacifist:isFailed()
	return game_savedata.pacifist_kills >= PACIFIST_TARGET
end

function pacifist:getTextFailed()
	return string.format("Killed %s enemies", game_savedata.pacifist_kills)
end

function pacifist:getTextProgress()
	if isGame() then
		return game_savedata.pacifist_kills.." player kills"
	end
end

local function pacifist_onPawnKilled(mission, pawn)
	if isNotRealMission() then
		return
	end

	if isPlayerInitiatedAttack() and pawn:IsEnemy() then
		game_savedata.pacifist_kills = game_savedata.pacifist_kills + 1
	end
end

local function pacifist_onPawnKilled(mission, pawn)
	if true
		and isRealMission()
		and isPlayerInitiatedAttack()
		and pawn:IsEnemy()
	then
		game_savedata.pacifist_kills = game_savedata.pacifist_kills + 1
	end
end

local function pacifist_onGameVictory(difficulty, islandsSecured, squad_id)
	if pacifist:isNotFailed() then
		pacifist:completeWithHighscore(islandsSecured)
	end
end


-- Subscribe to events
modApi.events.onSquadEnteredGame:subscribe(function(squadId)
	if squadId == SQUAD_DUNE_STRIDERS then
		modApi.events.onMissionEnd:subscribe(dust_onMissionEnd)

		modApi.events.onMissionStart:subscribe(artificial_onMissionStart)
		modApi.events.onGameVictory:subscribe(artificial_onGameVictory)

		modApi.events.onPawnKilled:subscribe(pacifist_onPawnKilled)
		modApi.events.onGameVictory:subscribe(pacifist_onGameVictory)
	end
end)

-- Unsubscribe from events
modApi.events.onSquadExitedGame:subscribe(function(squadId)
	if squadId == SQUAD_DUNE_STRIDERS then
		modApi.events.onMissionEnd:unsubscribe(dust_onMissionEnd)

		modApi.events.onMissionStart:unsubscribe(artificial_onMissionStart)
		modApi.events.onGameVictory:unsubscribe(artificial_onGameVictory)

		modApi.events.onPawnKilled:unsubscribe(pacifist_onPawnKilled)
		modApi.events.onGameVictory:unsubscribe(pacifist_onGameVictory)
	end
end)
