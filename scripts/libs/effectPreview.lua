
--------------------------------------------------------
-- Effect Preview v.1.1 - code library
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
-- consider using the code library weaponMarks instead.
--------------------------------------------------------

-------------------
-- initialization:
-------------------

-- local effectPreview = require(self.scriptPath ..'effectPreview')


------------------
-- function list:
------------------

------------------------------------------------
-- effectPreview.AddDamage(effect, spaceDamage)
------------------------------------------------
-- adds a damage preview to a SkillEffect.
------------------------------------------------

-------------------------------------------
-- effectPreview.AddCharge(effect, p1, p2)
-------------------------------------------
-- adds a charge preview to a SkillEffect
-- from p1 to p2
-------------------------------------------

-----------------------------------------
-- effectPreview.AddLeap(effect, p1, p2)
-----------------------------------------
-- adds a leap preview to a SkillEffect
-- from p1 to p2
-----------------------------------------

---------------------------------------------
-- effectPreview.AddTeleport(effect, p1, p2)
---------------------------------------------
-- adds a teleport preview to a SkillEffect
-- from p1 to p2
---------------------------------------------

-------------------------------------------
-- effectPreview.AddMove(effect, pawn, p2)
-------------------------------------------
-- adds a move preview to a SkillEffect
-- from pawn's space to p2
-------------------------------------------

----------------------------------------------------------------
----------------------------------------------------------------

local this = {}

-- asserts a Point is valid.
local function AssertPoint(p)
	local size = Board:GetSize()
	assert(
		p            and
		p.x >= 0     and
		p.y >= 0     and
		p.x < size.x and
		p.y < size.y
	)
end

-- move all pawns away from a tile.
-- use RewindTile to revert changes.
function this.ClearTile(effect, p1)
	effect:AddScript([[
		lmn_effect_preview_displaced = {};
		local point = Point(]].. p1.x ..",".. p1.y ..[[);
		local pawn = Board:GetPawn(point);
		while pawn do
			pawn:SetSpace(Point(-1, -1));
			table.insert(lmn_effect_preview_displaced, pawn:GetId());
			pawn = Board:GetPawn(point);
		end;
	]])
end

-- move all pawns away from a tile, except pawn with id == 'id'
-- use RewindTile to revert changes.
function this.FilterTile(effect, p1, id)
	effect:AddScript([[
		lmn_effect_preview_displaced = {};
		local point = Point(]].. p1.x ..",".. p1.y ..[[);
		local pawn = Board:GetPawn(point);
		while pawn and pawn:GetId() ~= ]].. id ..[[ do
			pawn:SetSpace(Point(-1, -1));
			table.insert(lmn_effect_preview_displaced, pawn:GetId());
			pawn = Board:GetPawn(point);
		end;
	]])
end

-- moves all displaced pawns back to it's tile.
-- used after ClearTile or FilterTile
function this.RewindTile(effect, p1)
	effect:AddScript([[
		for _, id in ipairs(lmn_effect_preview_displaced) do
			Board:GetPawn(id):SetSpace(Point(]].. p1.x ..",".. p1.y ..[[));
		end;
	]])
end

-- previews damage.
function this.AddDamage(effect, spaceDamage)
	AssertPoint(spaceDamage.loc)
	
	this.ClearTile(effect, spaceDamage.loc)
	effect:AddDamage(spaceDamage)
	this.RewindTile(effect, spaceDamage.loc)
end

-- previews a charge, but does not move any pawns.
function this.AddCharge(effect, p1, p2, pathing)
	AssertPoint(p1)
	AssertPoint(p2)
	pathing = pathing or PATH_FLYER
	
	this.ClearTile(effect, p1)
	effect:AddCharge(Board:GetPath(p1, p2, pathing), NO_DELAY)
	this.RewindTile(effect, p1)
end

-- previews a leap, but does not move any pawns.
function this.AddLeap(effect, p1, p2)
	AssertPoint(p1)
	AssertPoint(p2)
	
	local leap = PointList()
	leap:push_back(p1)
	leap:push_back(p2)
	
	this.ClearTile(effect, p1)
	effect:AddLeap(leap, NO_DELAY)
	this.RewindTile(effect, p1)
end

-- previews teleport, but does not move any pawns.
function this.AddTeleport(effect, p1, p2)
	AssertPoint(p1)
	AssertPoint(p2)
	
	this.ClearTile(effect, p1)
	effect:AddTeleport(p1, p2, NO_DELAY)
	this.RewindTile(effect, p1)
end

-- previews a move action, but does not move any pawns.
-- pathing is optional.
function this.AddMove(effect, pawn, p2, pathing)
	AssertPoint(p2)
	pathing = pathing or pawn:GetPathProf()
	
	local p1 = pawn:GetSpace()
	local move = Board:GetPath(p1, p2, pathing)
	
	this.ClearTile(effect, p1)
	effect:AddMove(move, NO_DELAY)
	this.RewindTile(effect, p1)
end

-- (should probably be in another library)
-- causes a pawn to leap, while hiding it's preview arc.
function this.AddHiddenLeap(effect, p1, p2, delay)
	AssertPoint(p1)
	AssertPoint(p2)
	
	local leap = PointList()
	leap:push_back(p1)
	leap:push_back(p2)
	
	effect:AddLeap(leap, delay)
	effect.effect:index(effect.effect:size()).bHide = true
end

return this