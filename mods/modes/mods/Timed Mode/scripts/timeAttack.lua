
local mod = mod_loader.mods[modApi.currentMod]
local path = mod.scriptPath
local modUtils = require(path .."modApiExt/modApiExt")
local menu = require(path .."libs/menu")
local hooks = require(path .."libs/hooks")
local UiTimer = require(path .."ui/timer")
local Ui2 = require(path .."ui/Ui2")
local this = {}
local missionTime, turnTime
local uiHolder, uiTimer
local isDisabled, isPaused

sdlext.addUiRootCreatedHook(function(screen, uiRoot)
	uiHolder = Ui2():width(1):height(1):addTo(uiRoot)
	uiHolder.translucent = true
end)

hooks:new("TimerEnded")

local function endTurn()
	for _, id in ipairs(extract_table(Board:GetPawns(TEAM_PLAYER))) do
		local pawn = Board:GetPawn(id)
		if not pawn:IsNeutral() then
			pawn:SetActive(false)
			pawn:ClearUndoMove()
		end
	end
end

hooks:addTimerEndedHook(function()
	endTurn()
end)

local function destroyUi()
	if uiTimer then
		uiTimer:detach()
		uiTimer = nil
	end
	
	isPaused = true
end

local function createUi(time)
	destroyUi()
	
	uiTimer = UiTimer(time):addTo(uiHolder)
	
	isPaused = false
end

local function restore()
	destroyUi()
	
	modApi:runLater(function(m)
		if isDisabled or Game:GetTeamTurn() ~= TEAM_PLAYER then
			return 
		end
		
		m.lmn_timed_mode = m.lmn_timed_mode or {}
		
		-- only restore timer if timer is on.
		if m.lmn_timed_mode.timer then
			createUi(m.lmn_timed_mode.timer)
		end
	end)
end

sdlext.addGameExitedHook(destroyUi)

function this:load()
	local options = mod_loader.currentModContent[mod.id].options
	
	missionTime = options["option_timed_mode_mission_time"].value
	turnTime = options["option_timed_mode_turn_time"].value
	
	if type(missionTime) ~= 'number' and type(turnTime) ~= 'number' then
		isDisabled = true
	end
	
	missionTime = type(missionTime) == 'number' and missionTime or 0
	turnTime = type(turnTime) == 'number' and turnTime or 0
	
	missionTime = missionTime * 60
	turnTime = turnTime * 60
	
	modUtils:addResetTurnHook(restore)
	modUtils:addGameLoadedHook(restore)
	
	modApi:addMissionNextPhaseCreatedHook(destroyUi)
	modApi:addMissionEndHook(destroyUi)
	
	modApi:addMissionStartHook(function(m)
		if isDisabled then
			return
		end
		
		destroyUi()
		
		m.lmn_timed_mode = m.lmn_timed_mode or {}
		m.lmn_timed_mode.timer = missionTime
	end)
	
	modApi:addNextTurnHook(function(m)
		if isDisabled then
			return
		end
		
		if Game:GetTeamTurn() == TEAM_PLAYER then
			m.lmn_timed_mode = m.lmn_timed_mode or {}
			m.lmn_timed_mode.timer = m.lmn_timed_mode.timer or 0
			m.lmn_timed_mode.timer = m.lmn_timed_mode.timer + turnTime
			
			createUi(m.lmn_timed_mode.timer)
		else
			isPaused = true
		end
	end)
	
	modApi:addMissionUpdateHook(function(m)
		
		if isDisabled or isPaused or Game:GetTeamTurn() ~= TEAM_PLAYER then
			return
		end
		
		if not uiTimer or menu.isOpen() or Board:IsBusy()  then
			return
		end
		
		m.lmn_timed_mode = m.lmn_timed_mode or {}
		m.lmn_timed_mode.timer = m.lmn_timed_mode.timer or 0
		m.lmn_timed_mode.timer = math.max(0, m.lmn_timed_mode.timer - 1)
		
		if not uiTimer.ended and m.lmn_timed_mode.timer == 0 then
			uiTimer.ended = true
			hooks:fireTimerEndedHooks()
		end
	end)
end

return this