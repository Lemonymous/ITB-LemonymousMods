
local mod = mod_loader.mods[modApi.currentMod]
local worldConstants = mod.libs.worldConstants
local effectPreview = mod.libs.effectPreview

lmn_DozerAtk = Skill:new{
	Name = "Dozer Blades",
	Icon = "weapons/dm_dozer.png",
	Class = "Brute",
	Range = INT_MAX,				-- max range of charge.
	MaxPawnsPushed = 2,				-- max pawns pushed in a chain.
	Damage = 0,						-- adds damage if pushing a pawn into a solid.
	VelX = 0.35,					-- velocity of charge.
	Push = true,					-- flag to allow pushing pawns into solids.
	ChainPush = false,				-- adds pushes to every pawn pushed, when colliding with solid
	CollideWall = false,			-- flag to allow charging into solids.
	CollideEdge = false,			-- flag to allow crashing into pawn at edge.
	LaunchSound = "/weapons/charge",
	ImpactSound = "/weapons/charge_impact",
}

-- returns whether a pawn is pushable or not
local function IsPushable(pawn)
	return _G[pawn:GetType()].Pushable
end

-- returns whether tile is solid or not.
local function IsSolid(point)
	local terrain = Board:GetTerrain(point)
	local pawn = Board:GetPawn(point)						-- solids:
	return	terrain == TERRAIN_BUILDING						-- building
		or	terrain == TERRAIN_MOUNTAIN						-- mountain
		or	(pawn and not IsPushable(pawn))					-- stable pawn
end

-- returns whether pathing type can fly or not.
local function CanFly(pathing)
	pathing = pathing % 16			-- TODO: make sure this conversion is correct for all teams.
	return	pathing == PATH_FLYER
		or	pathing == PATH_PHASING
		or	pathing == PATH_PROJECTILE
end

-- returns whether pathing type can swim or not.
local function CanSwim(pathing)
	pathing = pathing % 16			-- TODO: make sure this conversion is correct for all teams.
	return	CanFly(pathing)
		or	pathing == PATH_MASSIVE
		or	pathing == PATH_ROADRUNNER
end

-- returns whether pathing type considers tile a pit.
local function IsPit(point, pathing)
	pathing = pathing % 16			-- TODO: make sure this conversion is correct for all teams.
	local terrain = Board:GetTerrain(point)
	return	(terrain == TERRAIN_HOLE	and
			not CanFly(pathing))
		or	(terrain == TERRAIN_WATER	and
			not CanSwim(pathing))
end

function lmn_DozerAtk:GetDozerData(point, dir, range)
	local ret = {}
	ret.pushablePawns = {}
	local step = DIR_VECTORS[dir]
	local trainLength = 0
	local t = 0
	
	ret.virtualBoard = {}
	function ret:GetPawn(offset)
		if self.virtualBoard[offset] == false then
			return nil
		end
		return self.virtualBoard[offset] or Board:GetPawn(point + step * offset)
	end
	
	function ret:SetPawn(pawn, offset)
		self.virtualBoard[offset] = pawn
	end
	
	-- a recursive search for building a list of
	-- pawns and how far they can be pushed.
	local function CanMoveOneStep(offset)
		local curr = point + step * offset
		
		if not Board:IsValid(curr) then
			ret.distanceToSolid = offset
			return false
			
		elseif IsSolid(curr) then
			ret.distanceToSolid = offset
			return false
			
		end
		
		local pawn = ret:GetPawn(offset)
		if not pawn then
			return true
		else
			if trainLength < self.MaxPawnsPushed then
				trainLength = trainLength + 1
				if CanMoveOneStep(offset + 1) then
					ret:SetPawn(false, offset)
					
					if IsPit(curr + step, pawn:GetPathProf()) then
						ret.pushablePawns[pawn:GetId()].maxOffset = offset + 1
					else
						ret:SetPawn(pawn, offset + 1)
					end
					trainLength = trainLength - 1
					return true
				end
				trainLength = trainLength - 1
			end
		end
		
		return false
	end
	
	-- make a list of all pawns we can push.
	for k = 1, INT_MAX do
		if not Board:IsValid(point + step * k) then
			break
		end
		
		local pawn = Board:GetPawn(point + step * k)
		if pawn then
			ret:SetPawn(pawn, k)								-- set pawn's virtual location
			ret.pushablePawns[pawn:GetId()] = {
				pawn = pawn,
				offset = k,
				loc = pawn:GetSpace(),
			}
		end
	end
	
	-- figure out how far we can move.
	while t < range do
		local curr = point + step * (t + 1)
		if	Board:IsValid(curr)					and
			not IsPit(curr, Pawn:GetPathProf())	and
			CanMoveOneStep(t + 1)				then
			
			ret:SetPawn(false, t)
			ret:SetPawn(Pawn, t + 1)
		else
			break
		end
		t = t + 1
	end
	
	ret.distanceMoved = t
	
	return ret
