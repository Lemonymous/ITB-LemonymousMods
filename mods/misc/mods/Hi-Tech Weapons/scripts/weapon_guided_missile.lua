
local mod = mod_loader.mods[modApi.currentMod]
local effectBurst = mod.libs.effectBurst
local previewer = mod.libs.weaponPreview

local resetPath = false

lmn_Guided_Missile = Skill:new{
	Name = "Guided Missile",
	Description = "Trace a path and launch a powerful missile along it.",
	Class = "", -- any class to avoid 5 core cost.
	Icon = "weapons/lmn_guided_missile.png",
	Range = INT_MAX,
	PowerCost = 4,
	Push = true,
	Damage = 4,
	ShockStrength = 8,
	Range_Shock = 3,
	Range_Explosive = 1,
	Upgrades = 1,
	UpgradeCost = { 2 },
	UpgradeList = { "Explosive" },
	LaunchSound = "/weapons/rocket_launcher",
	CustomTipImage = "lmn_Guided_Missile_Tip", -- ensures tipimage gets it's own path.
	TipImage = {
		Unit = Point(2,4),
		Mountain = Point(2,2),
		Enemy = Point(2,0),
		Target = Point(2,0),
	},
	CustomRarity = 4,
}

function lmn_Guided_Missile:GetTargetArea(p1)
	local ret = PointList()
	ret:push_back(p1) -- add shooter's tile in order for GetSkillEffect to trigger on it and reset path.
	
	-- darken shooter's tile to indicate it is not a valid target.
	previewer:AddImage(p1, "combat/lmn_square.png", GL_Color(110,160,150))
	
	local size = Board:GetSize()
	for x = 0, size.x - 1 do												-- grab every tile on the board.
		for y = 0, size.y - 1 do
			local p2 = Point(x, y)
			local distance = Board:GetPath(p1, p2, PATH_PROJECTILE):size()	-- that can be reached
			if distance > 0 and distance <= self.Range + 1 then
				ret:push_back(p2)
			end
		end
	end
	
	return ret
end

-- returns the index of 'value' in 'list' or nil
local function list_indexof(list, value)
	assert(type(list) == 'table')
	
	for k, v in ipairs(list) do
		if value == v then
			return k
		end
	end
	return nil
end

-- lookup table for corner marks.
local corner = {
	[0] = { [1] = 1, [3] = 2 },
	[1] = { [0] = 3, [2] = 2 },
	[2] = { [1] = 0, [3] = 3 },
	[3] = { [0] = 0, [2] = 1 },
}

