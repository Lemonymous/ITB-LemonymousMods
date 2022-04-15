
-- requires
--	LApi
--	achievementExt
--		difficultyEvents
--	personalSavedata
--	squadEvents


-- defs
local CREATOR = "Lemonymous"
local SQUAD_ARCHIVE_ARMORS = "Archive_Armors"
local EVENT_BUILDING_DAMAGED = 7
local DEFAULT_WEAPONS = {
	"lmn_DevastatorCannon",
	"lmn_Bombrun",
	"lmn_SmokeLauncher",
}


local mod = modApi:getCurrentMod()
local game_savedata = GAME_savedata(CREATOR, SQUAD_ARCHIVE_ARMORS, "Achievements")


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

local function failAchievement(achievementId)
	game_savedata[achievementId.."_failed"] = true
end

local function isAchievementFailed(achievementId)
	return game_savedata[achievementId.."_failed"]
end

local function isDefaultWeapon(weaponId)
	return list_contains(DEFAULT_WEAPONS, weaponId)
end


-- Achievement: Collateral Damage
local collateral = modApi.achievements:addExt{
	id = "collateral",
	name = "Collateral Damage",
	tooltip = "End a battle with half of all buildings in ruins.",
	image = mod.resourcePath.."img/achievements/collateral.png",
	squad = SQUAD_ARCHIVE_ARMORS,
}

local function getBuildingAndRuinCount()
	local cutils = LApi.cutils:get()
	local buildings = 0
	local ruins = 0

	for _, p in ipairs(Board) do
		local iTerrain = Board:GetTerrain(p)
		local health = Board:GetHealth(p)

		if iTerrain == TERRAIN_BUILDING then
			buildings = buildings + 1
		elseif iTerrain == TERRAIN_RUBBLE and cutils.Board.GetRubbleType(p) == RUBBLE_BUILDING then
			ruins = ruins + 1
		end
	end

	return buildings, ruins
end

function collateral:getTextProgress()
	if isNotRealMission() then
		return
	end

	local buildings, ruins = getBuildingAndRuinCount()
	return string.format("%s of %s buildings are in ruins", ruins, buildings + ruins)
end

local function collateral_onMissionEnd()
	if isNotRealMission() then
		return
	end

	local buildings, ruins = getBuildingAndRuinCount()
	if ruins >= buildings then
		collateral:completeProgress()
	end
end


-- Achievement: Surgical Operation
game_savedata.surgical_failed = false
local surgical = modApi.achievements:addExt{
	id = "surgical",
	name = "Surgical Operation",
	tooltip = "Beat the game without losing any Grid Power.",
	textDiffComplete = "$highscore islands",
	textFailed = "Took Grid damage",
	retoastHighscore = true,
	image = mod.resourcePath.."img/achievements/surgical.png",
	squad = SQUAD_ARCHIVE_ARMORS,
}

function surgical:isFailed()
	return isAchievementFailed("surgical")
end

local function surgical_onMissionUpdate(mission)
	if isRealMission() and Game:GetEventCount(EVENT_BUILDING_DAMAGED) > 0 then
		failAchievement("surgical")
	end
end

local function surgical_onGameVictory(difficultyId, islandsSecured, squadId)
	if surgical:isNotFailed() then
		surgical:completeWithHighscore(islandsSecured)
	end
end


-- Achievement: Scrappy Victory
game_savedata.scrappy_failed = false
local scrappy = modApi.achievements:addExt{
	id = "scrappy",
	name = "Scrappy Victory",
	tooltip = "Beat the game with default un-upgraded weapons.",
	textDiffComplete = "$highscore islands",
	textFailed = "Modified equipment",
	retoastHighscore = true,
	image = mod.resourcePath.."img/achievements/scrappy.png",
	squad = SQUAD_ARCHIVE_ARMORS,
}

function scrappy:isFailed()
	return isAchievementFailed("scrappy")
end

local function scrappy_onMissionStart()
	if isNotRealMission() then
		return
	end

	for pawnId = 0, 2 do
		local mech = Game:GetPawn(pawnId)
		if mech then
			local weapons = mech:GetPoweredWeapons()

			for _, weaponId in pairs(weapons) do
				if not isDefaultWeapon(weaponId) then
					failAchievement("scrappy")
				end
			end
		end
	end
end

local function scrappy_onGameVictory(difficultyId, islandsSecured, squadId)
	if scrappy:isNotFailed() then
		scrappy:completeWithHighscore(islandsSecured)
	end
end


-- Subscribe to events
modApi.events.onSquadEnteredGame:subscribe(function(squadId)
	if squadId == SQUAD_ARCHIVE_ARMORS then
		modApi.events.onMissionEnd:subscribe(collateral_onMissionEnd)

		modApi.events.onMissionUpdate:subscribe(surgical_onMissionUpdate)
		modApi.events.onGameVictory:subscribe(surgical_onGameVictory)

		modApi.events.onMissionStart:subscribe(scrappy_onMissionStart)
		modApi.events.onGameVictory:subscribe(scrappy_onGameVictory)
	end
end)

-- Unsubscribe from events
modApi.events.onSquadExitedGame:subscribe(function(squadId)
	if squadId == SQUAD_ARCHIVE_ARMORS then
		modApi.events.onMissionEnd:unsubscribe(collateral_onMissionEnd)

		modApi.events.onMissionUpdate:unsubscribe(surgical_onMissionUpdate)
		modApi.events.onGameVictory:unsubscribe(surgical_onGameVictory)

		modApi.events.onMissionStart:unsubscribe(scrappy_onMissionStart)
		modApi.events.onGameVictory:unsubscribe(scrappy_onGameVictory)
	end
end)
