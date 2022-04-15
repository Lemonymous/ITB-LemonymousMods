
-- Requires:
-- 	modApiExt
-- 	eventifyModApiExtHooks


local VERSION = "1.0.0"
local EVENTS = {
	"onAttackStart",
	"onAttackResolved",
}

local attacking = false
local attacker = {}

local function getCurrentAttackInfo()
	if attacking then
		return shallow_copy(attacker)
	end
end

local function onSkillStart(mission, pawn, skillId, p1, p2)
	-- Track only real attacks
	if Board:IsTipImage() then
		return
	end

	if attacking == false then
		attacking = true
		attacker.mission = mission
		attacker.pawn = pawn
		attacker.pawnId = pawn:GetId()
		attacker.skillId = skillId
		attacker.p1 = p1
		attacker.p2 = p2

		-- Dispatch with the same arguments as onSkillStart
		modApi.events.onAttackStart:dispatch(mission, pawn, skillId, p1, p2)
	end
end

local function onMissionUpdate()
	if Board:GetBusyState() == 0 then
		if attacking then
			-- Dispatch with the same arguments as onSkillEnd
			modApi.events.onAttackResolved:dispatch(
				attacker.mission,
				attacker.pawn,
				attacker.skillId,
				attacker.p1,
				attacker.p2
			)
		end

		attacking = false
	end
end

local function onGameExited()
	attacking = false
end

local function initEvents()
	for _, eventId in ipairs(EVENTS) do
		if modApi.events[eventId] == nil then
			modApi.events[eventId] = Event()
		end
	end
end

local function finalizeInit(self)
	self.getCurrentAttackInfo = getCurrentAttackInfo

	modApi.events.onSkillStart:subscribe(onSkillStart)
	modApi.events.onMissionUpdate:subscribe(onMissionUpdate)
	modApi.events.onGameExited:subscribe(onGameExited)
end

local function onModsInitialized()
	local isHighestVersion = true
		and AttackEvents.initialized ~= true
		and AttackEvents.version == VERSION

	if isHighestVersion then
		AttackEvents:finalizeInit()
		AttackEvents.initialized = true
	end
end


local isNewerVersion = false
	or AttackEvents == nil
	or VERSION > AttackEvents.version

if isNewerVersion then
	AttackEvents = AttackEvents or {}
	AttackEvents.version = VERSION
	AttackEvents.finalizeInit = finalizeInit

	modApi.events.onModsInitialized:subscribe(onModsInitialized)

	initEvents()
end

return AttackEvents