-- removes every tile in a 'path' above 'last'
local function TrimPath(path, last)
	assert(type(path) == 'table')
	assert(last >= 1)
	assert(#path >= last)
	
	for i = #path, last + 1, -1 do
		table.remove(path, i)
	end
end

-- trims 'path' to not have any blocked tiles in it, using the 'pathing' set.
local function UnblockPath(path, pathing)
	assert(type(path) == 'table')
	assert(type(pathing) == 'number')
	
	for i = #path, 2, -1 do -- ignore first tile.
		if Board:IsBlocked(path[i], pathing) then
			TrimPath(path, i - 1)
			i = #path
		end
	end
end

-- extends a 'path' to reach 'p'
local function ExtendPath(path, p)
	assert(type(path) == 'table')
	assert(#path > 0)
	
	local path2 = extract_table(Board:GetPath(path[#path], p, PATH_PROJECTILE))
	for i = 2, #path2 do				-- ignore first index as the paths will share it.
		table.insert(path, path2[i])	-- connect paths
	end
end

-- removes self-intersections in the 'path'.
local function StraightenPath(path)
	assert(type(path) == 'table')
	assert(#path > 0)
	
	for i = #path, 1, -1 do
		local intersection = list_indexof(path, path[i])
		if intersection and intersection ~= i then
			TrimPath(path, intersection)
			i = intersection
		end
	end
end

function lmn_Guided_Missile:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local isTipImage = Board:IsTipImage()
	
	assert(p1:Manhattan(p2) <= self.Range)
	
	------------------
	-- construct path
	------------------
	if self.Path == nil or #self.Path == 0 or self.Path[1] ~= p1 or resetPath then
		self.Path = extract_table(Board:GetPath(p1, p2, PATH_PROJECTILE))
	else
		UnblockPath(self.Path, PATH_PROJECTILE)	-- trim path so it is not blocked.
		ExtendPath(self.Path, p2)				-- extend out to p2.
		StraightenPath(self.Path)				-- remove self-intersections.
		ExtendPath(self.Path, p2)				-- extend to reach p2.
		
		-- reset path if p2 could not be reached.
		if self.Path[#self.Path] ~= p2 then
			self.Path = extract_table(Board:GetPath(p1, p2, PATH_PROJECTILE))
		end
		
		-- ensure path is no longer than self.Range.
		local i = #self.Path
		while(#self.Path - 1 > self.Range) do
			i = i - 1
			TrimPath(self.Path, i)
			ExtendPath(self.Path, p2)
			StraightenPath(self.Path)
			ExtendPath(self.Path, p2)
		end
	end
	
	if not isTipImage then
		previewer:AddImage(p1, "combat/lmn_square.png", GL_Color(110,160,150))
	end
	
	-- exit if we don't have a path.
	if #self.Path < 2 then
		return ret
	end
	
	-- extend path until missile hits an obstacle.
	local path = shallow_copy(self.Path)
	local target = GetProjectileEnd(path[#path - 1], path[#path])
	ExtendPath(path, target)
	
	-------------
	-- mark path
	-------------
	local marks = {}
	local prevTile = path[1]
	local prevDir
	for i = 2, #path do
		local tile = path[i]
		local dir = GetDirection(tile - prevTile)
		prevDir = prevDir or dir
		
		local id = p2idx(tile)
		
		if i == #path then
			-- if we are adjacent our target
			if i == 2 then
				marks[id] = "combat/lmn_guided_close_y_".. dir ..".png"
			end
			
		elseif
			-- if we detect a corner
			path[i + 1].x ~= prevTile.x and
			path[i + 1].y ~= prevTile.y
		then
			local nextDir = GetDirection(path[i + 1] - tile)
			marks[id] = "combat/lmn_guided_corner_y_".. corner[nextDir][dir] ..".png"
			
		else
			-- otherwise we are at a straight path.
			marks[id] = "combat/lmn_guided_arrow_y_".. dir ..".png"
		end
		
		local mark = SpaceDamage(tile)
		mark.sImageMark = marks[id] or ""
		ret:AddDamage(mark)
		
		prevDir = dir
		prevTile = tile
	end
	
	---------------------------------
	-- launch projectiles along path
	---------------------------------
	local waypoint = path[1]
	local prevTile = path[1]
	for i = 2, #path do
		local tile = path[i]
		local nextTile = path[i + 1]
		if	-- if end of path or
			-- a turn is detected
			not nextTile				or
			(nextTile.x ~= prevTile.x	and
			nextTile.y ~= prevTile.y)
		then
			local dir = GetDirection(tile - waypoint)
			local distance = waypoint:Manhattan(tile)
			local delay = 0.005 * (distance - 1) -- hack to sync missile, smoke trail and impact.
			
			-- missile along straight path before the turn.
			ret:AddScript([[
				local p0 = ]].. p1:GetString() ..[[;
				local p1 = ]].. waypoint:GetString() ..[[;
				local p2 = ]].. tile:GetString() ..[[;
				local dir = ]].. dir ..[[;
				local distance = ]].. distance ..[[;
				local missile = SkillEffect();
				missile.iOwner = ]].. Board:GetPawn(p1):GetId() ..[[;
				missile.piOrigin = p1;
				missile:AddProjectile(p1, SpaceDamage(p2), "effects/lmn_shot_guided_missile", NO_DELAY);
				
				Board:AddEffect(missile);
			]])
			
			-- smoke trail along straight path before turn.
			for k = 0, distance - 1 do
				local curr = waypoint + DIR_VECTORS[dir] * k
				ret:AddDelay(0.08 + delay)
				delay = 0
				
				if curr ~= p1 then
					if curr == waypoint then
						effectBurst.Add(ret, curr, "lmn_Emitter_Guided_Static_".. dir, DIR_NONE, isTipImage)
					else
						effectBurst.Add(ret, curr, "lmn_Emitter_Guided_".. dir, dir, isTipImage)
					end
				end
			end
			waypoint = tile
		end
		
		prevTile = tile
	end
	
	---------------------
	-- impact resolution
	---------------------
	
	if self.Explosive then
		--------------------
		-- explosive damage
		--------------------
		
		local list = {}
		-- check distance to all tiles on board in relation to 'target'.
		local size = Board:GetSize()
		for x = 0, size.x - 1 do
			local dist_x = math.abs(target.x - x)
			for y = 0, size.y - 1 do
				local dist_y = math.abs(target.y - y)
				local dist = math.sqrt(dist_x * dist_x + dist_y * dist_y)
				
				-- if tile is within shockwave radius, add it to the list.
				if dist <= self.Range_Shock then
					table.insert(list, {tile = Point(x, y), dist = dist})
				end
			end
		end
		
		-- sort list from highest to lowest distance from 'target'.
		table.sort(list, function(a,b) return a.dist > b.dist end)
		
		local radius = 0
		-- keep checking the closest tile in the list,
		-- until the list is empty.
		while #list > 0 do
			-- for every tile that is within shockwave distance;
			while #list > 0 and list[#list].dist <= radius do
				
				local n = list[#list]
				
				local dist = target:Manhattan(n.tile)
				
				if dist <= self.Range_Explosive then
					-- apply explosion damage.
					local damage = SpaceDamage(n.tile, self.Damage)
					
					if n.tile == target then
						damage.iPush = self.Push and dir or DIR_NONE
						damage.sSound = "/impact/generic/explosion_large"
					else
						damage.sSound = "/impact/generic/explosion"
					end
					
					damage.sAnimation = "explo_fire1"
					damage.sImageMark = marks[p2idx(n.tile)] or ""
					
					ret:AddDamage(damage)
				end
				
				if n.dist <= self.Range_Shock then
					-- apply tile bounce,
					ret:AddBounce(n.tile, self.ShockStrength / math.max(1, n.dist))
				end
				
				-- and remove the tile from the list.
				table.remove(list, #list)
			end
			
			-- increase shockwave radius,
			radius = radius + 0.1
			-- and wait a little.
			ret:AddDelay(0.015)
			-- repeat.
		end
	else
		----------------------
		-- single target push
		----------------------
		
		local dir = GetDirection(target - path[#path - 1])
		local damage = SpaceDamage(target, self.Damage)
		damage.iPush = self.Push and dir or DIR_NONE
		damage.sAnimation = "explopush2_".. dir
		damage.sSound = "/impact/generic/explosion_large"
		damage.sImageMark = marks[p2idx(target)] or ""
		ret:AddDamage(damage)
	end
	
	return ret
end

lmn_Guided_Missile_A = lmn_Guided_Missile:new{
	UpgradeDescription = "Replaces push with area damage.",
	Push = false,
	Explosive = true,
	CustomTipImage = "lmn_Guided_Missile_Tip_A",
	TipImage = {
		Unit = Point(2,4),
		Mountain = Point(2,2),
		Enemy = Point(2,0),
		Enemy2 = Point(2,1),
		Target = Point(2,0),
	},
}

lmn_Guided_Missile_Tip = lmn_Guided_Missile:new{}
lmn_Guided_Missile_Tip_A = lmn_Guided_Missile_A:new{}

function lmn_Guided_Missile_Tip:GetSkillEffect(p1, p2)
	return lmn_Guided_Missile.GetSkillEffect(self, p1, p2)
end

lmn_Guided_Missile_Tip_A.GetSkillEffect = lmn_Guided_Missile_Tip.GetSkillEffect

modApi:addWeaponDrop("lmn_Guided_Missile")

modApi:appendAsset("img/weapons/lmn_guided_missile.png", mod.resourcePath .."img/weapons/guided_missile.png")
modApi:appendAsset("img/effects/lmn_shot_guided_missile_R.png", mod.resourcePath .."img/effects/shot_guided_missile_R.png")
modApi:appendAsset("img/effects/lmn_shot_guided_missile_U.png", mod.resourcePath .."img/effects/shot_guided_missile_U.png")

-- TODO: add color blind marks.
modApi:appendAsset("img/combat/lmn_guided_arrow_y_0.png", mod.resourcePath .."img/combat/projectile_arrow_02.png")
modApi:appendAsset("img/combat/lmn_guided_arrow_y_1.png", mod.resourcePath .."img/combat/projectile_arrow_13.png")
modApi:appendAsset("img/combat/lmn_guided_arrow_y_2.png", mod.resourcePath .."img/combat/projectile_arrow_02.png")
modApi:appendAsset("img/combat/lmn_guided_arrow_y_3.png", mod.resourcePath .."img/combat/projectile_arrow_13.png")
modApi:appendAsset("img/combat/lmn_guided_close_y_0.png", mod.resourcePath .."img/combat/projectile_close_02.png")
modApi:appendAsset("img/combat/lmn_guided_close_y_1.png", mod.resourcePath .."img/combat/projectile_close_13.png")
modApi:appendAsset("img/combat/lmn_guided_close_y_2.png", mod.resourcePath .."img/combat/projectile_close_02.png")
modApi:appendAsset("img/combat/lmn_guided_close_y_3.png", mod.resourcePath .."img/combat/projectile_close_13.png")
modApi:appendAsset("img/combat/lmn_guided_corner_y_0.png", mod.resourcePath .."img/combat/projectile_corner_02.png")
modApi:appendAsset("img/combat/lmn_guided_corner_y_1.png", mod.resourcePath .."img/combat/projectile_corner_13.png")
modApi:appendAsset("img/combat/lmn_guided_corner_y_2.png", mod.resourcePath .."img/combat/projectile_corner_02.png")
modApi:appendAsset("img/combat/lmn_guided_corner_y_3.png", mod.resourcePath .."img/combat/projectile_corner_13.png")

Location["combat/lmn_guided_arrow_y_0.png"] = Point(-16, 0)
Location["combat/lmn_guided_arrow_y_1.png"] = Point(-16, 0)
Location["combat/lmn_guided_arrow_y_2.png"] = Point(-16, 0)
Location["combat/lmn_guided_arrow_y_3.png"] = Point(-16, 0)
Location["combat/lmn_guided_close_y_0.png"] = Point(-27, 15)
Location["combat/lmn_guided_close_y_1.png"] = Point(-28, -6)
Location["combat/lmn_guided_close_y_2.png"] = Point(1, -6)
Location["combat/lmn_guided_close_y_3.png"] = Point(0, 15)
Location["combat/lmn_guided_corner_y_0.png"] = Point(-16, 0)
Location["combat/lmn_guided_corner_y_1.png"] = Point(-16, 0)
Location["combat/lmn_guided_corner_y_2.png"] = Point(-2, 0)
Location["combat/lmn_guided_corner_y_3.png"] = Point(-16, 11)

modApi:copyAsset("img/combat/square.png", "img/combat/lmn_square.png")
Location["combat/lmn_square.png"] = Point(-27, 2)

-- angles matching the board directions,
-- with variance going an equal amount to either side.
local angle_variance = 40
local angle_0 = 323 + angle_variance / 2
local angle_1 = 37 + angle_variance / 2
local angle_2 = 142 + angle_variance / 2
local angle_3 = 218 + angle_variance / 2

lmn_Emitter_Guided_Static_0 = Emitter:new{
	image = "effects/smoke/art_smoke.png",
	max_alpha = 0.4,
	x = 0,
	y = 20,
	angle = angle_0,
	angle_variance = angle_variance,
	variance = 25,
	burst_count = 19,
	lifespan = 1.6,
	speed = 0.14,
	birth_rate = 0,
	max_particles = 64,
	gravity = false,
	layer = LAYER_FRONT
}

lmn_Emitter_Guided_Static_1 = lmn_Emitter_Guided_Static_0:new{ angle = angle_1 }
lmn_Emitter_Guided_Static_2 = lmn_Emitter_Guided_Static_0:new{ angle = angle_2 }
lmn_Emitter_Guided_Static_3 = lmn_Emitter_Guided_Static_0:new{ angle = angle_3 }

lmn_Emitter_Guided_0 = lmn_Emitter_Guided_Static_0:new{
	x = 0,
	y = 10,
	angle = angle_0,
	variance = 5,
	burst_count = 10,
	lifespan = 1.8,
}

lmn_Emitter_Guided_1 = lmn_Emitter_Guided_0:new{ angle = angle_1 }
lmn_Emitter_Guided_2 = lmn_Emitter_Guided_0:new{ angle = angle_2 }
lmn_Emitter_Guided_3 = lmn_Emitter_Guided_0:new{ angle = angle_3 }
