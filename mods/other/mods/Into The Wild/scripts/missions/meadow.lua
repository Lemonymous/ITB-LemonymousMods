
local path = mod_loader.mods[modApi.currentMod].scriptPath
local utils = require(path .."utils")
local this = {id = "Mission_lmn_Meadow"}

Mission_lmn_Meadow = Mission_Infinite:new{
	Name = "Flower Field",
	SpawnStart = 0,
	SpawnStart_Easy = 0,
	MapTags = {"lmn_meadow"},
	Environment = "Env_lmn_Meadow",
	BonusPool = { BONUS_KILL_FIVE, BONUS_GRID, BONUS_BLOCK, "lmn_bonus_specimen" },
	UseBonus = true,
	sprouts =
	{
		DIFF_EASY = {
			init_count = {3,4,4,5},
			spawn_chance = {.3,.3,.3,.3},
			upg_chance = {.2,.2,.3,.3}
		},
		DIFF_DEFAULT = {
			init_count = {4,5,5,6},
			spawn_chance = {.4,.4,.5,.5},
			upg_chance = {.4,.5,.6,.8}
		}
	}
}

Env_lmn_Meadow = Environment:new{
	Name = "Meadow",
	Text = "Only Flower enemies can spawn, and Sprouts grow in large quantities.", -- TODO: update text
	StratText = "MEADOW",
	CombatIcon = "combat/tile_icon/lmn_tile_meadow.png",
	CombatName = "MEADOW",
}

local function isDeploymentZone(loc)
	local zone = Board:GetZone("deployment")
	if zone then
		zone = extract_table(zone)
	else
		zone = {}
		for x = 1, 6 do
			for y = 1, 3 do
				zone[zone+1] = Point(x,y)
			end
		end
	end
	
	return list_contains(zone, loc)
end

local function isValidSpawn(loc, avoidDeployment)
	local isDeploymentZone = avoidDeployment and isDeploymentZone(loc)
	
	return
		not Board:IsBlocked(loc, PATH_GROUND)	and
		not isDeploymentZone					and
		not Board:IsSpawning(loc)				and
		not Board:IsPod(loc)
end

function Mission_lmn_Meadow:SpawnSprouts(count)
	local board = utils.getBoard()
	utils.shuffle(board)
	
	for _, loc in ipairs(board) do
		if count <= 0 then
			break
		end
		
		if isValidSpawn(loc) then
			count = count - 1
			if math.random() < self.sprouts.upg_chance then
				Board:SpawnPawn("lmn_SproutBud2", loc)
			else
				Board:SpawnPawn("lmn_SproutBud1", loc)
			end
		end
	end
end

function Mission_lmn_Meadow:StartMission()
	local diff = GetDifficulty() == DIFF_EASY and "DIFF_EASY" or "DIFF_DEFAULT"
	local sprouts = self.sprouts[diff]
	local sector = GetSector()
	
	-- init sprout vars for this mission instance.
	self.sprouts = {
		init_count = sprouts.init_count[math.max(1, math.min(sector, #sprouts.init_count))],
		spawn_chance = sprouts.spawn_chance[math.max(1, math.min(sector, #sprouts.spawn_chance))],
		upg_chance = sprouts.upg_chance[math.max(1, math.min(sector, #sprouts.upg_chance))]
	}
	
	local sector = GetSector()
	local counts = {Core = 2, Unique = math.min(0, sector - 2)}
	
	-- populate list as we get more plants in game.
	local enemylists = 
	{
		Core = {"lmn_Sunflower", "lmn_Springseed"},--"lmn_Sprout", "lmn_Bud", 
		Unique = {"lmn_Sunflower", "lmn_Infuser1"} -- temp to avoid crash on island 3-4
	}
	
	self.pawn_table = {}
	for kind, count in pairs(counts) do
		if #enemylists[kind] > 0 then
			for i = 1, count do
				table.insert(self.pawn_table, random_removal(enemylists[kind]))
			end
		end
	end
	
	local spawner = self:GetSpawner()
	spawner.max_pawns = shallow_copy(spawner.max_pawns)
	spawner.max_pawns.lmn_Sprout = INT_MAX
	
	self:SpawnSprouts(self.sprouts.init_count)
	Board:SpawnQueued()
end

function Mission_lmn_Meadow:UpdateSpawning()
	local count = self:GetSpawnCount()
	
	if self.TurnLimit - Game:GetTurnCount() > 2 then
		local sprouts = 0
		
		for i = count, 1, -1 do
			if math.random() < self.sprouts.spawn_chance then
				sprouts = sprouts + 1
			end
		end
		
		self:SpawnSprouts(sprouts * 2)
		
		count = count - sprouts
	end
	
	if count > 0 then
		self:SpawnPawns(count)
	end
end

function Mission_lmn_Meadow.NextPawn(self, pawn_tables, name_only)
	return Mission.NextPawn(self, self.pawn_table, name_only)
end

function this:init(mod)
	modApi:appendAsset("img/combat/tiles_grass/lmn_ground_meadow.png", mod.resourcePath .."img/tileset_plant/ground_meadow.png")
	
	for i = 0, 5 do
		modApi:addMap(mod.resourcePath .."maps/lmn_meadow".. i ..".map")
	end
	
	modApi:appendAsset("img/combat/tile_icon/lmn_tile_meadow.png", mod.resourcePath .."img/combat/icon_meadow.png")
	Location["combat/tile_icon/lmn_tile_meadow.png"] = Point(-27,2)
	Global_Texts["TipTitle_".."Env_lmn_Meadow"] = Env_lmn_Meadow.Name
	Global_Texts["TipText_".."Env_lmn_Meadow"] = Env_lmn_Meadow.Text
end

function this:load(mod, options, version)
end

return this