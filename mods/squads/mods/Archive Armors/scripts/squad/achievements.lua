
local mod = mod_loader.mods[modApi.currentMod]
local modApiExt = LApi.library:fetch("modApiExt/modApiExt", nil, "ITB-ModUtils")
local squad = "lmn_Archive_Armors"
local achievements = {
	collateral = modApi.achievements:add{
		id = "collateral",
		name = "Collateral Damage",
		objective = {
			complete = true,
			easy = 0,
			normal = 0,
			hard = 0,
		},
		tooltip = "End a battle with half of all buildings in ruins\n\n"..
			"Easy: $bronze\n"..
			"Normal: $silver\n"..
			"Hard: $gold",
		image = mod.resourcePath.."img/achievements/collateral.png",
		squad = squad,
	},

	surgical = modApi.achievements:add{
		id = "surgical",
		name = "Surgical Operation",
		objective = {
			complete = true,
			easy = 0,
			normal = 0,
			hard = 0,
		},
		tooltip = "Beat the game without losing any Grid Power\n\n"..
			"$status"..
			"Easy: $bronze\n"..
			"Normal: $silver\n"..
			"Hard: $gold",
		image = mod.resourcePath.."img/achievements/surgical.png",
		squad = squad,
	},

	scrappy = modApi.achievements:add{
		id = "scrappy",
		name = "Scrappy Victory",
		objective = {
			complete = true,
			easy = 0,
			normal = 0,
			hard = 0,
		},
		tooltip = "Beat the game with default un-upgraded weapons\n\n"..
			"$status"..
			"Easy: $bronze\n"..
			"Normal: $silver\n"..
			"Hard: $gold",
		image = mod.resourcePath.."img/achievements/scrappy.png",
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
		and GAME.lmn_Archive_Armors ~= nil
		and GAME.lmn_Archive_Armors.achievementData ~= nil
end

local function gameData()
	if GAME.lmn_Archive_Armors == nil then
		GAME.lmn_Archive_Armors = {}
	end

	if GAME.lmn_Archive_Armors.achievementData == nil then
		GAME.lmn_Archive_Armors.achievementData = {}
	end

	return GAME.lmn_Archive_Armors.achievementData
end

local difficultyIndices = {
	[DIFF_EASY] = "easy",
	[DIFF_NORMAL] = "normal",
	[DIFF_HARD] = "hard",
	default = "hard",
}

local COMPLETE = 1
local INCOMPLETE = 0

-- collateral
local getTooltip = achievements.collateral.getTooltip
achievements.collateral.getTooltip = function(self)
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

modApi.events.onMissionEnd:subscribe(function()
	local exit = false
		or isSquad() == false
		or isMissionBoard() == false

	if exit then
		return
	end

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

	local difficulty = GetRealDifficulty()
	local objective = difficultyIndices[difficulty] or difficultyIndices.default
	local achievementCompleted = true
		and ruins >= buildings
		and achievements.collateral:getProgress()[objective] == INCOMPLETE

	if achievementCompleted then
		achievements.collateral:addProgress{ [objective] = COMPLETE }
		achievements.collateral:addProgress{ complete = false }
		achievements.collateral:addProgress{ complete = true }
	end
end)

-- surgical
local EVENT_BUILDING_DAMAGED = 7

local getTooltip = achievements.surgical.getTooltip
achievements.surgical.getTooltip = function(self)
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
		local failed = gameData().surgicalFailed
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
	gameData().surgicalFailed = false
end)

modApi.events.onMissionUpdate:subscribe(function()
	local exit = false
		or isSquad() == false
		or isMission() == false
		or gameData().surgicalFailed

	if exit then
		return
	end

	if Game:GetEventCount(EVENT_BUILDING_DAMAGED) > 0 then
		gameData().surgicalFailed = true
	end
end)

modApi.events.onGameVictory:subscribe(function(difficulty, islandsSecured, squad_id)
	local exit = false
		or isSquad() == false
		or gameData().surgicalFailed

	if exit then
		return
	end

	local objective = difficultyIndices[difficulty] or difficultyIndices.default
	local chievo = achievements.surgical
	local progress = shallow_copy(chievo:getProgress())

	if progress[objective] < islandsSecured then
		progress.complete = true
		progress[objective] = islandsSecured
		chievo:addProgress{ complete = false }
		chievo:setProgress(progress)
	end
end)

-- scrappy
local defaultWeapons = {
	"lmn_DevastatorCannon",
	"lmn_Bombrun",
	"lmn_SmokeLauncher",
}

local getTooltip = achievements.scrappy.getTooltip
achievements.scrappy.getTooltip = function(self)
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
		local failed = gameData().scrappyFailed
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
	gameData().scrappyFailed = false
end)

modApi.events.onFrameDrawn:subscribe(function()
	local exit = false
		or isSquad() == false
		or isMission()
		or gameData().scrappyFailed

	if exit then
		return
	end

	for pawnId = 0, 2 do
		local mech = Game:GetPawn(pawnId)
		local weapons = mech:GetPoweredWeapons()

		for _, weaponId in pairs(weapons) do
			if not list_contains(defaultWeapons, weaponId) then
				gameData().scrappyFailed = true
			end
		end
	end
end)

modApi.events.onGameVictory:subscribe(function(difficulty, islandsSecured, squad_id)
	local exit = false
		or isSquad() == false
		or gameData().scrappyFailed

	if exit then
		return
	end

	local objective = difficultyIndices[difficulty] or difficultyIndices.default
	local chievo = achievements.scrappy
	local progress = shallow_copy(chievo:getProgress())

	if progress[objective] < islandsSecured then
		progress.complete = true
		progress[objective] = islandsSecured
		chievo:addProgress{ complete = false }
		chievo:setProgress(progress)
	end
end)
