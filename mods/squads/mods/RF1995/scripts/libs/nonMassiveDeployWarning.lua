
-------------------------------------------------
-- non-Massive Deployment Warning - code library
-------------------------------------------------
-- displays a warning for deploying in water for
-- non-massive mechs. (pawns must be added)
--
-- requires modApiExt.
-------------------------------------------------

-------------------------------
-- initialization and loading:
--[[---------------------------

	-- in init.lua
	local deployWarning

	-- in init.lua - function init:
	deployWarning = require(self.scriptPath .."nonMassiveDeployWarning")
	deployWarning:init(self)

	-- in init.lua - function load:
	deployWarning:load(modApiExt)
	
	
	-- after you have initialized and loaded it,
	-- you can request it again in other files with:
	local deployWarning = require(self.scriptPath .."nonMassiveDeployWarning")
	
]]-----------------------------

------------------
-- function list:
------------------

-----------------------------------------------------------
-- deployWarning:Add(pawnType)
--[[-------------------------------------------------------
	adds a pawn to track non-massive status of.
	warning icons will still only appear if pawn is
	non-massive and non-flying.
	
	example:
	
	deployWarning:Add("PunchMech")
	
]]---------------------------------------------------------

local mod = mod_loader.mods[modApi.currentMod]
local resourcePath = mod.resourcePath
local scriptPath = mod.scriptPath

local modApiExt = require(scriptPath .."modApiExt/modApiExt")

local this = {
	id = mod.id .."_DeploymentWarning",
	pawns = {},
}

this.Warning = {
	Link = this.id.. "_Link",
	IconColor = GL_Color(255, 150, 140, 1),
	TileColor = GL_Color(255, 50, 50, 0.75),
	Tile = "combat/tile_icon/".. this.id .."_drown.png",
	Title = "Dangerous Deployment.",
	Desc = "Non-massive Mechs that cannot fly die in water.",
}

Location[this.Warning.Tile] = Point(-27,2)
TILE_TOOLTIPS[this.Warning.Link] = {this.Warning.Title, this.Warning.Desc}
modApi:appendAsset("img/".. this.Warning.Tile, resourcePath .."img/combat/tile_icon/tile_drown.png")

local defaultDeploymentZone = {}
for x = 1, 3 do
	for y = 1, 6 do
		table.insert(defaultDeploymentZone, Point(x,y))
	end
end

local function pawnIsDrownable(pawn)
	return
		this.pawns[pawn:GetType()]     and
		not _G[pawn:GetType()].Massive and
		not pawn:IsFlying()
end

local function addToDeployableMechs(id)
	GAME[this.id] = GAME[this.id] or {}
	
	table.insert(GAME[this.id].Deployable_Mechs, 1, id)
	GAME[this.id].SelectedMechId = id
end

local function removeFromDeployableMechs(id)
	GAME[this.id] = GAME[this.id] or {}
	
	remove_element(id, GAME[this.id].Deployable_Mechs)
	GAME[this.id].SelectedMechId = GAME[this.id].Deployable_Mechs[1]
end

local oldMissionStartDeployment = Mission.StartDeployment
Mission.StartDeployment = function(...)
	GAME[this.id] = {
		DeploymentPhase = true,
		Deployable_Mechs = {0, 1, 2},
		SelectedMechId = 0,
		DangerTiles = {}
	}
	
	local deploymentZone
	local customDeployZone = extract_table(Board:GetZone("deployment"))
	if #customDeployZone > 0 then
		deploymentZone = customDeployZone
	else
		deploymentZone = defaultDeploymentZone
	end
	
	for _, tile in ipairs(deploymentZone) do
		if Board:GetTerrain(tile) == TERRAIN_WATER then
			table.insert(GAME[this.id].DangerTiles, tile)
		end
	end
	
	oldMissionStartDeployment(...)
end

function this:AddPawn(pawnType)
	assert(type(pawnType) == 'string')
	assert(_G[pawnType])
	
	self.pawns[pawnType] = true
end

sdlext.addGameExitedHook(function()
	this.highlighted = nil
end)

function this:init() end
function this:load()
	modApi:addNextTurnHook(function()
		GAME[self.id] = GAME[self.id] or {}
		GAME[self.id].DeploymentPhase = false
	end)
	
	modApi:addMissionUpdateHook(function()
		GAME[self.id] = GAME[self.id] or {}
		
		if
			not GAME[self.id].DeploymentPhase or
			not GAME[self.id].SelectedMechId
		then
			return
		end
		
		local selectedPawn = Board:GetPawn(GAME[self.id].SelectedMechId)
		
		if pawnIsDrownable(selectedPawn) then
			for _, tile in ipairs(GAME[self.id].DangerTiles) do
				Board:MarkSpaceImage(tile, self.Warning.Tile, self.Warning.IconColor)
				Board:MarkSpaceDesc(tile, self.Warning.Link)
				Board:MarkSpaceSimpleColor(tile, self.Warning.TileColor)
				if tile == self.highlighted then
					local damage = SpaceDamage(tile, DAMAGE_DEATH)
					Board:MarkSpaceDamage(damage)
				end
			end
		end
		
		if
			self.highlighted								and
			Board:IsPawnSpace(self.highlighted)				and
			Board:IsPawnTeam(self.highlighted, TEAM_MECH)	and
			pawnIsDrownable(Board:GetPawn(self.highlighted))
		then
			local tile = selectedPawn:GetSpace()
			if list_contains(GAME[self.id].DangerTiles, tile) then
				local damage = SpaceDamage(tile, DAMAGE_DEATH)
				Board:MarkSpaceDamage(damage)
			end
		end
	end)
	
	modApiExt:addPawnSelectedHook(function(_, pawn)
		GAME[self.id] = GAME[self.id] or {}
		
		if
			not GAME[self.id].DeploymentPhase	or
			pawn:GetTeam() ~= TEAM_PLAYER		or
			not pawn:IsMech()
		then
			return
		end
		
		local id = pawn:GetId()
		
		if pawn:GetSpace() == Point(-1, -1) then
			removeFromDeployableMechs(id)
		end
		
		addToDeployableMechs(id)
	end)
	
	modApiExt:addPawnDeselectedHook(function(_, pawn)
		GAME[self.id] = GAME[self.id] or {}
		
		if
			not GAME[self.id].DeploymentPhase	or
			pawn:GetTeam() ~= TEAM_PLAYER		or
			not pawn:IsMech()
		then
			return
		end
		
		if pawn:GetSpace() ~= Point(-1, -1) then
			removeFromDeployableMechs(pawn:GetId())
		end
	end)
	
	modApiExt:addPawnPositionChangedHook(function(_, pawn, oldPosition)
		GAME[self.id] = GAME[self.id] or {}
		
		if not GAME[self.id].DeploymentPhase then
			return
		end
		
		local id = pawn:GetId()
		if pawn:GetSpace() == Point(-1, -1) then
			addToDeployableMechs(id)
		elseif oldPosition == Point(-1, -1) then
			removeFromDeployableMechs(id)
		end
	end)
	
	modApiExt:addTileHighlightedHook(function(_, tile) self.highlighted = tile end)
	modApiExt:addTileUnhighlightedHook(function() self.highlighted = nil end)
end

return this
