-- collection of functions I either find I use often,
-- or don't know a better place to put them yet.
-- some of them might be just drafts.

local this = {}

-- a variant of GetProjectileEnd with an additional range parameter.
-- returns the first valid tile along a line going through p1 -> p2.
function this.GetProjectileEnd(p1, p2, range, pathing)
	range = range or INT_MAX
	pathing = pathing or PATH_PROJECTILE
	local dir = GetDirection(p2 - p1)
	local target = p1

	for k = 1, range do
		local curr = p1 + DIR_VECTORS[dir] * k

		if not Board:IsValid(curr) then
			break
		end

		target = curr

		if Board:IsBlocked(target, pathing) then
			break
		end
	end

	return target
end

-- returns if a tile is a pit.
function this.IsHoleOrWater(p)
	local terrain = Board:GetTerrain(p)
	return terrain == TERRAIN_WATER or terrain == TERRAIN_HOLE -- lava and acid water counts as water here.
end

-- returns if a tile has a building connected to the grid.
function this.IsPoweredBuilding(p)
	return Board:IsBuilding(p) and Board:IsPowered(p)
end

-- adds a sound to an effect list on a point.
-- the sound will use the impact index of the unit hit.
function this.EffectAddAttackSound(fx, p, sound, isQueued)
	assert(type(fx) == 'userdata')
	assert(type(p) == 'userdata')

	local q = isQueued and 'Queued' or ''
	local d = SpaceDamage(p)
	d.bHide = true
	d.sSound = sound

	fx['Add'..q..'Damage'](fx, d)
end

-- queued version of EffectAddAttackSound.
function this.EffectQueuedAddAttackSound(fx, p, sound)
	this.EffectAddAttackSound(fx, p, sound, true)
end

-- this function is probably not good enough for general use yet.
-- needs improvement.
function this.EffectPreviewExtraDamage(fx, p, isQueued)
	assert(type(fx) == 'userdata')
	assert(type(p) == 'userdata')

	local q = isQueued and "Queued" or ""
	local d = SpaceDamage(p, 1)
	d.bHide = true

	local pawn = Board:GetPawn(p)
	if pawn then
		fx['Add'..q..'Script'](string.format(
			"Board:GetPawn(%s):SetSpace(Point(-1,-1))",
			pawn:GetId()
		))
	end

	fx['Add'..q..'Damage'](fx, d)

	if pawn then
		fx['Add'..q..'Script'](string.format(
			"Board:GetPawn(%s):SetSpace(%s)",
			pawn:GetId(),
			p:GetString()
		))
	end
end

function this.EffectQueuedPreviewExtraDamage(fx, p)
	this.EffectPreviewExtraDamage(fx, p, true)
end

-- crude functions for checking if we are in a tipimage.
-- sometimes this is the only method available.
function this.IsTipImage()
	return Board:GetSize() == Point(6,6)
end

-- scrambles an array.
function this.shuffle(tbl)

    for i = #tbl, 2, -1 do
        local j = math.random(1, i)

		-- neat way to swap two variables.
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end

	return tbl
end

local function isValidDeployment(p)
	local terrain = Board:GetTerrain(p)

	return
		terrain ~= TERRAIN_MOUNTAIN	and
		terrain ~= TERRAIN_BUILDING	and
		not Board:IsPod(p)			and
		not Board:IsDangerous(p)	and
		not Board:IsDangerousItem(p)and
		not Board:IsSpawning(p)		and
		not Board:IsAcid(p)
		-- should check if tile has been spawn blocked,
		-- but the information is not readily available
end

-- returns the deployment zone.
function this.getDeploymentZone()
	assert(Board)

	local deployment = extract_table(Board:GetZone("deployment"))

	if #deployment == 0 then
		for x = 1, 3 do
			for y = 1, 6 do
				local curr = Point(x, y)

				if isValidDeployment(curr) then
					table.insert(deployment, curr)
				end
			end
		end
	end

	return deployment
end

function this.isAdjacent(p, q)
	assert(type(p) == 'userdata')
	assert(type(q) == 'userdata')

	if p.x == q.x then
		return math.abs(p.y - q.y) == 1
	elseif p.y == q.y then
		return math.abs(p.x - q.x) == 1
	end

	return false
end

-- returns whether a table is empty or not.
function this.list_isEmpty(list)
	return not next(list)
end

-- iterate a table and return true if the
-- predicate function returns true for any item in the table.
function this.table_predicates(list, fn)
	for i, v in pairs(list) do
		if fn(v) then
			return true
		end
	end

	return false
end

-- iterate a list and return true if the
-- predicate function returns true for any item in the list.
function this.list_predicates(list, fn)
	for _, v in ipairs(list) do
		if fn(v) then
			return true
		end
	end

	return false
end

-- returns a list of all locations on the board.
-- if optional parameter fn is used, add only points affirming the function.
function this.getBoard(fn)
	local ret = {}

	local size = Board:GetSize()
	for x = 0, size.x - 1 do
		for y = 0, size.y - 1 do
			local p = Point(x,y)
			if not fn or fn(p) then
				table.insert(ret, p)
			end
		end
	end

	return ret
end

-- returns a point on the board satisfying the conditions of predicate.
-- returns nil if no points satisfies the conditions.
function this.getSpace(predicate)
	assert(type(predicate) == "function")

	local size = Board:GetSize()
	for y = 0, size.y - 1 do
		for x = 0, size.x - 1 do
			local p = Point(x, y)
			if predicate(p) then
				return p
			end
		end
	end

	return nil
end

-- returns the first point point in a PointList matching a predicate.
function this.PointListFind(pointList, predicate)
	for i, loc in ipairs(extract_table(pointList)) do
		if predicate(loc, i) then
			return loc
		end
	end

	return nil
end

return this