end

local imageMarkTip
local imageMark
function lmn_DozerAtk:GetTargetArea(point)
	
	local ret = PointList()
	local pathing = Pawn:GetPathProf()
	local isTipImage = Board:IsTipImage()
	
	if isTipImage then
		imageMarkTip = {}
	else
		imageMark = {}
	end
	
	for dir = DIR_START, DIR_END do
		local step = DIR_VECTORS[dir]
		local isImageMark
		
		if isTipImage then
			imageMarkTip[dir] = {}
			isImageMark = imageMarkTip[dir]
		else
			imageMark[dir] = {}
			isImageMark = imageMark[dir]
		end
		
		for k = 1, INT_MAX do										-- populate a table for imageMarks
			local curr = point + step * k
			if not Board:IsValid(curr) then
				break
			end
			
			if not Board:IsPawnSpace(curr) then
				isImageMark[k] = true
			end
		end
		
		local data = self:GetDozerData(point, dir, self.Range)
		
		for k = 1, data.distanceMoved do							-- add all tiles we can move to.
			ret:push_back(point + step * k)
		end
		
		local crashDist = data.distanceMoved + 1					-- add another tile if we can crash.
		local pawn = data:GetPawn(crashDist)
		local curr = point + step * crashDist
		local terrain = Board:GetTerrain(curr)
		
		if	Board:IsValid(curr)					and
			crashDist <= self.Range				and
			not IsPit(curr, Pawn:GetPathProf())	then
			
			if pawn and IsPushable(pawn) then
				if self.Push then
					if	Board:IsValid(curr + step)
					or	self.CollideEdge			then
						
						ret:push_back(curr)
					end
				end
				
			elseif
				self.CollideWall				and
				(terrain == TERRAIN_MOUNTAIN
			or	terrain == TERRAIN_BUILDING)	then
				
				ret:push_back(curr)
			end
		end
	end
	
	return ret
end

