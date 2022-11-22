
local mod = mod_loader.mods[modApi.currentMod]
local worldConstants = mod.libs.worldConstants
local effectBurst = mod.libs.effectBurst
local previewer = mod.libs.weaponPreview

local resetPath = false

lmn_Tri_Striker = Skill:new{
	Name = "Tri-Striker",
	Description = "Target 3 connected tiles and lob artillery on them.",
	Class = "",
	Icon = "weapons/lmn_tri_striker.png",
	Range = INT_MAX, -- no current support for < max range.
	PowerCost = 4,
	Damage = 3,
	Targets = 3,
	ArtiTrail = true,
	Upgrades = 1,
	UpgradeCost = { 3 },
	UpgradeList = { "+1 Damage" },
	LaunchSound = "",
	CustomTipImage = "lmn_Tri_Striker_Tip", -- ensures tipimage gets it's own path.
	TipImage = {
		Unit = Point(2,4),
		Enemy = Point(1,1),
		Building = Point(2,1),
		Enemy2 = Point(3,1),
		Target = Point(2,1),
	},
	CustomRarity = 4,
}

function lmn_Tri_Striker:GetTargetArea(p1)
	local ret = PointList()
	ret:push_back(p1) -- add shooter's tile in order for GetSkillEffect to trigger on it.

	local tiles = {p1}

	for dir = DIR_START, DIR_END do
		local curr = p1 + DIR_VECTORS[dir]
		if Board:IsValid(curr) then
			table.insert(tiles, curr)
		end
	end

	for _, tile in ipairs(tiles) do
		local color = GL_Color(72,106,100)
		if tile == p1 then
			color = GL_Color(110,160,150)
		end

		previewer:AddImage(tile, "combat/lmn_square.png", color)
	end

	local size = Board:GetSize()
	for x = 0, size.x - 1 do						-- grab every tile on the board.
		for y = 0, size.y - 1 do
			local p2 = Point(x, y)
			if p1:Manhattan(p2) <= self.Range then	-- that can be reached
				ret:push_back(p2)
			end
		end
	end

	return ret
end

-- returns whether a table is empty or not.
local function list_isEmpty(list)
	for _, v in pairs(list) do
		return false
	end
	return true
end

