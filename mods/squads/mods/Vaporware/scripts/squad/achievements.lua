
-- requires
--	achievementExt
--		difficultyEvents
--	personalSavedata
--	squadEvents
--	eventifyModApiExtHooks
--	attackEvents


-- defs
local CREATOR = "Lemonymous"
local SQUAD_VAPORWARE = "vaporware"
local CANCELED_TARGET = 30
local DOCILE_TARGET = 3
local BUMPING_TARGET = 2


local mod = modApi:getCurrentMod()
local game_savedata = GAME_savedata(CREATOR, SQUAD_VAPORWARE, "Achievements")
local mission_savedata_attacked = Mission_savedata(CREATOR, SQUAD_VAPORWARE, "Achievements", "attacked")


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


-- Achievement: Canceled!
game_savedata.canceled_attacks = 0
local queued = {}
local canceled = modApi.achievements:addExt{
	id = "canceled",
	name = "Canceled!",
	tooltip = "Cancel "..CANCELED_TARGET.." attacks on a single Island.",
	textDiffComplete = "$highscore attacks canceled",
	retoastHighscore = true,
	image = mod.resourcePath.."img/achievements/canceled.png",
	squad = SQUAD_VAPORWARE,
}

function canceled:getTextProgress()
	if isGame() then
		return game_savedata.canceled_attacks.." attacks canceled"
	end
end

local function canceled_onQueuedAttackCanceled(pawn, origin, target, queuedShot, queuedSkill)
	if isNotRealMission() or pawn:IsEnemy() == false then
		return
	end

	game_savedata.canceled_attacks = game_savedata.canceled_attacks + 1
end

local function canceled_onGameStateChanged(currentState, oldState)
	if oldState == GAME_STATE_MAP and currentState == GAME_STATE_ISLAND then
		game_savedata.canceled_attacks = 0

	elseif oldState == GAME_STATE_ISLAND and currentState == GAME_STATE_MAP then
		if game_savedata.canceled_attacks >= CANCELED_TARGET then
			canceled:completeWithHighscore(game_savedata.canceled_attacks)
		end
		game_savedata.canceled_attacks = 0
	end
end


-- Achievement: Docile Opposition
local docile = modApi.achievements:addExt{
	id = "docile_opposition",
	name = "Docile Opposition",
	tooltip = "Start a turn where at least "..DOCILE_TARGET.." non-frozen enemies, withheld their attack.",
	textDiffComplete = "$highscore docile enemies",
	retoastHighscore = true,
	image = mod.resourcePath.."img/achievements/docile_opposition.png",
	squad = SQUAD_VAPORWARE,
}

local function nonfrozenEnemyWithheldAttack(enemyId)
	local enemy = Board:GetPawn(enemyId)

	return true
		and enemy:IsFrozen() == false
		and #enemy:GetPoweredWeapons() > 0
		and enemy:GetQueuedWeapon() == nil
		and mission_savedata_attacked[enemyId] ~= true
end

local function docile_onMissionStart()
	if isNotRealMission() then
		return
	end

	clear_table(mission_savedata_attacked)
end

local function docile_onNextTurn()
	if isNotRealMission() then
		return
	end

	if Game:GetTeamTurn() == TEAM_ENEMY then
		clear_table(mission_savedata_attacked)
	else
		local enemies = Board:GetPawns(TEAM_ENEMY)
		local enemyCount = enemies:size()
		local enemiesWithheldAttack = 0

		for i = 1, enemyCount do
			local enemyId = enemies:index(i)

			if nonfrozenEnemyWithheldAttack(enemyId) then
				enemiesWithheldAttack = enemiesWithheldAttack + 1
			end
		end

		if enemiesWithheldAttack >= DOCILE_TARGET then
			docile:completeWithHighscore(enemiesWithheldAttack)
		end
	end
end

local function docile_onEnemyAttackStart(mission, pawn, weaponId, p1, p2)
	if isNotRealMission() then
		return
	end

	mission_savedata_attacked[pawn:GetId()] = true
end


-- Achievement: Bumping Heads
local bumping_kills = 0
local bumping = modApi.achievements:addExt{
	id = "bumping_heads",
	name = "Bumping Heads",
	tooltip = "Kill "..BUMPING_TARGET.." enemies in a single Vortex.",
	textDiffComplete = "$highscore kills",
	retoastHighscore = true,
	image = mod.resourcePath.."img/achievements/bumping_heads.png",
	squad = SQUAD_VAPORWARE,
}

local function isVortexGenerator(weaponId)
	return false
		or weaponId == "vw_Vortex_Generator"
		or weaponId == "vw_Vortex_Generator_A"
		or weaponId == "vw_Vortex_Generator_B"
		or weaponId == "vw_Vortex_Generator_AB"
end

local function isNotVortexGenerator(weaponId)
	return not isVortexGenerator(weaponId)
end

local function bumping_onPawnKilled(mission, pawn)
	if isRealMission() and pawn:IsEnemy() then
		bumping_kills = bumping_kills + 1
	end
end

local function bumping_onAllyAttackStart(mission, pawn, weaponId, p1, p2)
	if isNotRealMission() or isNotVortexGenerator(weaponId) then
		return
	end

	bumping_kills = 0
end

local function bumping_onAllyAttackResolved(mission, pawn, weaponId, p1, p2)
	if isNotRealMission() or isNotVortexGenerator(weaponId) then
		return
	end

	if bumping_kills >= BUMPING_TARGET then
		bumping:completeWithHighscore(bumping_kills)
	end
end


-- Subscribe to events
modApi.events.onSquadEnteredGame:subscribe(function(squadId)
	if squadId == SQUAD_VAPORWARE then
		modApi.events.onQueuedAttackCanceled:subscribe(canceled_onQueuedAttackCanceled)
		modApi.events.onGameStateChanged:subscribe(canceled_onGameStateChanged)

		modApi.events.onMissionStart:subscribe(docile_onMissionStart)
		modApi.events.onNextTurn:subscribe(docile_onNextTurn)
		modApi.events.onEnemyAttackStart:subscribe(docile_onEnemyAttackStart)

		modApi.events.onPawnKilled:subscribe(bumping_onPawnKilled)
		modApi.events.onAllyAttackStart:subscribe(bumping_onAllyAttackStart)
		modApi.events.onAllyAttackResolved:subscribe(bumping_onAllyAttackResolved)
	end
end)


-- Unsubscribe from events
modApi.events.onSquadExitedGame:subscribe(function(squadId)
	if squadId == SQUAD_VAPORWARE then
		modApi.events.onQueuedAttackCanceled:unsubscribe(canceled_onQueuedAttackCanceled)
		modApi.events.onGameStateChanged:unsubscribe(canceled_onGameStateChanged)

		modApi.events.onMissionStart:unsubscribe(docile_onMissionStart)
		modApi.events.onNextTurn:unsubscribe(docile_onNextTurn)
		modApi.events.onEnemyAttackStart:unsubscribe(docile_onEnemyAttackStart)

		modApi.events.onPawnKilled:unsubscribe(bumping_onPawnKilled)
		modApi.events.onAllyAttackStart:unsubscribe(bumping_onAllyAttackStart)
		modApi.events.onAllyAttackResolved:unsubscribe(bumping_onAllyAttackResolved)
	end
end)