function lmn_DozerAtk:GetSkillEffect(p1, p2)
	
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	local step = DIR_VECTORS[dir]
	local distance = p1:Manhattan(p2)
	local isTipImage = Board:IsTipImage()
	
	local isImageMark
	if isTipImage then
		isImageMark = imageMarkTip[dir]
	else
		isImageMark = imageMark[dir]
	end
	
	local data = self:GetDozerData(p1, dir, distance)						-- get data for this target tile.
	local moveLoc = p1 + step * data.distanceMoved
	
	local pawnLocs = {}
	for _, v in pairs(data.pushablePawns) do								-- hash pawns by distance from dozer.
		pawnLocs[v.offset] = shallow_copy(v)
	end
	
	local charges = {}
	local furthestPush = 0
	local trainLength = 0
	local function addCharge(loc, maxDist)									-- recursive function calculating all charges.
		local v = pawnLocs[loc]
		if v then
			local time = v.offset - trainLength
			charges[time] = charges[time] or {}
			
			local moveDist = maxDist + 1
			if v.maxOffset then
				moveDist = math.min(moveDist, v.maxOffset)
			end
			
			furthestPush = math.max(furthestPush, moveDist)
			table.insert(charges[time], {id = v.pawn:GetId(), initLoc = v.loc, start = loc, stop = moveDist})
			pawnLocs[loc] = nil
			
			trainLength = trainLength + 1
			for k = loc + 1, moveDist do
				addCharge(k, moveDist)
			end
			trainLength = trainLength - 1
			
			pawnLocs[moveDist] = v
			v.offset = moveDist
			distance = math.max(distance, moveDist)
		end
	end
	
	for k = 1, data.distanceMoved do
		addCharge(k, data.distanceMoved)									-- init charge recursion.
	end
	
	worldConstants:setSpeed(ret, self.VelX)
	ret:AddCharge(Board:GetPath(p1, moveLoc, PATH_FLYER), NO_DELAY)			-- charge dozer.
	worldConstants:resetSpeed(ret)
	
	local damage = SpaceDamage(p1)											-- throw dust behind dozer.
	damage.sAnimation = "exploout0_".. (dir+2)%4
	ret:AddDamage(damage)
	
	for k = 1, distance do
		
		if charges[k] then													-- charge pushable pawns at their correct timings.
			
			for _, v in ipairs(charges[k]) do
				local start = p1 + step * v.start
				local stop = p1 + step * v.stop
				
				worldConstants:setSpeed(ret, self.VelX)
				effectPreview:filterTile(ret, start, v.id)				-- sort the tile and charge the specific pawnId.
				ret:AddCharge(Board:GetPath(start, stop, PATH_FLYER), NO_DELAY)
				effectPreview:rewindTile(ret, start)
				worldConstants:resetSpeed(ret)
				
				if start ~= v.initLoc then
					effectPreview:addCharge(ret, v.initLoc, stop)		-- update the preview of the increased charge length.
				end
			end
		end
		
		if k <= data.distanceMoved + 1 then
			local curr = p1 + step * (k - 1)
			ret:AddBounce(curr, -3)
		end
		
		if k <= data.distanceMoved then
			ret:AddDelay(0.08 * worldConstants:getDefaultSpeed() / self.VelX)
		end
	end
	
	effectPreview:addCharge(ret, p1, moveLoc)
	
	if moveLoc ~= p2 then													-- if we should crash,
		
		local dirs = {"up", "right", "down", "left"}
		local pawn = data:GetPawn(data.distanceMoved + 1)
		if pawn then
			if self.Push then
				
				local spaceDamage = SpaceDamage(p2)	
				spaceDamage.sSound = self.ImpactSound
				ret:AddDamage(spaceDamage)									-- collision sound
				
				local spaceDamage = SpaceDamage(p2, self.Damage)
				
				if Board:IsValid(p2 + step) then
					spaceDamage.iPush = dir
					if isImageMark[data.distanceMoved + 1] then
						spaceDamage.sImageMark = "combat/arrow_hit_".. dirs[dir+1] ..".png"
					end
				end
				
				if self.Damage > 0 then
					spaceDamage.sAnimation = "ExploAir".. math.min(2, self.Damage)
				end
				
				if p1 == moveLoc then
					ret:AddMelee(p1, spaceDamage, NO_DELAY)					-- main push
				else
					ret:AddDamage(spaceDamage)
				end
				
				if self.ChainPush then
					local pushed = 0
					for k = data.distanceMoved + 2, furthestPush do
						local curr = p1 + step * k
						if not Board:IsValid(curr) then
							break
						end
						
						local pawn = data:GetPawn(k)
						if pawn and IsPushable(pawn) then
							if	Board:IsValid(curr + step)
							or	self.CollideEdge			then
								
								ret:AddDelay(0.5)
								local spaceDamage = SpaceDamage(curr, self.Damage, dir)
								if isImageMark[k] then
									spaceDamage.sImageMark = "combat/arrow_hit_".. dirs[dir+1] ..".png"
								end
								ret:AddDamage(spaceDamage)					-- chain pushes
							end
						else
							break
						end
					end
				end
			end
		else
			local terrain = Board:GetTerrain(p2)
			if	self.CollideWall				and
				(terrain == TERRAIN_MOUNTAIN
			or	terrain == TERRAIN_BUILDING)	then
				
				local spaceDamage = SpaceDamage(p2, self.Damage)
				spaceDamage.sSound = self.ImpactSound
				
				if self.Damage > 0 then
					spaceDamage.sAnimation = "ExploAir".. math.min(2, self.Damage)
				end
				
				if p1 == moveLoc then
					ret:AddMelee(p1, spaceDamage)							-- building collision
				else
					ret:AddDamage(spaceDamage)
				end
			end
		end
	end
	
	if isTipImage then
		ret:AddDelay(1.5)
	end
	
	return ret
end

lmn_DozerAtk_A = lmn_DozerAtk:new()
lmn_DozerAtk_B = lmn_DozerAtk:new()
lmn_DozerAtk_AB = lmn_DozerAtk:new()

lmn_DozerAtk_1 = {
	Description = "Move and shove up to 2 units, any distance.",
	VelX = 0.35,
	Range = INT_MAX,
	MaxPawnsPushed = 2,
	Upgrades = 1,
	UpgradeCost = { 3 },
	UpgradeList = { "Pile up" },
	CustomTipImage = "lmn_DozerAtk_Tip",
	TipImage = {
		Unit = Point(2,4),
		Enemy = Point(2,2),
		Enemy2 = Point(2,1),
		Target = Point(2,1),
	}
}

