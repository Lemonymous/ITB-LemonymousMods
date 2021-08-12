
local modApiExt = LApi.library:fetch("modApiExt/modApiExt", nil, "ITB-ModUtils")

-- mission with 5 turns has enemy spawn on turn 0, 1, 2, 3.

--[[
	make leaders count as alpha's for determining
	whether to create weak or alpha pawns
	in the final mission(s).
--]]
local old_Spawner_CountLivingUpgrades = Spawner.CountLivingUpgrades
function Spawner:CountLivingUpgrades()
	local count = old_Spawner_CountLivingUpgrades(self)
	if	not Board				or
		not self.isFinalMission	then
		
		return count
	end
	
	local pawns = extract_table(Board:GetPawns(TEAM_ENEMY))
	for _, id in ipairs(pawns) do
		if string.find(Board:GetPawn(id):GetType(), "Boss") then
			count = count + 1
		end
	end
	
	return count
end

local old_Spawner_NextPawn = Spawner.NextPawn
function Spawner:NextPawn(pawn_tables)
	local ret = old_Spawner_NextPawn(self, pawn_tables)
	
	if	self.isFinalMission								and
		#self.leaders_remaining > 0						and
		self.leaders_spawned < self.leaders_to_spawn	then
		
		local leader = string.sub(ret, 1, string.len(ret) - 1) .."Boss"
		if list_contains(self.leaders_remaining, leader) then
			remove_element(leader, self.leaders_remaining)
			self.leaders_spawned = self.leaders_spawned + 1
			ret = leader
		end
	end
	--LOG("Spawner:NextPawn=".. ret .." leaders_spawned=".. tostring(self.leaders_spawned) .."/".. tostring(self.num_leaders))
	return ret
end

local function InitBossRush(mission)
	local spawner = mission:GetSpawner()
	spawner.isFinalMission = true
	spawner.leaders_spawned = 0
	spawner.leaders_to_spawn = 0
	spawner.leaders_remaining = shallow_copy(mission.BossList)
end

local function UpdateBossRush(mission)
	local spawner = mission:GetSpawner()
	local total = 0
	while total ~= spawner.num_leaders do
		total = math.min(total + 4, spawner.num_leaders)
		-- some silly code to space out spawns evenly across 4 turns.
		if Board:GetTurn() % (4 / (total % 4 > 0 and total % 4 or 4)) < 1 then
			spawner.leaders_to_spawn = spawner.leaders_to_spawn + 1
		end
	end
end

local old_Mission_Final_StartMission = Mission_Final.StartMission
function Mission_Final:StartMission()
	InitBossRush(self)
	return old_Mission_Final_StartMission(self)
end

local old_Mission_Final_GetSpawnCount = Mission_Final.GetSpawnCount
function Mission_Final:GetSpawnCount()
	UpdateBossRush(self)
	return old_Mission_Final_GetSpawnCount(self)
end

local old_Mission_Final_Cave_StartMission = Mission_Final_Cave.StartMission
function Mission_Final_Cave:StartMission()
	InitBossRush(self)
	return old_Mission_Final_Cave_StartMission(self)
end

local old_Mission_Final_Cave_GetSpawnCount = Mission_Final_Cave.GetSpawnCount
function Mission_Final_Cave:GetSpawnCount()
	UpdateBossRush(self)
	return old_Mission_Final_Cave_GetSpawnCount(self)
end

local function onPawnTracked(mission, pawn)
	local spawner = mission:GetSpawner()
	
	if not spawner.isFinalMission then
		return
	end
	
	local pawnType = pawn:GetType()
	if	spawner.leaders_remaining							and
		list_contains(spawner.leaders_remaining, pawnType)	then
		
		remove_element(pawnType, spawner.leaders_remaining)
		spawner.leaders_spawned = spawner.leaders_spawned + 1
	end
end

local function onModsLoaded()
	--[[
		set the maximum number of extra leaders we
		can spawn per 4 turns on the final missions,
		(each phase), for every combination of difficulty
		and number of islands cleared.
		
		spawns has set pawns on them, so leaders can be
		blocked like any other pawn; however, the player
		won't know which is which.
	--]]
	
	SectorSpawners[DIFF_EASY][2].num_leaders = 0
	SectorSpawners[DIFF_EASY][3].num_leaders = 0
	SectorSpawners[DIFF_EASY][4].num_leaders = 0
	SectorSpawners[DIFF_NORMAL][2].num_leaders = 0
	SectorSpawners[DIFF_NORMAL][3].num_leaders = 0
	SectorSpawners[DIFF_NORMAL][4].num_leaders = 1
	SectorSpawners[DIFF_HARD][2].num_leaders = 1
	SectorSpawners[DIFF_HARD][3].num_leaders = 2
	SectorSpawners[DIFF_HARD][4].num_leaders = 3
	SectorSpawners[DIFF_VERY_HARD][2].num_leaders = 3
	SectorSpawners[DIFF_VERY_HARD][3].num_leaders = 4
	SectorSpawners[DIFF_VERY_HARD][4].num_leaders = 5
	SectorSpawners[DIFF_IMPOSSIBLE][2].num_leaders = 4
	SectorSpawners[DIFF_IMPOSSIBLE][3].num_leaders = 6
	SectorSpawners[DIFF_IMPOSSIBLE][4].num_leaders = 8
	
	-- these can only be reached via console.
	SectorSpawners[DIFF_EASY][1].num_leaders = 0
	SectorSpawners[DIFF_NORMAL][1].num_leaders = 0
	SectorSpawners[DIFF_HARD][1].num_leaders = 0
	SectorSpawners[DIFF_VERY_HARD][1].num_leaders = 0
	SectorSpawners[DIFF_IMPOSSIBLE][1].num_leaders = 0
	
	modApiExt:addPawnTrackedHook(onPawnTracked)
end

modApi.events.onModsLoaded:subscribe(onModsLoaded)
