
-- requires
--	achievementExt
--		difficultyEvents
--	personalSavedata
--	squadEvents
--	eventifyModApiExtHooks
--	attackEvents


-- defs
local CREATOR = "Lemonymous"
local SQUAD_RF1995 = "RF1995"
local EVENT_MECH_DAMAGED = 24
local EVENT_POD_DESTROYED = 37


local mod = modApi:getCurrentMod()
local game_savedata = GAME_savedata(CREATOR, SQUAD_RF1995, "Achievements")


-- Helper functions
local function isRealMission()
	local mission = GetCurrentMission()

	return true
		and mission ~= nil
		and mission ~= Mission_Test
		and Board
		and Board:IsMissionBoard()
end

local function isNotRealMission()
	return not isRealMission()
end

local function isGame()
	return Game ~= nil
end

local function failAchievement(achievementId)
	game_savedata[achievementId.."_failed"] = true
end

local function isAchievementFailed(achievementId)
	return game_savedata[achievementId.."_failed"]
end


-- Achievement: Mo-mo-mo-monster Kill!
local monsterkill_kills = 0
local monsterkill = modApi.achievements:addExt{
	id = "monsterkill",
	name = "Mo-mo-mo-monster Kill!",
	tooltip = "Kill 3 enemies with a single attack.",
	textDiffComplete = "$highscore kills",
	image = mod.resourcePath.."img/achievements/monsterkill.png",
	squad = SQUAD_RF1995,
}

local function monsterkill_onPawnKilled(mission, pawn)
	if isRealMission() and pawn:IsEnemy() then
		monsterkill_kills = monsterkill_kills + 1
	end
end

local function monsterkill_onAttackStart(mission, pawn, weaponId, p1, p2)
	monsterkill_kills = 0
end

local function monsterkill_onAttackResolved(mission, pawn, weaponId, p1, p2)
	if isNotRealMission() or pawn:IsEnemy() then
		return
	end

	if monsterkill_kills >= 3 then
		monsterkill:completeWithHighscore(monsterkill_kills)
	end
end


-- Achievement: Can't Touch This
game_savedata.untouchable_failed = false
local untouchable = modApi.achievements:addExt{
	id = "untouchable",
	name = "Can't Touch This",
	tooltip = "Beat the game without taking any Mech damage.",
	textDiffComplete = "$highscore islands",
	textFailed = "Took Mech damage",
	retoastHighscore = true,
	image = mod.resourcePath.."img/achievements/untouchable.png",
	squad = SQUAD_RF1995,
}

function untouchable:isFailed()
	return isAchievementFailed("untouchable")
end

local function untouchable_onMissionUpdate(mission)
	if isRealMission() and Game:GetEventCount(EVENT_MECH_DAMAGED) > 0 then
		failAchievement("untouchable")
	end
end

local function untouchable_onGameVictory(difficultyId, islandsSecured, squadId)
	if untouchable:isNotFailed() then
		untouchable:completeWithHighscore(islandsSecured)
	end
end


-- Achievement: Eye on the Price
game_savedata.eyeontheprice_failed = false
local eyeontheprice = modApi.achievements:addExt{
	id = "eyeontheprice",
	name = "Eye on the Prize",
	tooltip = "Beat the game without failing an objective.",
	textDiffComplete = "$highscore islands",
	textFailed = "Objective failed",
	retoastHighscore = true,
	image = mod.resourcePath.."img/achievements/objective.png",
	squad = SQUAD_RF1995,
}

function eyeontheprice:isFailed()
	return isAchievementFailed("eyeontheprice")
end

local function eyeontheprice_onMissionUpdate()
	if isRealMission() and Game:GetEventCount(EVENT_POD_DESTROYED) > 0 then
		failAchievement("eyeontheprice")
	end
end

local function eyeontheprice_onMissionEnd(mission)
	if isNotRealMission() then
		return
	end

	local objectives = mission:BaseCompletedObjectives()

	for _, obj in ipairs(objectives) do
		if obj.rep < obj.potential then
			failAchievement("eyeontheprice")
		end
	end
end

local function eyeontheprice_onGameVictory(difficultyId, islandsSecured, squadId)
	if eyeontheprice:isNotFailed() then
		eyeontheprice:completeWithHighscore(islandsSecured)
	end
end


-- Subscribe to events
modApi.events.onSquadEnteredGame:subscribe(function(squadId)
	if squadId == SQUAD_RF1995 then
		AttackEvents.onAttackStart:subscribe(monsterkill_onAttackStart)
		AttackEvents.onAttackResolved:subscribe(monsterkill_onAttackResolved)
		modApiExt.events.onPawnKilled:subscribe(monsterkill_onPawnKilled)

		modApi.events.onMissionUpdate:subscribe(untouchable_onMissionUpdate)
		modApi.events.onGameVictory:subscribe(untouchable_onGameVictory)

		modApi.events.onMissionUpdate:subscribe(eyeontheprice_onMissionUpdate)
		modApi.events.onMissionEnd:subscribe(eyeontheprice_onMissionEnd)
		modApi.events.onGameVictory:subscribe(eyeontheprice_onGameVictory)
	end
end)

-- Unsubscribe from events
modApi.events.onSquadExitedGame:subscribe(function(squadId)
	if squadId == SQUAD_RF1995 then
		AttackEvents.onAttackStart:unsubscribe(monsterkill_onAttackStart)
		AttackEvents.onAttackResolved:unsubscribe(monsterkill_onAttackResolved)
		modApiExt.events.onPawnKilled:unsubscribe(monsterkill_onPawnKilled)

		modApi.events.onMissionUpdate:unsubscribe(untouchable_onMissionUpdate)
		modApi.events.onGameVictory:unsubscribe(untouchable_onGameVictory)

		modApi.events.onMissionUpdate:unsubscribe(eyeontheprice_onMissionUpdate)
		modApi.events.onMissionEnd:unsubscribe(eyeontheprice_onMissionEnd)
		modApi.events.onGameVictory:unsubscribe(eyeontheprice_onGameVictory)
	end
end)
