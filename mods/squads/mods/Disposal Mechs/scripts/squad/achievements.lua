
-- requires
--	achievementExt
--		difficultyEvents
--	personalSavedata
--	squadEvents
--	eventifyModApiExtHooks
--	attackEvents


-- defs
local CREATOR = "Lemonymous"
local SQUAD_DISPOSAL_MECHS = "Disposal_Mechs"
local TEAMWORK_TARGET = 5
local GARBAGE_TARGET = 7
local CLEANER_TARGET = 200


local mod = modApi:getCurrentMod()
local game_savedata = GAME_savedata(CREATOR, "Achievements", SQUAD_ARCHIVE_ARMORS)
local mission_savedata = Mission_savedata(CREATOR, "Achievements", SQUAD_ARCHIVE_ARMORS)


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


-- Achievement: Team Spirit
mission_savedata.teamwork_moves = 0
local teamwork_mechLocations = {}
local teamwork = modApi.achievements:addExt{
	id = "teamwork",
	name = "Team Spirit",
	tooltip = "Move allied mechs with attacks 5 times in a single battle.",
	textDiffComplete = "$highscore times",
	image = mod.resourcePath.."img/achievements/teamwork.png",
	squad = SQUAD_DISPOSAL_MECHS,
}

function teamwork:getTextProgress()
	if isRealMission() then
		return mission_savedata.teamwork_moves.." times"
	end
end

local function teamwork_onAttackStart(mission, pawn, weaponId, p1, p2)
	local pawnId = pawn:GetId()
	local mechs = Board:GetPawns(TEAM_MECH)
	clear_table(teamwork_mechLocations)

	for i = 1, mechs:size() do
		local mechId = mechs:index(i)
		local mech = Board:GetPawn(mechId)

		if mechId ~= pawnId then
			teamwork_mechLocations[mechId] = mech:GetSpace()
		end
	end
end

local function teamwork_onAttackResolved(mission, pawn, weaponId, p1, p2)
	if isNotRealMission() or pawn:IsEnemy() then
		return
	end

	for mechId, loc in pairs(teamwork_mechLocations) do
		local mech = Board:GetPawn(mechId)

		if mech and mech:GetSpace() ~= loc then
			mission_savedata.teamwork_moves = mission_savedata.teamwork_moves + 1
		end
	end
end

local function teamwork_onMissionEnd(mission)
	if mission_savedata.teamwork_moves >= TEAMWORK_TARGET then
		teamwork:completeWithHighscore(mission_savedata.teamwork_moves)
	end
end


-- Achievement: Garbage Day
mission_savedata.garbage_kills = 0
local garbage = modApi.achievements:addExt{
	id = "garbage",
	name = "Garbage Day",
	tooltip = "Kill 7 enemies inflicted with A.C.I.D. in a single battle.",
	textDiffComplete = "$highscore kills",
	image = mod.resourcePath.."img/achievements/garbage.png",
	squad = SQUAD_DISPOSAL_MECHS,
}

function garbage:getTextProgress()
	if isRealMission() then
		return mission_savedata.garbage_kills.." kills"
	end
end

local function garbage_onPawnKilled(mission, pawn)
	if isRealMission() and pawn:IsEnemy() and pawn:IsAcid() then
		mission_savedata.garbage_kills = mission_savedata.garbage_kills + 1
	end
end

local function garbage_onMissionEnd(mission)
	if isNotRealMission() then
		return
	end

	if mission_savedata.garbage_kills >= GARBAGE_TARGET then
		garbage:completeWithHighscore(mission_savedata.garbage_kills)
	end
end


-- Achievement: Expert Cleaner
game_savedata.cleaner_kills = 0
local cleaner = modApi.achievements:addExt{
	id = "cleaner",
	name = "Expert Cleaner",
	tooltip = "Beat the game with at least 200 kills.",
	textDiffComplete = "$highscore kills",
	retoastHighscore = true,
	image = mod.resourcePath.."img/achievements/cleaner.png",
	squad = SQUAD_DISPOSAL_MECHS,
}

function cleaner:getTextProgress()
	if isGame() then
		return game_savedata.cleaner_kills.." kills"
	end
end

local function cleaner_onPawnKilled(mission, pawn)
	if isRealMission() and pawn:IsEnemy() then
		game_savedata.cleaner_kills = game_savedata.cleaner_kills + 1
	end
end

local function cleaner_onGameVictory(difficulty, islandsSecured, squad_id)
	if game_savedata.cleaner_kills > CLEANER_TARGET then
		cleaner:completeWithHighscore(game_savedata.cleaner_kills)
	end
end


-- Subscribe to events
modApi.events.onSquadEnteredGame:subscribe(function(squadId)
	if squadId == SQUAD_DISPOSAL_MECHS then
		modApi.events.onAttackStart:subscribe(teamwork_onAttackStart)
		modApi.events.onAttackResolved:subscribe(teamwork_onAttackResolved)
		modApi.events.onMissionEnd:subscribe(teamwork_onMissionEnd)

		modApi.events.onPawnKilled:subscribe(garbage_onPawnKilled)
		modApi.events.onMissionEnd:subscribe(garbage_onMissionEnd)

		modApi.events.onPawnKilled:subscribe(cleaner_onPawnKilled)
		modApi.events.onGameVictory:subscribe(cleaner_onGameVictory)
	end
end)

-- Unsubscribe from events
modApi.events.onSquadExitedGame:subscribe(function(squadId)
	if squadId == SQUAD_DISPOSAL_MECHS then
		modApi.events.onAttackStart:unsubscribe(teamwork_onAttackStart)
		modApi.events.onAttackResolved:unsubscribe(teamwork_onAttackResolved)
		modApi.events.onMissionEnd:unsubscribe(teamwork_onMissionEnd)

		modApi.events.onPawnKilled:unsubscribe(garbage_onPawnKilled)
		modApi.events.onMissionEnd:unsubscribe(garbage_onMissionEnd)

		modApi.events.onPawnKilled:unsubscribe(cleaner_onPawnKilled)
		modApi.events.onGameVictory:unsubscribe(cleaner_onGameVictory)
	end
end)
