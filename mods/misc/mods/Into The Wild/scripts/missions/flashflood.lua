
local path = mod_loader.mods[modApi.currentMod].scriptPath
local missionTemplates = require(path .."missions/missionTemplates")
local utils = require(path .."utils")
local astar = require(path .."astar")
local this = {id = "Mission_lmn_FlashFlood"}

Mission_lmn_FlashFlood = Mission_Infinite:new{
	Name = "Flash Flood",
	MapTags = {"lmn_flashflood"},
	BonusPool = copy_table(missionTemplates.bonusNoBlock),
	Environment = "Env_lmn_FlashFlood",
	UseBonus = true,
	GlobalSpawnMod = 1,
	SpawnMod = 1,
}
Mission_lmn_FlashFlood.GetCompletedStatus = missionTemplates.GetCompletedStatusEnvironment

Env_lmn_FlashFlood = Environment:new{
	Name = "Flash Flood",
	Text = "A twisting river will rush across the board, submerging marked tiles until next turn.",
	--Text = "A snake of water will rush across the map, submerging marked tiles until next turn.",
	StratText = "FLASH FLOOD",
	CombatIcon = "combat/tile_icon/lmn_tile_flood.png",
	DryupIcon = "combat/tile_icon/lmn_tile_grass.png",
	CombatName = "FLASH FLOOD",
	floodIndex = 0, -- current location of flood. start on map edge.
	submergedTiles = {},
	plannedTiles = {},
	Locations = {},
	Planned = true,
	effectFinished = false,
}

function Env_lmn_FlashFlood:Start()
end

function Env_lmn_FlashFlood:IsValidTarget(loc)
	local terrain = Board:GetTerrain(loc)
	
	return
		Board:IsValid(loc)			and
		not Board:IsPod(loc)		and
		not Board:IsBuilding(loc)	and
		not Board:IsSpawning(loc)	and
		terrain ~= TERRAIN_MOUNTAIN and
		terrain ~= TERRAIN_HOLE
end

local function isCorner(p)
	local size = Board:GetSize()
	
	local x = p.x == 0 or p.x == size.x - 1
	local y = p.y == 0 or p.y == size.y - 1
	
	return x and y
end

function Env_lmn_FlashFlood:Plan()
	self.submerge = not self.submerge
	
	if self.submerge then
		locs = utils.getBoard(function(p)
			return
				Env_lmn_FlashFlood:IsValidTarget(p) and
				Board:IsEdge(p) and not isCorner(p)
		end)
		
		if #locs == 0 then return false end
		
		utils.shuffle(locs)
		local first = locs[1]
		
		local size = Board:GetSize()
		local across = Point(first.x, first.y)
		if across.x == 0 then
			across.x = size.x - 1
		elseif across.y == 0 then
			across.y = size.y - 1
		elseif across.x == size.x - 1 then
			across.x = 0
		elseif across.y == size.y - 1 then
			across.y = 0
		end
		
		table.sort(locs, function(a,b) return a:Manhattan(across) < b:Manhattan(across) end)
		
		for _, last in ipairs(locs) do
			self.Locations = astar.GetPath(first, last, function(p) return self:IsValidTarget(p) end)
			if #self.Locations > 0 then
				self.MarkInProgress = true
				self.MarkLocations = {}
				break
			end
		end
	else
		self.MarkInProgress = true
		self.MarkLocations = {}
	end
	
	for _, p in ipairs(self.Locations) do
		-- TODO: for some reason this does not prevent Vek from spawning here.
		-- Does it have something to do with the mod loaders custom spawning code?
		Board:BlockSpawn(p, BLOCKED_TEMP)
	end
	
	return false -- done planning for this turn.
end

function Env_lmn_FlashFlood:IsEffect()
	return #self.Locations ~= 0
end

