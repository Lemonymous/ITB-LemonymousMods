
---------------------------------------------------------------------
-- Trait v1.2 - code library
---------------------------------------------------------------------
-- add a trait description and icon to the tooltip of a unit type.
-- max one per unit type, and should only be used for unit types created
-- in your own mod.
--
-- trying to give traits to unit types outside of your mod can overwrite
-- traits from other mods.
--
-- v1.1: streamlined and removed functionality that was beyond scope (tutorial tips).
-- v1.2: removed getModUtils lib dependency.

local mod = mod_loader.mods[modApi.currentMod]
local path = mod.resourcePath
local module_id = mod.id .."_trait"
local modUtils = require(path .."scripts/modApiExt/modApiExt")
local traits = {
	--[[
	[pawnType] = {
		id,
		desc
	}
	]]
}

local icons = {
	--[pid] = trait
}

local pawns = {
	--[pawnId] = {loc}
}

local this = {}
local traitCount = 0

local function file_exists(name)
	local f = io.open(name, "r")
	if f then io.close(f) return true else return false end
end

-- return the description of the trait.
local oldGetStatusTooltip = GetStatusTooltip
function GetStatusTooltip(id)
	for _, trait in pairs(traits) do
		if id == trait.id then
			return trait.desc
		end
	end
	
	return oldGetStatusTooltip(id)
end

function this:Add(input)
	local id = module_id .. traitCount
	local pawnTypes = input.PawnTypes
	local icon = input.Icon
	local desc = input.Description
	
	assert(type(pawnTypes) == 'table' or type(pawnTypes) == 'string', "must be string or table of strings")
	assert(type(icon) == 'table' or type(icon) == 'string', "must be string or table of length 2 with string and Point")
	assert(type(desc) == 'table', "must be table of length 2 with title and text")
	
	if type(pawnTypes) ~= 'table' then
		pawnTypes = {pawnTypes}
	end
	
	if type(icon) ~= 'table' then
		icon = {icon, Point(0,0)}
	end
	
	for _, pawnType in ipairs(pawnTypes) do
		traits[pawnType] = {
			id = id,
			desc = desc
		}
	end
	
	local path = "combat/icons/icon_".. id .. ".png"
	local pathGlow = "combat/icons/icon_".. id .. "_glow.png"
	local file_icon = icon[1]
	local file_icon_glow = icon[1]:sub(1, -5) .."_glow.png"
	local icon_offset = icon[2]
	local is_vanilla_asset = file_icon:find("^img/")
	
	if is_vanilla_asset then
		modApi:copyAsset(file_icon, "img/".. path)
		modApi:copyAsset(file_icon_glow, "img/".. pathGlow)
		Location[pathGlow] = icon_offset
		
	else
		if file_exists(file_icon) then
			modApi:appendAsset("img/".. path, file_icon)
			
		elseif file_exists(file_icon_glow) then
			modApi:appendAsset("img/".. pathGlow, file_icon_glow)
			Location[pathGlow] = icon_offset
		end
	end
	
	traitCount = traitCount + 1
end

-- updates a tile with the correct trait icon.
local function updateTile(p)
	local pawn = Board:GetPawn(p)
	local pid = p2idx(p)
	local current = icons[pid]
	
	if pawn and not pawn:IsDead() then
		local pawnType = pawn:GetType()
		local trait = traits[pawnType]
		
		if trait then
			if trait.id ~= current then
				-- found a trait and it is different than current icon.
				Board:SetTerrainIcon(p, trait.id)
				icons[pid] = trait.id
			end
			
			return
		end
	end
	
	-- icon on tile shouldn't possibly be there.
	Board:SetTerrainIcon(p, "")
	icons[pid] = nil
end

-- update any trait icon for a pawn
local function updatePawn(pawnId)
	local pawn = Board:GetPawn(pawnId)
	local tracked = pawns[pawnId]
	
	if not tracked then
		return
	end
	
	updateTile(tracked.loc)
	
	if not pawn or pawn:IsDead() then
		pawns[pawnId] = nil
		return
	end
	
	tracked.loc = pawn:GetSpace()
	updateTile(tracked.loc)
end

-- starts tracking a single pawn.
local function trackPawn(_, pawn)
	local pawnId = pawn:GetId()
	local pawnType = pawn:GetType()
	
	if not traits[pawnType] then
		return
	end
	
	pawns[pawnId] = {loc = pawn:GetSpace()}
	
	updatePawn(pawnId)
end

-- refreshes the whole list of tracked icons.
local function trackPawns()
	-- clear tracked icons.
	for pid, trait in pairs(icons) do
		local p = idx2p(pid)
		
		Board:SetTerrainIcon(p, "")
	end
	
	pawns = {}
	icons = {}
	
	for _, pawnId in ipairs(extract_table(Board:GetPawns(TEAM_ANY))) do
		trackPawn(_, Board:GetPawn(pawnId))
	end
end

local function untrackPawns()
	pawns = {}
	icons = {}
end

sdlext.addGameExitedHook(untrackPawns)

function this:load()
	modApi:addTestMechEnteredHook(trackPawns)
	modApi:addTestMechExitedHook(untrackPawns)
	modApi:addMissionEndHook(untrackPawns)
	modUtils:addResetTurnHook(function()
		-- board state is of before reset,
		-- so wait until it updates.
		modApi:runLater(trackPawns)
	end)
	modUtils:addGameLoadedHook(function(mission)
		if mission then
			-- board is not created yet,
			-- so wait until it updates.
			modApi:runLater(trackPawns)
		end
	end)
	modUtils:addPawnTrackedHook(trackPawn)
	
	modApi:addMissionUpdateHook(function()
		-- make a copy so we can remove elements from
		-- the original list without disturbing the iteration.
		local pawns = shallow_copy(pawns)
		
		for pawnId, tracked in pairs(pawns) do
			updatePawn(pawnId)
		end
	end)
end

return this