lmn_DozerAtk_1A = {
	UpgradeDescription = "Allows bulldozing any number of units.",
	VelX = 0.35,
	Range = INT_MAX,
	MaxPawnsPushed = INT_MAX,
	CustomTipImage = "lmn_DozerAtk_Tip_A",
	TipImage = {
		Unit = Point(2,5),
		Enemy = Point(2,4),
		Enemy2 = Point(2,3),
		Enemy3 = Point(2,2),
		Enemy4 = Point(2,1),
		Water = Point(2,0),
		Target = Point(2,1),
	}
}

lmn_DozerAtk_2 = {
	Description = "Move and shove 1 unit, any distance.",
	VelX = 0.35,
	Range = INT_MAX,
	MaxPawnsPushed = 1,
	Upgrades = 2,
	UpgradeCost = { 1, 2 },
	UpgradeList = { "+1 target", "+2 targets" },
	CustomTipImage = "lmn_DozerAtk_Tip",
	TipImage = {
		Unit = Point(2,4),
		Enemy = Point(2,2),
		Mountain = Point(2,0),
		Target = Point(2,1),
	}
}

lmn_DozerAtk_2A = {
	UpgradeDescription = "Allows bulldozing 1 additional unit.",
	VelX = 0.35,
	Range = INT_MAX,
	MaxPawnsPushed = 2,
	CustomTipImage = "lmn_DozerAtk_Tip_A",
	TipImage = {
		Unit = Point(2,4),
		Enemy = Point(2,2),
		Enemy2 = Point(2,1),
		Water = Point(2,0),
		Target = Point(2,1),
	}
}

lmn_DozerAtk_2B = {
	UpgradeDescription = "Allows bulldozing 2 additional units.",
	VelX = 0.35,
	Range = INT_MAX,
	MaxPawnsPushed = 3,
	CustomTipImage = "lmn_DozerAtk_Tip_B",
	TipImage = {
		Unit = Point(2,4),
		Enemy = Point(2,3),
		Enemy2 = Point(2,2),
		Enemy3 = Point(2,1),
		Water = Point(2,0),
		Target = Point(2,1),
	}
}

lmn_DozerAtk_2AB = {
	VelX = 0.35,
	Range = INT_MAX,
	MaxPawnsPushed = 4,
	CustomTipImage = "lmn_DozerAtk_Tip_AB",
	TipImage = lmn_DozerAtk_1A.TipImage,
}

lmn_DozerAtk_3 = {
	Description = "Move up to 2 tiles and push units along.",
	VelX = 0.27,
	Range = 2,
	MaxPawnsPushed = INT_MAX,
	Upgrades = 2,
	UpgradeCost = { 1, 2 },
	UpgradeList = { "+1 Range", "+2 Range" },
	CustomTipImage = "lmn_DozerAtk_Tip",
	TipImage = {
		Unit = Point(2,3),
		Enemy = Point(2,1),
		Water = Point(2,0),
		Target = Point(2,1),
	}
}

lmn_DozerAtk_3A = {
	UpgradeDescription = "Increases range by 1 tile.",
	VelX = 0.27,
	Range = 3,
	MaxPawnsPushed = INT_MAX,
	CustomTipImage = "lmn_DozerAtk_Tip_A",
	TipImage = {
		Unit = Point(2,4),
		Enemy = Point(2,2),
		Enemy2 = Point(2,1),
		Water = Point(2,0),
		Target = Point(2,1),
	}
}

lmn_DozerAtk_3B = {
	UpgradeDescription = "Increases range by 2 tiles.",
	VelX = 0.27,
	Range = 4,
	MaxPawnsPushed = INT_MAX,
	CustomTipImage = "lmn_DozerAtk_Tip_B",
	TipImage = {
		Unit = Point(2,4),
		Enemy = Point(2,3),
		Enemy2 = Point(2,2),
		Enemy3 = Point(2,1),
		Water = Point(2,0),
		Target = Point(2,0),
	}
}

