
local this = {}

-- make bosses count as Alphas
local old_Spawner_CountLivingUpgrades = Spawner.CountLivingUpgrades
function Spawner:CountLivingUpgrades()
	local count = old_Spawner_CountLivingUpgrades(self)
	if not Board then
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

local function IsBot(str)
	return _G[str] and _G[str].DefaultFaction == FACTION_BOTS
end

local function IsJelly(str)
	return _G[str] and _G[str].Leader ~= LEADER_NONE
end

local function RemUpg(str)
	local l = string.len(str)
	local upg = string.sub(str, math.max(1, l - 3), l)
	if upg == "Boss" then
		return string.sub(str, 1, l - 4)
	end

	return string.sub(str, 1, l - 1)
end

-- returns 'Boss', '1' or '2'
-- for Boss, normal and Alpha Vek respectively.
local function GetUpgrade(str)
	local l = string.len(str)
	local upg = string.sub(str, math.max(1, l - 3), l)
	if upg == "Boss" then
		return upg
	end
	return string.sub(str, l, l)
end

local function GetBoss(spawner, str)
	if	not spawner.lmn_customDiff_mission_started and
		not this.starting_bosses

	then
		return
	end

	local leader
	if IsJelly(str) then
		leader = "Jelly_Boss"
	else
		leader = string.sub(str, 1, string.len(str) - 1) .."Boss"
	end

	if _G[leader] then
		return leader
	end

	return nil
end

local old_Spawner_NextPawn = Spawner.NextPawn
function Spawner:NextPawn(pawn_tables)
	local ret = old_Spawner_NextPawn(self, pawn_tables)

	if IsBot(ret) then -- avoid converting bots into vek.
		return ret
	end

	if not self.non_island_vek then

		self.non_island_vek = {}

		local island_pawns = GAME:GetSpawnList(self.spawn_island)

		for _, vek in ipairs(EnemyLists.Core) do
			if not list_contains(island_pawns, vek) then
				table.insert(self.non_island_vek, vek)
			end
		end

		for _, vek in ipairs(EnemyLists.Unique) do
			if not list_contains(island_pawns, vek) then
				table.insert(self.non_island_vek, vek)
			end
		end

		if not this.jelly_no_touch then
			for _, vek in ipairs(EnemyLists.Leaders) do
				if not list_contains(island_pawns, vek) then
					table.insert(self.non_island_vek, vek)
				end
			end
		end
	end

	local upg = GetUpgrade(ret)
	local isJelly = IsJelly(ret)

	if	tostring(self.missionName) ~= "Sinkhole Hive" and -- avoid converting emerging hornets into ground Vek.
		#self.non_island_vek > 0
	then
		local spiceroll = math.random(0, 100)

		local str = "Spiceroll for ".. ret ..": ".. spiceroll .." - "

		if spiceroll < this.non_island_chance then
			if not IsJelly(ret) or not this.jelly_no_touch then

				local vek = self.non_island_vek[random_int(#self.non_island_vek) + 1]

				local upg = upg
				if upg ~= "Boss" then
					if IsJelly(vek) and upg == "2" then
						upg = "1"
					end

					if _G[vek .. upg] then -- for peace of mind
						str = str .. "Converting to ".. vek .. upg .."."
						ret = vek .. upg
					else
						str = str .. "Failed converting to ".. vek .. upg .."."
					end
				else
					str = str .."Suppressing converting Bosses."
				end
			else
				str = str .."Suppressing converting Psions."
			end
		else
			str = str .."Failed."
		end

		if this.logging_spice then
			LOG(str)
		end
	end

	if upg == "2" or isJelly then
		local bossroll = math.random(0, 100)

		local str = "Bossroll for ".. ret ..": ".. bossroll .." - "

		if bossroll < this.leader_chance then

			local leader = GetBoss(self, ret)

			if leader then
				str = str .."Upgrading ".. ret .." to ".. leader .."."
				ret = leader
			else
				if	not self.lmn_customDiff_mission_started and
					not this.starting_bosses
				then
					str = str .."Suppressing spawn at the start of mission."
				else
					str = str .."Failed to find matching boss upgrade."
				end
			end

		else
			str = str .."Failed."
		end

		if this.logging_boss then
			LOG(str)
		end
	end

	return ret
end

local oldMissionCreateSpawner = Mission.CreateSpawner
function Mission:CreateSpawner(data)
	oldMissionCreateSpawner(self, data)
	self.Spawner.missionName = self.Name
end

local oldMissionGetStartingPawns = Mission.GetStartingPawns
function Mission:GetStartingPawns()
	local startingCount = oldMissionGetStartingPawns(self)

	return startingCount + this.mod_spawn_start
end

local oldMissionGetSpawnsPerTurn = Mission.GetSpawnsPerTurn
function Mission:GetSpawnsPerTurn()
	local spawnCounts = oldMissionGetSpawnsPerTurn(self)
	for i, _ in ipairs(spawnCounts) do
		spawnCounts[i] = spawnCounts[i] + this.mod_spawn_per_turn
	end

	return spawnCounts
end

local oldMissionGetMaxEnemy = Mission.GetMaxEnemy
function Mission:GetMaxEnemy()
	local maxCount = oldMissionGetMaxEnemy(self)

	return maxCount + this.mod_spawn_max
end

sdlext.addGameEnteredHook(function(screen)

	if this.mod.installed then
		--LOG("CustomDifficulty enabled - Modifying spawns.")
		this.mod_spawn_start = this.options["option_mod_spawn_start"].value
		this.mod_spawn_per_turn = this.options["option_mod_spawn_per_turn"].value
		this.mod_spawn_max = this.options["option_mod_spawn_max"].value
		this.leader_chance = this.options["option_random_bosses"].value
		this.non_island_chance = this.options["option_non_island_vek"].value
		this.jelly_no_touch = this.options["option_jelly_no_touch"].enabled
		this.starting_bosses = this.options["option_starting_bosses"].enabled
		this.logging_spice = this.options["option_logging_spice"].enabled
		this.logging_boss = this.options["option_logging_boss"].enabled
	else
		-- need a way to detect mod not enabled for this to work.
		--LOG("CustomDifficulty not enabled - Stop modifying spawns.")
		this.mod_spawn_start = 0
		this.mod_spawn_per_turn = 0
		this.mod_spawn_max = 0
		this.leader_chance = 0
		this.non_island_chance = 0
		this.jelly_no_touch = false
		this.starting_bosses = false
		this.logging_spice = false
		this.logging_boss = false
	end
end)

function this:init(mod)

end

function this:load(mod, options)
	this.mod = mod
	this.options = options

	modApi:addMissionStartHook(function(mission)
		mission:GetSpawner().lmn_customDiff_mission_started = true
	end)
end

return this