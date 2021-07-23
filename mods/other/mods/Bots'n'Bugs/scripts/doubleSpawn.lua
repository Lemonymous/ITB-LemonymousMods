
local mod = mod_loader.mods[modApi.currentMod]
local path = mod.scriptPath
local modUtils = require(path .."modApiExt/modApiExt")
local pawnSpace = require(path .."libs/pawnSpace")
local getNearestLoc = require(path .."libs/getNearestLoc")
local utils = require(path .."libs/utils")
local module_id = mod.id .."_doublespawn"
local cloneable = {
	"lmn_Swarmer1",
	"lmn_Swarmer2",
	"lmn_SwarmerBoss"
}
local this = {}
local isMissionStart = false

local function isCloneable(pawn)
	return list_contains(cloneable, pawn:GetType())
end

local function isHalfSpawn(pawn)
	return _G[pawn:GetType()].HalfSpawn
end

lmn_DoubleSpawn = {}

function lmn_DoubleSpawn.CanSidestep(pawnId)
	local pawn = Board:GetPawn(pawnId)
	local moveSpeed = pawn:GetMoveSpeed()
	local pathing = pawn:GetPathProf()
	local p1 = pawn:GetSpace()
	
	-- prevent clone to step into deployment zone and pylon zone in final mission.
	local deployment = {}
	local pylons = {}
	
	if isMissionStart or Game:GetTurnCount() == 0 then
		deployment = utils.getDeploymentZone()
		pylons = extract_table(Board:GetZone("pylons"))
	end
	
	local p2 = getNearestLoc(p1, function(p)
		local result =
			p ~= p1										and
			not Board:IsBlocked(p, pathing)				and
			not Board:IsSpawning(p)						and
			not Board:IsDangerous(p)					and
			not Board:IsPod(p)							and
			not list_contains(deployment, p)			and
			not list_contains(pylons, p)
		
		if result then
			local path = Board:GetPath(p1, p, pathing)
			
			if path:empty() or path:size() - 1 > moveSpeed then
				return false
			end
		end
		
		return result
	end)
	
	if not p2 then
		return false
	end
	
	Board:SetDangerous(p2)
	local fx = SkillEffect()
	pawnSpace.FilterSpace(fx, p1, pawnId)
	fx:AddMove(Board:GetPath(p1, p2, pathing), NO_DELAY)
	pawnSpace.Rewind(fx)
	Board:AddEffect(fx)
	
	return true
end

local oldGetSpawnCount = Mission.GetSpawnCount
function Mission.GetSpawnCount(...)
	
	local pawns_all = extract_table(Board:GetPawns(TEAM_ENEMY_MAJOR))
	local pawns = {}
	for _, id in ipairs(pawns_all) do
		local pawn = Board:GetPawn(id)
		
		if isHalfSpawn(pawn) then
			pawns[#pawns+1] = { pawn = pawn, loc = pawn:GetSpace() }
		end
	end
	
	-- hide half of all units from GetPawnCount function.
	-- every unit counts as 0.5 pawns for spawn count purposes.
	-- X.5 units is rounded down to X.0
	for i = 1, math.ceil(#pawns / 2) do
		local swarmer = pawns[i]
		Board:RemovePawn(swarmer.pawn)
	end
	
	local result = oldGetSpawnCount(...)
	
	-- unhide pawns.
	for i = 1, math.ceil(#pawns / 2) do
		local swarmer = pawns[i]
		Board:AddPawn(swarmer.pawn)
		swarmer.pawn:SetSpace(swarmer.loc)
	end
	
	return result
end

function this:load()
	modApi:addPreMissionAvailableHook(function(mission)
		isMissionStart = true
	end)
	
	modApi:addPostMissionAvailableHook(function(mission)
		isMissionStart = false
	end)
	
	local function TryClonePawn(m, pawn)
		if not isCloneable(pawn) then
			return
		end
		
		local pawnId, pawnType = pawn:GetId(), pawn:GetType()
		local pData = _G[pawnType]
		
		m[module_id] = m[module_id] or {}
		m[module_id][pawnId] = m[module_id][pawnId] or {}
		
		-- return if this pawn has replicated.
		if m[module_id][pawnId].hasDuped then
			return
		end
		
		-- init copy count.
		m[module_id][pawnId].copy = m[module_id][pawnId].copy or 0
		
		-- return if we have cloned this pawn enough.
		-- clone once by default for cloneable pawns.
		if m[module_id][pawnId].copy >= (pData.Clones or 1) then
			return
		end
		
		local p = pawn:GetSpace()
		local fx = SkillEffect()
		fx:AddDelay(.8)
		fx:AddScript(string.format([[
			local m = GetCurrentMission();
			local module_id, pawnId, p, type, copy = %q, %s, %s, %q, %s;
			
			if lmn_DoubleSpawn.CanSidestep(pawnId) then
				local clone = PAWN_FACTORY:CreatePawn(type);
				local cloneId = clone:GetId();
				
				m[module_id][pawnId].hasDuped = true;
				m[module_id][cloneId] = m[module_id][cloneId] or {};
				m[module_id][cloneId].copy = copy + 1;
				
				Board:AddPawn(clone, p);
				clone:SpawnAnimation();
			end
		]], module_id, pawnId, p:GetString(), pawnType, m[module_id][pawnId].copy))
		
		Board:AddEffect(fx)
	end
	
	local function TryClonePawns(m)
		-- check if we need to clone any pawns after loading a game.
		for _, id in ipairs(extract_table(Board:GetPawns(TEAM_ANY))) do
			local pawn = Board:GetPawn(id)
			TryClonePawn(m, pawn)
		end
	end
	
	modUtils:addPawnTrackedHook(function(m, pawn)
		TryClonePawn(m, pawn)
	end)
	
	modUtils:addResetTurnHook(function()
		-- board state is of before reset,
		-- so wait until it updates.
		modApi:runLater(TryClonePawns)
	end)
	
	modUtils:addGameLoadedHook(function(mission)
		if mission then
			-- board is not created yet,
			-- so wait until it updates.
			modApi:runLater(TryClonePawns)
		end
	end)
end

return this