-- returns a table of points 'path' from 'p1' to 'p2' inclusive endpoints.
-- returns an empty table if p1 == p2
local function GetPath(p1, p2)
	assert(type(p1) == type(Point()))
	assert(type(p2) == type(p1))
	assert(Board:IsValid(p1))
	assert(Board:IsValid(p2))

	local path = {p1}
	local currDist = p1:Manhattan(p2)

	while path[#path] ~= p2 do
		for dir = DIR_START, DIR_END do
			local p = path[#path] + DIR_VECTORS[dir]
			local dist = p:Manhattan(p2)
			if dist < currDist then
				table.insert(path, p)
				currDist = dist
			end
		end
	end

	if #path == 1 then -- mimicing Board:GetPath
		return {}
	end

	return path
end

-- removes every tile in a 'path' before 'first' and after 'last'
local function TrimPath(path, first, last)
	assert(type(path) == 'table')
	assert(first >= 1)
	assert(last >= 1)
	assert(#path >= first)
	assert(#path >= last)

	for i = first - 1, 1, -1 do
		table.remove(path, i)
	end

	for i = #path, last + 1, -1 do
		table.remove(path, i)
	end
end

-- extends a 'path' to reach 'p'
local function ExtendPath(path, p)
	assert(type(path) == 'table')
	assert(#path > 0)

	local path2 = GetPath(path[#path], p)
	for i = 2, #path2 do				-- ignore first index as the paths will share it.
		table.insert(path, path2[i])	-- connect paths
	end
end

-- removes any duplicate tiles in 'path'.
local function RemoveDuplicate(path)
	assert(type(path) == 'table')

	local copy = shallow_copy(path)

	-- purge 'path'
	for i, v in ipairs(path) do
		path[i] = nil
	end

	-- reconstruct path in order without duplicates.
	for i = #copy, 1, -1 do
		if not list_contains(path, copy[i]) then
			table.insert(path, 1, copy[i])
		end
	end
end

-- filters 'path' to only contain points where 'func(p)' returns true.
local function FilterPath(path, func)
	assert(type(path) == 'table')
	assert(type(func) == 'function')

	for i = #path, 1, -1 do
		if not func(path[i]) then
			table.remove(path, i)
		end
	end
end

-- returns true if 'p1' is adjacent 'p2'.
local function IsAdjacent(p1, p2)
	assert(type(p1) == type(Point()))
	assert(type(p2) == type(p1))

	if p1.x == p2.x then
		return math.abs(p1.y - p2.y) == 1
	elseif p1.y == p2.y then
		return math.abs(p1.x - p2.x) == 1
	end

	return false
end

-- removes tiles from the start of the list that
-- are not adjacent any other tiles in the list.
local function TrimDisconnectedPath(path)
	assert(type(path) == 'table')

	for i = #path - 1, 1, -1 do
		local isAdjacent = false

		for j = #path, i + 1, -1 do
			isAdjacent = IsAdjacent(path[i], path[j])
			if isAdjacent then
				break
			end
		end

		if not isAdjacent then
			table.remove(path, i)
		end
	end
end

function lmn_Tri_Striker:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local isTipImage = Board:IsTipImage()

	if not isTipImage then
		------------------
		-- construct path
		------------------
		if self.Path == nil or #self.Path == 0 or resetPath then
			self.Path = GetPath(p1, p2)
		else
			ExtendPath(self.Path, p2) -- extend out to p2.
		end

		RemoveDuplicate(self.Path)

		-- remove tiles within range 1 of shooter.
		FilterPath(self.Path, function(p) return p:Manhattan(p1) > 1 end)

		-- mark tiles within range 1 of shooter.
		local tiles = {p1}

		for dir = DIR_START, DIR_END do
			local curr = p1 + DIR_VECTORS[dir]
			if Board:IsValid(curr) then
				table.insert(tiles, curr)
			end
		end

		for _, tile in ipairs(tiles) do
			local color = GL_Color(72,106,100)
			if tile == p1 then
				color = GL_Color(110,160,150)
			end

			previewer:AddImage(tile, "combat/lmn_square.png", color)
		end

		-- remove disconnected tiles from path.
		TrimDisconnectedPath(self.Path)

		-- exit if we don't have a valid path.
		if
			p1:Manhattan(p2) <= 1 or
			#self.Path == 0
		then
			self.Path = nil
			return ret
		end

		-- fetch the 3 last points in path.
		TrimPath(self.Path, math.max(1, 1 + #self.Path - self.Targets), #self.Path)
	end

	---------------------
	-- impact resolution
	---------------------
	-- create a strike path in ascending order, using index 1 as root.
	local strikePath = shallow_copy(self.Path)
	table.sort(strikePath, function(a,b) return a:Manhattan(self.Path[1]) < b:Manhattan(self.Path[1]) end)

	-- get median direction.
	local middleIndex = math.floor((#strikePath + 1) / 2)
	local dir = GetDirection(strikePath[middleIndex] - p1)

	-- strike tiles
	for i, tile in ipairs(strikePath) do
		ret:AddSound("weapons/defense_strike")

		local artillery = SpaceDamage(tile, self.Damage)
		artillery.sAnimation = "explo_fire1"

		if not self.ArtiTrail then
			artillery.bHidePath = true
			artillery.sImageMark = "combat/lmn_tri_striker_down_".. dir ..".png"
		end

		if i == 1 then
			artillery.sSound = "/impact/generic/explosion_large"
		else
			artillery.sSound = "/impact/generic/explosion"
		end

		effectBurst.Add(ret, p1, "lmn_Emitter_Tri_Striker_Static", DIR_NONE, isTipImage)

		ret:AddScript([[
			lmn_tri_striker_orig_emitter = Emitter_Missile;
			Emitter_Missile = lmn_Emitter_Tri_Striker;
		]])
		worldConstants:setHeight(ret, 44)
		ret:AddArtillery(p1, artillery, "effects/shotup_lmn_tri_strike_missile.png", NO_DELAY)
		worldConstants:resetHeight(ret)
		ret:AddScript([[
			Emitter_Missile = lmn_tri_striker_orig_emitter;
		]])
		ret:AddDelay(0.12)
	end

	if not self.ArtiTrail then
		local mark = SpaceDamage(p1)
		mark.sImageMark = "combat/lmn_tri_striker_up_".. dir ..".png"
		ret:AddDamage(mark)
	end

	return ret
end

lmn_Tri_Striker_A = lmn_Tri_Striker:new{
	UpgradeDescription = "Increases damage by 1",
	CustomTipImage = "lmn_Tri_Striker_Tip_A",
	Damage = 4,
}

lmn_Tri_Striker_B = lmn_Tri_Striker:new{
	UpgradeDescription = "Increases damage by 1",
	CustomTipImage = "lmn_Tri_Striker_Tip_B",
	Damage = 4,
}

lmn_Tri_Striker_AB = lmn_Tri_Striker:new{
	CustomTipImage = "lmn_Tri_Striker_Tip_AB",
	Damage = 5,
}

lmn_Tri_Striker_Tip = lmn_Tri_Striker:new{ Path = {Point(1,1), Point(2,1), Point(3,1)} }
lmn_Tri_Striker_Tip_A = lmn_Tri_Striker_A:new{ Path = lmn_Tri_Striker_Tip.Path }
lmn_Tri_Striker_Tip_B = lmn_Tri_Striker_B:new{ Path = lmn_Tri_Striker_Tip.Path }
lmn_Tri_Striker_Tip_AB = lmn_Tri_Striker_AB:new{ Path = lmn_Tri_Striker_Tip.Path }

function lmn_Tri_Striker_Tip:GetSkillEffect(p1, p2)
	return lmn_Tri_Striker.GetSkillEffect(self, p1, p2)
end

lmn_Tri_Striker_Tip_A.GetSkillEffect = lmn_Tri_Striker_Tip.GetSkillEffect
lmn_Tri_Striker_Tip_B.GetSkillEffect = lmn_Tri_Striker_Tip.GetSkillEffect
lmn_Tri_Striker_Tip_AB.GetSkillEffect = lmn_Tri_Striker_Tip.GetSkillEffect

lmn_Emitter_Tri_Striker = Emitter_Missile:new{
	variance = 1,
	max_alpha = 0.6,
	angle_variance = 360,
	lifespan = 1.25,
	birth_rate = 0.001,
	speed = 0.1,
	rot_speed = 10,
	max_particles = 128,
}

modApi:addWeaponDrop("lmn_Tri_Striker")

modApi:appendAsset("img/weapons/lmn_tri_striker.png", mod.resourcePath .."img/weapons/tri_striker.png")
modApi:appendAsset("img/effects/shotup_lmn_tri_strike_missile.png", mod.resourcePath .."img/effects/shotup_tri_strike_missile.png")

modApi:appendAsset("img/combat/lmn_tri_striker_up_0.png", mod.resourcePath .."img/combat/artillery_icon_up_flipped.png")
modApi:appendAsset("img/combat/lmn_tri_striker_up_1.png", mod.resourcePath .."img/combat/artillery_icon_up_flipped.png")
modApi:copyAsset("img/combat/artillery_icon_up.png", "img/combat/lmn_tri_striker_up_2.png")
modApi:copyAsset("img/combat/artillery_icon_up.png", "img/combat/lmn_tri_striker_up_3.png")
modApi:appendAsset("img/combat/lmn_tri_striker_down_0.png", mod.resourcePath .."img/combat/artillery_icon_down_flipped.png")
modApi:appendAsset("img/combat/lmn_tri_striker_down_1.png", mod.resourcePath .."img/combat/artillery_icon_down_flipped.png")
modApi:copyAsset("img/combat/artillery_icon_down.png", "img/combat/lmn_tri_striker_down_2.png")
modApi:copyAsset("img/combat/artillery_icon_down.png", "img/combat/lmn_tri_striker_down_3.png")
Location["combat/lmn_tri_striker_up_0.png"] = Point(5, -10)
Location["combat/lmn_tri_striker_up_1.png"] = Point(5, 12)
Location["combat/lmn_tri_striker_up_2.png"] = Point(-22, 11)
Location["combat/lmn_tri_striker_up_3.png"] = Point(-22, -11)
Location["combat/lmn_tri_striker_down_0.png"] = Point(-22, 11)
Location["combat/lmn_tri_striker_down_1.png"] = Point(-22, -11)
Location["combat/lmn_tri_striker_down_2.png"] = Point(4, -10)
Location["combat/lmn_tri_striker_down_3.png"] = Point(4, 10)

modApi:copyAsset("img/combat/square.png", "img/combat/lmn_square.png")
Location["combat/lmn_square.png"] = Point(-27, 2)

lmn_Emitter_Tri_Striker_Static = Emitter:new{
	image = "effects/smoke/art_smoke.png",
	max_alpha = 0.4,
	x = 0,
	y = 17,
	angle_variance = 360,
	variance = 0,
	variance_x = 20,
	variance_y = 15,
	burst_count = 20,
	lifespan = 1.9,
	speed = 0.3,
	gravity = false,
	layer = LAYER_FRONT
}
