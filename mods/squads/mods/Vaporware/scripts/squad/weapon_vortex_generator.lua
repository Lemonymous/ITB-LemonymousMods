
modApi:addWeaponDrop("vw_Vortex_Generator")


local globals = LApi.library:fetch("globals")
local weaponPreview = LApi.library:fetch("weaponPreview")
local globalPawnIndex = globals:new()


local function isAdjacent(p1, p2)
	return p1:Manhattan(p2) == 1
end

local Simulation = Class.new()
function Simulation:new()
	self.smoke = {}
end

function Simulation:isSmoke(point)
	if not Board:IsValid(point) then
		return false
	end

	local pidx = p2idx(point)

	if self.smoke[pidx] == nil then
		self.smoke[pidx] = Board:IsSmoke(point)
	end

	return self.smoke[pidx]
end

function Simulation:setSmoke(point, isSmoke)
	local pidx = p2idx(point)

	self.smoke[pidx] = isSmoke
end


vw_Vortex_Generator = Skill:new{
	Name = "Vortex Generator",
	Description = "Create a vortex within 3 tiles, pulling in adjacent units and all aligned Smoke.",
	Icon = "weapons/vw_vortex_generator.png",
	Class = "Science",
	PowerCost = 1,
	MinRange = 1,
	Range = 3,
	Stable = false,
	Upgrades = 2,
	UpgradeList = { "Stable", "Range: 5" },
	UpgradeCost = { 1, 2 },
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,1),
		Smoke = Point(1,1),
		Enemy2 = Point(2,0),
	}
}

vw_Vortex_Generator_A = vw_Vortex_Generator:new{
	UpgradeDescription = "Prevents pulling the user into the vortex.",
	Stable = true,
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,2),
		Smoke = Point(1,2),
		Enemy2 = Point(2,1),
	}
}

vw_Vortex_Generator_B = vw_Vortex_Generator:new{
	UpgradeDescription = "Increases range to 5.",
	Range = 5,
	TipImage = {
		Unit = Point(2,4),
		Target = Point(2,0),
		Smoke = Point(1,0),
		Enemy2 = Point(2,1),
	}
}

vw_Vortex_Generator_AB = vw_Vortex_Generator:new{
	Stable = true,
	Range = 5,
}

function vw_Vortex_Generator:GetTargetArea(point)
	local ret = PointList()

	for dir = DIR_START, DIR_END do
		for distance = self.MinRange, self.Range do
			local loc = point + DIR_VECTORS[dir] * distance
			local tileIsInvalid = Board:IsValid(loc) == false

			if tileIsInvalid then
				break
			end

			ret:push_back(loc)
		end
	end

	return ret
end

