
--------------------------------------------------------
-- Effect Preview v2.0 - code library
--
-- by Lemonymous
--------------------------------------------------------
-- provides functions for previewing
-- charge, leap, teleport, move,
-- and damage to some extent.
--
-- actual damage done in this way is not applied
-- to pawns, but is applied to the tile,
-- so buildings and terrain will be damaged.
--
-- if you need to preview damage, without dealing it,
-- consider using the code library weaponPreview instead.
--------------------------------------------------------
--
--    Requires libraries:
-- globals.lua
--
--    Fetch library:
-- local effectPreview = require(self.scriptPath..'effectPreview')
--
--    Methods:
-- :addDamage(effect, spaceDamage)
-- :addCharge(effect, p1, p2, pathing)
-- :addLeap(effect, p1, p2)
-- :addTeleport(effect, p1, p2)
-- :addMove(effect, pawn, p2, pathing)
-- :addHiddenLeap(effect, p1, p2, delay)
--
--    Methods for internal use:
-- :clearTile(effect, tile)
-- :filterTile(effect, tile)
-- :rewindTile(effect, tile)
--
--------------------------------------------------------

local path = GetParentPath(...)
local globals = require(path.."globals")
local displaced_index
local effectPreview = {}

local function onModsInitialized()
	displaced_index = globals:new()
end

-- move all pawns away from a tile.
-- use RewindTile to revert changes.
function effectPreview:clearTile(effect, tile)
	Assert.Equals('userdata', type(effect), "Argument #1")
	Assert.TypePoint(tile, "Argument #2")

	effect:AddScript(string.format([[
		local displaced = {};
		local tile = %s;
		local pawn = Board:GetPawn(tile);
		globals[%s] = displaced;
		while pawn do
			pawn:SetSpace(Point(-1, -1));
			table.insert(displaced, pawn:GetId());
			pawn = Board:GetPawn(tile);
		end;
	]], tile:GetString(), displaced_index))
end

-- move all pawns away from a tile, except pawn with id == 'id'
-- use RewindTile to revert changes.
function effectPreview:filterTile(effect, tile, id)
	Assert.Equals('userdata', type(effect), "Argument #1")
	Assert.TypePoint(tile, "Argument #2")
	Assert.Equals('number', type(id), "Argument #1")

	effect:AddScript(string.format([[
		local displaced = {};
		local tile = %s;
		local pawn = Board:GetPawn(tile);
		globals[%s] = displaced;
		while pawn and pawn:GetId() ~= %s do
			pawn:SetSpace(Point(-1, -1));
			table.insert(displaced, pawn:GetId());
			pawn = Board:GetPawn(tile);
		end;
	]],  tile:GetString(), displaced_index, id))
end

-- moves all displaced pawns back to it's tile.
-- used after ClearTile or FilterTile
function effectPreview:rewindTile(effect, tile)
	Assert.Equals('userdata', type(effect), "Argument #1")
	Assert.TypePoint(tile, "Argument #2")

	effect:AddScript(string.format([[
		local tile = %s;
		local displaced = globals[%s];
		for _, id in ipairs(displaced) do
			Board:GetPawn(id):SetSpace(tile);
		end;
	]], tile:GetString(), displaced_index))
end

-- previews damage.
function effectPreview:addDamage(effect, spaceDamage)
	Assert.Equals('userdata', type(effect), "Argument #1")
	Assert.Equals('userdata', type(spaceDamage), "Argument #2")
	Assert.TypePoint(spaceDamage.loc)

	self:clearTile(effect, spaceDamage.loc)
	effect:AddDamage(spaceDamage)
	self:rewindTile(effect, spaceDamage.loc)
end

-- previews a charge, but does not move any pawns.
function effectPreview:addCharge(effect, p1, p2, pathing)
	Assert.Equals('userdata', type(effect), "Argument #1")
	Assert.TypePoint(p1, "Argument #2")
	Assert.TypePoint(p2, "Argument #3")

	pathing = pathing or PATH_FLYER

	self:clearTile(effect, p1)
	effect:AddCharge(Board:GetPath(p1, p2, pathing), NO_DELAY)
	self:rewindTile(effect, p1)
end

-- previews a leap, but does not move any pawns.
function effectPreview:addLeap(effect, p1, p2)
	Assert.Equals('userdata', type(effect), "Argument #1")
	Assert.TypePoint(p1, "Argument #2")
	Assert.TypePoint(p2, "Argument #3")

	local leap = PointList()
	leap:push_back(p1)
	leap:push_back(p2)

	self:clearTile(effect, p1)
	effect:AddLeap(leap, NO_DELAY)
	self:rewindTile(effect, p1)
end

-- previews teleport, but does not move any pawns.
function effectPreview:addTeleport(effect, p1, p2)
	Assert.Equals('userdata', type(effect), "Argument #1")
	Assert.TypePoint(p1, "Argument #2")
	Assert.TypePoint(p2, "Argument #3")

	self:clearTile(effect, p1)
	effect:AddTeleport(p1, p2, NO_DELAY)
	self:rewindTile(effect, p1)
end

-- previews a move action, but does not move any pawns.
-- pathing is optional.
function effectPreview:addMove(effect, pawn, p2, pathing)
	Assert.Equals('userdata', type(effect), "Argument #1")
	Assert.Equals('userdata', type(pawn), "Argument #2")
	Assert.TypePoint(p2, "Argument #3")

	pathing = pathing or pawn:GetPathProf()

	local p1 = pawn:GetSpace()
	local move = Board:GetPath(p1, p2, pathing)

	self:clearTile(effect, p1)
	effect:AddMove(move, NO_DELAY)
	self:rewindTile(effect, p1)
end

-- (should probably be in another library)
-- causes a pawn to leap, while hiding it's preview arc.
function effectPreview:addHiddenLeap(effect, p1, p2, delay)
	Assert.Equals('userdata', type(effect), "Argument #1")
	Assert.TypePoint(p1, "Argument #2")
	Assert.TypePoint(p2, "Argument #3")
	Assert.Equals('number', type(delay), "Argument #4")

	local leap = PointList()
	leap:push_back(p1)
	leap:push_back(p2)

	effect:AddLeap(leap, delay)
	effect.effect:index(effect.effect:size()).bHide = true
end

modApi.events.onModsInitialized:subscribe(onModsInitialized)

effectPreview.ClearTile = function(...) effectPreview:clearTile(...) end
effectPreview.FilterTile = function(...) effectPreview:filterTile(...) end
effectPreview.RewindTile = function(...) effectPreview:rewindTile(...) end
effectPreview.AddDamage = function(...) effectPreview:addDamage(...) end
effectPreview.AddCharge = function(...) effectPreview:addCharge(...) end
effectPreview.AddLeap = function(...) effectPreview:addLeap(...) end
effectPreview.AddTeleport = function(...) effectPreview:addTeleport(...) end
effectPreview.AddMove = function(...) effectPreview:addMove(...) end
effectPreview.AddHiddenLeap = function(...) effectPreview:addHiddenLeap(...) end

return effectPreview
