
local VERSION = "0.0.1"

local function cachedMoveSpeed()
	local mission = GetCurrentMission()

	if mission.trueMoveSpeed == nil then
		mission.trueMoveSpeed = {}
	end

	return mission.trueMoveSpeed
end

local function updateCachedMoveSpeed()
	local pawns = Board:GetPawns(TEAM_ANY)

	for i = 1, pawns:size() do
		local pawnId = pawns:index(i)
		local pawn = Board:GetPawn(pawnId)
		local loc = pawn:GetSpace()

		if Board:IsValid(loc) then
			local tileTable = Board:GetTileTable(loc)
			local moveSpeed = pawn:GetMoveSpeed()
			local isNotGrappled = moveSpeed > 0

			if isNotGrappled then
				local cachedMoveSpeed = cachedMoveSpeed()

				if cachedMoveSpeed[pawnId] ~= moveSpeed then
					cachedMoveSpeed[pawnId] = moveSpeed
				end
			end
		end
	end
end

local function getMoveSpeed(self, pawn)
	Assert.Equals('table', type(self), "#Argument 0")
	Assert.Equals('userdata', type(pawn), "#Argument 1")

	local result = pawn:GetMoveSpeed()

	if Board ~= nil then
		local loc = pawn:GetSpace()
		local pawnId = pawn:GetId()
		local tileTable = Board:GetTileTable(loc)
		local isGrappled = true
			and tileTable.grappled ~= nil
			and tileTable.grappled > 0

		if isGrappled then
			result = cachedMoveSpeed()[pawnId] or 0
		end
	end

	return result
end

local function onModsInitialized()
	if VERSION < TrueMoveSpeed.version then
		return
	end

	if TrueMoveSpeed.initialized then
		return
	end

	TrueMoveSpeed:finalizeInit()
	TrueMoveSpeed.initialized = true
end

modApi.events.onModsInitialized:subscribe(onModsInitialized)

if TrueMoveSpeed == nil or not modApi:isVersion(VERSION, TrueMoveSpeed.version) then
	TrueMoveSpeed = TrueMoveSpeed or {}
	TrueMoveSpeed.version = VERSION

	function TrueMoveSpeed:finalizeInit()
		TrueMoveSpeed.get = getMoveSpeed

		modApi.events.onMissionUpdate:subscribe(updateCachedMoveSpeed)
	end
end

return TrueMoveSpeed