function Env_lmn_FlashFlood:MarkBoard()
	local icon = self.submerge and self.CombatIcon or self.DryupIcon
	local desc = self.submerge and "lmn_flashflood_submerge" or "lmn_flashflood_ground"
	
	if self:IsEffect() then
		if self.MarkInProgress and not Board:IsBusy() then
			local fx = SkillEffect()
			
			for i, loc in ipairs(self.Locations) do
				if not list_contains(self.MarkLocations, loc) then
					fx:AddScript(string.format("table.insert(GetCurrentMission().LiveEnvironment.MarkLocations, %s)", loc:GetString()))
					fx:AddSound("/props/square_lightup")
					if i == #self.Locations then
						fx:AddScript("GetCurrentMission().LiveEnvironment.MarkInProgress = nil")
					else
					end
					fx:AddDelay(.10)
				end
			end
			
			Board:AddEffect(fx)
		end
		
		for _, loc in ipairs(self.MarkLocations) do
			Board:MarkSpaceImage(loc, icon, GL_Color(255,226,88,0.75))
			Board:MarkSpaceDesc(loc, desc)
		end
	end
end

function Env_lmn_FlashFlood:Voice(suffix)
	local fx = SkillEffect()
	fx:AddVoice("Mission_lmn_FlashFlood".. suffix, -1)
	Board:AddEffect(fx)
end

function Env_lmn_FlashFlood:ApplyEffect()
	if not self.MarkLocations then return false end
	
	local fx = SkillEffect()
	fx.iOwner = ENV_EFFECT
	
	self.MarkLocations = reverse_table(self.MarkLocations)
	
	while #self.MarkLocations > 0 do
		local loc = pop_back(self.MarkLocations)
		
		if #self.MarkLocations == 0 then
			fx:AddSound("/props/tide_flood_last")
		else
			fx:AddSound("/props/tide_flood")
		end
		
		local d = SpaceDamage(loc)
		
		if self.submerge then
			d.iTerrain = TERRAIN_WATER
			
			if Board:GetTerrain(loc) == TERRAIN_MOUNTAIN or Board:IsDangerousItem(loc) then
				d.iDamage = DAMAGE_DEATH
			end
		else
			if Board:GetTerrain(loc) == TERRAIN_WATER then
				d.iTerrain = TERRAIN_ROAD
			end
		end
		
		fx:AddDamage(d)
		fx:AddBounce(d.loc, -1)
		
		fx:AddDelay(0.08)
    end
	
	local turn = Game:GetTurnCount()
	if turn == 1 then
		fx:AddScript("Env_lmn_FlashFlood:Voice('_Flood')")
	--elseif turn == 4 then
	--	fx:AddScript("Env_lmn_FlashFlood:Voice('_Dry')")
	--else
	--	LOG("turn is ".. turn)
	end
	
    Board:AddEffect(fx)
	
	return false -- effects done for this turn.
end

-- remove belts if flooded.
local old = Env_Belt.CheckBelts
function Env_Belt:CheckBelts(...)
	for i = #self.Belts, 1, -1 do
		if Board:IsTerrain(self.Belts[i], TERRAIN_WATER) then
			table.remove(self.Belts, i)
		end
	end
	
	old(self, ...)
end

function this:init(mod)
	modApi:appendAsset("img/combat/tile_icon/lmn_tile_grass.png", mod.resourcePath .."img/combat/icon_grass.png")
	modApi:appendAsset("img/combat/tile_icon/lmn_tile_flood.png", mod.resourcePath .."img/combat/icon_flood.png")
	Location["combat/tile_icon/lmn_tile_grass.png"] = Point(-27,2)
	Location["combat/tile_icon/lmn_tile_flood.png"] = Point(-27,2)
	
	TILE_TOOLTIPS.lmn_flashflood_submerge = {"Flood", "The tile here will turn into Water."}
	TILE_TOOLTIPS.lmn_flashflood_ground = {"Ground", "The tile here will turn into regular Ground."}
	Global_Texts["TipTitle_".."Env_lmn_FlashFlood"] = Env_lmn_FlashFlood.Name
	Global_Texts["TipText_".."Env_lmn_FlashFlood"] = Env_lmn_FlashFlood.Text
	
	for i = 0, 4 do
		modApi:addMap(mod.resourcePath .."maps/lmn_flashflood".. i ..".map")
	end
end

function this:load(mod, options, version)
	
end

return this