lmn_DozerAtk_3AB = {
	VelX = 0.27,
	Range = 5,
	MaxPawnsPushed = INT_MAX,
	CustomTipImage = "lmn_DozerAtk_Tip_AB",
	TipImage = {
		Unit = Point(2,5),
		Enemy = Point(2,4),
		Enemy2 = Point(2,3),
		Enemy3 = Point(2,2),
		Enemy4 = Point(2,1),
		Water = Point(2,0),
		Target = Point(2,0),
	}
}

lmn_DozerAtk_Tip = lmn_DozerAtk:new()
lmn_DozerAtk_Tip_A = lmn_DozerAtk:new()
lmn_DozerAtk_Tip_B = lmn_DozerAtk:new()
lmn_DozerAtk_Tip_AB = lmn_DozerAtk:new()

function lmn_DozerAtk_Tip:GetTargetArea(p)
	if self.TipImage.Water then
		Board:SetTerrain(self.TipImage.Water, TERRAIN_ACID)
		Board:SetTerrain(self.TipImage.Water, TERRAIN_WATER)
	end
	return lmn_DozerAtk.GetTargetArea(self, p)
end

function lmn_DozerAtk_Tip:GetSkillEffect(p1, p2)
	return lmn_DozerAtk.GetSkillEffect(self, p1, p2)
end

lmn_DozerAtk_Tip.GetTargetArea = lmn_DozerAtk_Tip.GetTargetArea
lmn_DozerAtk_Tip.GetSkillEffect = lmn_DozerAtk_Tip.GetSkillEffect
lmn_DozerAtk_Tip_A.GetTargetArea = lmn_DozerAtk_Tip.GetTargetArea
lmn_DozerAtk_Tip_A.GetSkillEffect = lmn_DozerAtk_Tip.GetSkillEffect
lmn_DozerAtk_Tip_B.GetTargetArea = lmn_DozerAtk_Tip.GetTargetArea
lmn_DozerAtk_Tip_B.GetSkillEffect = lmn_DozerAtk_Tip.GetSkillEffect
lmn_DozerAtk_Tip_AB.GetTargetArea = lmn_DozerAtk_Tip.GetTargetArea
lmn_DozerAtk_Tip_AB.GetSkillEffect = lmn_DozerAtk_Tip.GetSkillEffect

-- injects values from 'src' into 'dst'
local function injectValues(dst, src)
	assert(type(src) == 'table')
	assert(type(dst) == 'table')
	
	for i, v in pairs(src) do
		dst[i] = v
	end
end

modApi.events.onModLoaded:subscribe(function(id)
	if id ~= mod.id then return end

	local options = mod_loader.currentModContent[id].options

	if options["option_dozer"].value == 2 then
		injectValues(lmn_DozerAtk, lmn_DozerAtk_2)
		injectValues(lmn_DozerAtk_A, lmn_DozerAtk_2A)
		injectValues(lmn_DozerAtk_B, lmn_DozerAtk_2B)
		injectValues(lmn_DozerAtk_AB, lmn_DozerAtk_2AB)
		injectValues(lmn_DozerAtk_Tip, lmn_DozerAtk_2)
		injectValues(lmn_DozerAtk_Tip_A, lmn_DozerAtk_2A)
		injectValues(lmn_DozerAtk_Tip_B, lmn_DozerAtk_2B)
		injectValues(lmn_DozerAtk_Tip_AB, lmn_DozerAtk_2AB)
		
	elseif options["option_dozer"].value == 3 then
		injectValues(lmn_DozerAtk, lmn_DozerAtk_3)
		injectValues(lmn_DozerAtk_A, lmn_DozerAtk_3A)
		injectValues(lmn_DozerAtk_B, lmn_DozerAtk_3B)
		injectValues(lmn_DozerAtk_AB, lmn_DozerAtk_3AB)
		injectValues(lmn_DozerAtk_Tip, lmn_DozerAtk_3)
		injectValues(lmn_DozerAtk_Tip_A, lmn_DozerAtk_3A)
		injectValues(lmn_DozerAtk_Tip_B, lmn_DozerAtk_3B)
		injectValues(lmn_DozerAtk_Tip_AB, lmn_DozerAtk_3AB)
		
	else
		injectValues(lmn_DozerAtk, lmn_DozerAtk_1)
		injectValues(lmn_DozerAtk_A, lmn_DozerAtk_1A)
		injectValues(lmn_DozerAtk_Tip, lmn_DozerAtk_1)
		injectValues(lmn_DozerAtk_Tip_A, lmn_DozerAtk_1A)
	end
end)

modApi:addWeaponDrop("lmn_DozerAtk")
