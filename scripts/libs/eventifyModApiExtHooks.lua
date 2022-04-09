
local modApiExt = LApi.library:fetch("modApiExt/modApiExt", nil, "ITB-ModUtils")

local VERSION = "1.0.0"
local EVENTS = {
	"ResetTurn",
	"GameLoaded",
	-- "TileHighlighted", -- LApi event is more accurate
	-- "TileUnhighlighted", -- LApi event is more accurate
	"PawnTracked",
	"PawnUntracked",
	"PawnPositionChanged",
	"PawnUndoMove",
	-- "PawnSelected", -- mod loader event already defined
	"PawnDeslected",
	"PawnDamaged",
	"PawnHealed",
	"PawnKilled",
	"PawnRevived",
	"PawnIsFire",
	"PawnIsAcid",
	"PawnIsFrozen",
	"PawnIsGrappled",
	"PawnIsShielded",
	"VekMoveStart",
	"VekMoveEnd",
	"BuildingDestroyed",
	"SkillStart",
	"SkillEnd",
	"QueuedSkillStart",
	"QueuedSkillEnd",
	"SkillBuild",
	-- "TipImageShown", -- mod loader event already defined
	-- "TipImageHidden", -- mod loader event already defined
	"PodDetected",
	"PodLanded",
	"PodTrampled",
	"PodDestroyed",
	"PodCollected",
	"MostRecentResolved",
}

local function createHooks(self)
	self.handlers = {}

	for _, event in ipairs(EVENTS) do
		local eventId = "on"..event
		self.handlers[eventId] = function(...)
			modApi.events[eventId]:dispatch(...)
		end
	end
end

local function addModApiExtHooks()
	for _, event in ipairs(EVENTS) do
		local eventId = "on"..event
		local hookId = "add"..event.."Hook"
		local addHook = modApiExt[hookId]
		local handler = EventifyModApiExtHooks.handlers[eventId]

		if addHook and handler then
			addHook(modApiExt, handler)
		end
	end
end

local function initEvents()
	for _, event in ipairs(EVENTS) do
		eventId = "on"..event
		if modApi.events[eventId] == nil then
			modApi.events[eventId] = Event()
		end
	end
end

local function finalizeInit(self)
	createHooks(self)
	modApi.events.onModsLoaded:subscribe(addModApiExtHooks)
end

local function onModsInitialized()
	local isHighestVersion = true
		and EventifyModApiExtHooks.initialized ~= true
		and EventifyModApiExtHooks.version == VERSION

	if isHighestVersion then
		EventifyModApiExtHooks:finalizeInit()
		EventifyModApiExtHooks.initialized = true
	end
end


local isNewerVersion = false
	or EventifyModApiExtHooks == nil
	or VERSION > EventifyModApiExtHooks.version

if isNewerVersion then
	EventifyModApiExtHooks = EventifyModApiExtHooks or {}
	EventifyModApiExtHooks.version = VERSION
	EventifyModApiExtHooks.finalizeInit = finalizeInit

	modApi.events.onModsInitialized:subscribe(onModsInitialized)

	initEvents()
end

return EventifyModApiExtHooks