function vw_Vortex_Generator:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local pre_event_index
	local pre_event = SpaceDamage()
	local post_event = SpaceDamage()
	local push_event = SpaceDamage()
	local smoke_create = SpaceDamage()
	local smoke_remove = SpaceDamage()
	local collide_event = SpaceDamage()

	local sim = Simulation()

	local pushedTargets = {}
	local clouds = {}
	local cloudsOnRow = { 0, 0, 0, [0] = 0 }
	local addCenterCloud = false

	collide_event.loc = p2
	smoke_create.sImageMark = "combat/icons/vw_icon_smoke_glow.png"
	smoke_remove.sImageMark = "combat/icons/vw_icon_smoke_immune_glow.png"

	ret:AddDamage(pre_event)
	pre_event_index = ret.effect:size()

	-- calculate & simulate cloud movement
	for dist = 0, 7 do
		local addCloudToAllRows = false
		for dir = DIR_START, DIR_END do
			local loc = p2 + DIR_VECTORS[dir] * dist

			if Board:IsSmoke(loc) then
				local cloud = {
					loc = loc,
					dir = dir,
					vec = DIR_VECTORS[dir],
					move = dist - cloudsOnRow[dir],
				}

				clouds[#clouds+1] = cloud

				sim:setSmoke(cloud.loc, false)
				sim:setSmoke(cloud.loc - cloud.vec * cloud.move, true)

				-- if cloud.move is equal to dist,
				-- then the cloud moves to p2.
				-- add a cloud to each row later.
				if cloud.move == dist then
					addCloudToAllRows = true
				else
					cloudsOnRow[dir] = cloudsOnRow[dir] + 1
				end
			end
		end

		if addCloudToAllRows then
			for dir = DIR_START, DIR_END do
				cloudsOnRow[dir] = cloudsOnRow[dir] + 1
			end
		end
	end

	-- find number of colliding units
	for dir = DIR_START, DIR_END do
		local vec = DIR_VECTORS[dir]
		local loc = p2 + vec
		local pawn = Board:GetPawn(loc)

		local isStableUser = true
			and self.Stable
			and loc == p1

		local pawnIsPushable = true
			and pawn ~= nil
			and pawn:IsGuarding() == false
			and isStableUser == false

		if pawnIsPushable then
			pushedTargets[#pushedTargets+1] = loc
		end
	end

	local collisionInCenter = true
		and #pushedTargets > 1
		and Board:IsBlocked(p2, PATH_FLYER) == false

	local addCenterCloud = true
		and Board:IsSmoke(p2) == false
		and sim:isSmoke(p2) == true

	-- add sound
	ret:AddSound("/weapons/enhanced_tractor")

	if #clouds > 0 then
		ret:AddSound("/enemy/shared/moved")
	end

	-- add whirl
	ret:AddScript(string.format([[Board:AddAnimation(%s, "vw_whirl", NO_DELAY)]], p2:GetString()))

	-- add events for pushing units
	for dir = DIR_START, DIR_END do
		local dir_opposite = (dir+2)%4
		local vec = DIR_VECTORS[dir]
		local loc = p2 + vec

		push_event.loc = loc
		push_event.iPush = dir_opposite
		push_event.sImageMark = ""
		push_event.sAnimation = "airpush_"..dir_opposite

		local isStableUser = true
			and self.Stable
			and loc == p1

		local markAddCloud = true
			and Board:IsSmoke(loc) == false
			and sim:isSmoke(loc) == true

		local markRemCloud = true
			and Board:IsSmoke(loc) == true
			and sim:isSmoke(loc) == false

		if markAddCloud then
			push_event.sImageMark = smoke_create.sImageMark
		elseif markRemCloud then
			push_event.sImageMark = smoke_remove.sImageMark
		end

		if isStableUser then
			push_event.iPush = DIR_NONE
		end

		ret:AddDamage(push_event)
	end

	-- add events for moving clouds
	while #clouds > 0 do
		for i = #clouds, 1, -1 do
			local cloud = clouds[i]
			ret:AddScript(string.format(
				"Board:SetSmoke(%s, true, true)",
				cloud.loc:GetString()
			))

			local markAddCloud = true
				and Board:IsSmoke(cloud.loc) == false
				and sim:isSmoke(cloud.loc) == true
				and isAdjacent(cloud.loc, p2) == false

			if markAddCloud then
				smoke_create.loc = cloud.loc
				ret:AddDamage(smoke_create)
			end

			if cloud.move == 0 then
				-- swap and remove
				clouds[i] = clouds[#clouds]
				clouds[#clouds] = nil
			else
				ret:AddScript(string.format([[
					local p, dir = %s, %s 
					Board:SetSmoke(p, false, true) 
					Board:AddAnimation(p, "vw_smoke_move_"..dir, NO_DELAY) 
				]], cloud.loc:GetString(), cloud.dir))

				local markRemCloud = true
					and Board:IsSmoke(cloud.loc) == true
					and sim:isSmoke(cloud.loc) == false
					and isAdjacent(cloud.loc, p2) == false

				if markRemCloud then
					smoke_remove.loc = cloud.loc
					ret:AddDamage(smoke_remove)
				end

				cloud.loc = cloud.loc - cloud.vec
				cloud.move = cloud.move - 1
			end
		end

		ret:AddDelay(ANIMS.vw_smoke_move_0.Time * ANIMS.vw_smoke_move_0.NumFrames)
	end

	if collisionInCenter then
		-- mark star in center
		if addCenterCloud then
			collide_event.sImageMark = "combat/vw_arrow_hit+smoke.png"
		else
			collide_event.sImageMark = "combat/vw_arrow_hit.png"
		end

		ret:AddDamage(collide_event)

		-- apply extra collision damage
		for _, loc in ipairs(pushedTargets) do
			local extra_damage_event = SpaceDamage()
			extra_damage_event.loc = loc
			extra_damage_event.iPush = 230 -- hack to display hp loss

			weaponPreview:AddDamage(extra_damage_event)
		end

		-- add events for add/rem invisible dummy unit
		pre_event = ret.effect:index(pre_event_index)

		pre_event.sScript = string.format([[
			local pawn = PAWN_FACTORY:CreatePawn("vw_Wall") 
			globals[%s] = pawn:GetId() 
			pawn:SetInvisible(true) 
			Board:AddPawn(pawn, %s) 
		]], globalPawnIndex, p2:GetString())

		post_event.sScript = string.format([[
			local pawnId = globals[%s] 
			local pawn = Board:GetPawn(pawnId) 
			if pawn then 
				Board:RemovePawn(pawn) 
			end
		]], globalPawnIndex)

		ret:AddDelay(0.4)
		ret:AddDamage(post_event)
	end

	return ret
end

local function createSmoke(count)
	local tiles = extract_table(Board:GetTiles())

	for i = 1, count do
		Board:SetSmoke(random_removal(tiles), true, true)
	end
end

-- add clouds to experiment with in test mech scenario
modApi.events.onTestMechEntered:subscribe(function()
	modApi:runLater(function()
		local pawn = false
			or Game:GetPawn(0)
			or Game:GetPawn(1)
			or Game:GetPawn(2)

		if pawn and pawn:IsWeaponEquipped("vw_Vortex_Generator") then
			createSmoke(5)
		end
	end)
end)
