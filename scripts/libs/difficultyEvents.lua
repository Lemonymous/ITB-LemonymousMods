
local VERSION = "1.0.0"
local EVENTS = {
	"onRealDifficultyChanged",
	"onDifficultyChanged",
}

local difficulty
local realDifficulty

local function onFrameDrawStart()
	local prev_difficulty = difficulty
	local prev_realDifficulty = realDifficulty

	difficulty = GetDifficulty()
	realDifficulty = GetRealDifficulty()

	if difficulty ~= prev_difficulty then
		modApi.events.onDifficultyChanged:dispatch(difficulty, prev_difficulty)
	end

	if realDifficulty ~= prev_realDifficulty then
		modApi.events.onRealDifficultyChanged:dispatch(realDifficulty, prev_realDifficulty)
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
	modApi.events.onFrameDrawStart:subscribe(onFrameDrawStart)
end

local function onModsInitialized()
	local isHighestVersion = true
		and DifficultyEvents.initialized ~= true
		and DifficultyEvents.version == VERSION

	if isHighestVersion then
		DifficultyEvents:finalizeInit()
		DifficultyEvents.initialized = true
	end
end


local isNewerVersion = false
	or DifficultyEvents == nil
	or VERSION > DifficultyEvents.version

if isNewerVersion then
	DifficultyEvents = DifficultyEvents or {}
	DifficultyEvents.version = VERSION
	DifficultyEvents.finalizeInit = finalizeInit

	modApi.events.onModsInitialized:subscribe(onModsInitialized)

	initEvents()
end

return DifficultyEvents
