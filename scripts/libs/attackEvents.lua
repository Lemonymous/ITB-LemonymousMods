
-- Requires:
-- 	modApiExt
-- 	eventifyModApiExtHooks


local VERSION = "1.1.0"
local EVENTS = {
	"onAllyAttackResolved",
	"onAllyAttackStart",
	"onAttackResolved",
	"onAttackStart",
	"onEnemyAttackResolved",
	"onEnemyAttackStart",
	"onQueuedAttackCanceled",
	"onQueuedAttackInitiated",
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

		if pawn:IsEnemy() then
			modApi.events.onEnemyAttackStart:dispatch(mission, pawn, skillId, p1, p2)
		else
			modApi.events.onAllyAttackStart:dispatch(mission, pawn, skillId, p1, p2)
		end
	end
end

local function isQueued(queuedAttack)
	if queuedAttack == nil or queuedAttack.piQueuedShot == nil then
		return false
	end

	return true
		and Board:IsValid(queuedAttack.piQueuedShot)
		and Board:IsValid(queuedAttack.piTarget)
end

local function onMissionUpdate(mission)
	if Board:GetBusyState() == 0 then
		if attacking then
			local args = {
				attacker.mission,
				attacker.pawn,
				attacker.skillId,
				attacker.p1,
				attacker.p2
			}

			-- Dispatch with the same arguments as onSkillEnd
			modApi.events.onAttackResolved:dispatch(unpack(args))

			if attacker.pawn:IsEnemy() then
				modApi.events.onEnemyAttackResolved:dispatch(unpack(args))
			else
				modApi.events.onAllyAttackResolved:dispatch(unpack(args))
			end
		end

		attacking = false

		-- Update tracked queued attacks
		local queuedAttacks = mission.queuedAttacks
		if queuedAttacks == nil then
			queuedAttacks = {}
			mission.queuedAttacks = queuedAttacks
		end

		local pawns = Board:GetPawns(TEAM_ANY)
		for i = 1, pawns:size() do
			local pawnId = pawns:index(i)
			local pawn = Board:GetPawn(pawnId)
			local queuedAttack = pawn:GetQueued()

			local isQueued = true
				and queuedAttack ~= nil
				and queuedAttack.piQueuedShot ~= nil
				and Board:IsValid(queuedAttack.piQueuedShot)

			local wasQueued = queuedAttacks[pawnId] ~= nil

			local isQueuedAttacking = true
				and isQueued
				and queuedAttack.piTarget ~= nil
				and queuedAttack.piTarget.x == -INT_MAX
				and queuedAttack.piTarget.y == -INT_MAX

			if isQueuedAttacking then
				if queuedAttacks ~= nil then
					queuedAttacks[pawnId] = nil
				end
			else
				if isQueued and not wasQueued then
					queuedAttacks[pawnId] = queuedAttack
					modApi.events.onQueuedAttackInitiated:dispatch(
						pawn,
						queuedAttack.piOrigin,
						queuedAttack.piTarget,
						queuedAttack.piQueuedShot,
						queuedAttack.iQueuedSkill
					)
				elseif wasQueued and not isQueued then
					local queuedAttack = queuedAttacks[pawnId]
					modApi.events.onQueuedAttackCanceled:dispatch(
						pawn,
						queuedAttack.piOrigin,
						queuedAttack.piTarget,
						queuedAttack.piQueuedShot,
						queuedAttack.iQueuedSkill
					)
					queuedAttacks[pawnId] = nil
				end
			end
		end
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
