
local VERSION = "1.0.0"
local EVENTS = {
	"onSquadEnteredGame",
	"onSquadExitedGame",
}

local function onGameEntered()
	local squad = GAME.additionalSquadData
	local squadId = squad.squad

	if squadId ~= nil then
		modApi.events.onSquadEnteredGame:dispatch(squadId)
	end
end

local function onGameExited()
	local squad = GAME.additionalSquadData
	local squadId = squad.squad

	if squadId ~= nil then
		modApi.events.onSquadExitedGame:dispatch(squadId)
	end
end

local function initEvents()
	for _, eventId in ipairs(EVENTS) do
		if modApi.events[eventId] == nil then
			modApi.events[eventId] = Event()
		end
	end
end

local function finalizeInit(self)
	modApi.events.onGameEntered:subscribe(onGameEntered)
	modApi.events.onGameExited:subscribe(onGameExited)
end

local function onModsInitialized()
	local isHighestVersion = true
		and SquadEvents.initialized ~= true
		and SquadEvents.version == VERSION

	if isHighestVersion then
		SquadEvents:finalizeInit()
		SquadEvents.initialized = true
	end
end


local isNewerVersion = false
	or SquadEvents == nil
	or VERSION > SquadEvents.version

if isNewerVersion then
	SquadEvents = SquadEvents or {}
	SquadEvents.version = VERSION
	SquadEvents.finalizeInit = finalizeInit

	modApi.events.onModsInitialized:subscribe(onModsInitialized)

	initEvents()
end

return SquadEvents
