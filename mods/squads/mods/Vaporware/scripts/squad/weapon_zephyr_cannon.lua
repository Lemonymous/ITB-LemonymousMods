
modApi:addWeaponDrop("vw_Zephyr_Cannon")


local mod = mod_loader.mods[modApi.currentMod]
local worldConstants = LApi.library:fetch("worldConstants")
local defaultArtilleryHeight = worldConstants:getDefaultHeight()


local function getArtilleryHeight(distance)
	return 6 + distance * 2
end

local halfDistance = { 1,2,3,2,3 }
local function getHalfDistance(distance)
	return halfDistance[distance] or distance
end

local function getHalfPoint(p1, dir, distance)
	return p1 + DIR_VECTORS[dir] * getHalfDistance(distance)
end

local function isInvalidBounceTile(tile)
	local terrain = Board:GetTerrain(tile)

	if Board:IsPawnSpace(tile) then
		return false
	end

	return false
		or terrain == TERRAIN_WATER
		or terrain == TERRAIN_HOLE
end

local function GetProjectileEnd(p1, p2, pathing, range)
	range = range or INT_MAX
	pathing = pathing or PATH_PROJECTILE
	local dir = GetDirection(p2 - p1)
	local target = p1

	for k = 1, range do
		local curr = p1 + DIR_VECTORS[dir] * k
		local tileIsInvalid = Board:IsValid(curr) == false
		local tileIsBlocked = Board:IsBlocked(curr, pathing)

		if tileIsInvalid then
			break
		end

		target = curr

		if tileIsBlocked then
			break
		end
	end

	return target
end


vw_Zephyr_Cannon = Skill:new{
	Name = "Zephyr Cannon",
	Description = "Fires a pushing canister up to 3 tiles, creating Smoke while in transit",
	Icon = "weapons/vw_zephyr_cannon.png",
	Class = "Brute",
	PowerCost = 1,
	Range = 3,
	Artillery = false,
	ArtilleryHeight = 4.5, -- only used for tipimage
	Upgrades = 2,
	UpgradeList = { "Artillery", "Range: 5" },
	UpgradeCost = { 2, 2 },
	TipImage = {
		Unit = Point(2,4),
		Target = Point (2,1),
		Enemy1 = Point(2,1),
	}
}

vw_Zephyr_Cannon_A = vw_Zephyr_Cannon:new{
	UpgradeDescription = "Becomes a short range artillery. Above range 3, the canister will bounce.",
	Artillery = true,
	ArtilleryHeight = 12, -- only used for tipimage
	TipImage = {
		Unit = Point(2,4),
		Target = Point (2,1),
		Enemy1 = Point(2,2),
	}
}

vw_Zephyr_Cannon_B = vw_Zephyr_Cannon:new{
	UpgradeDescription = "Increases range to 5.",
	Range = 5,
	ArtilleryHeight = 6, -- only used for tipimage
	TipImage = {
		Unit = Point(2,4),
		Target = Point (2,0),
	}
}

vw_Zephyr_Cannon_AB = vw_Zephyr_Cannon:new{
	Artillery = true,
	ArtilleryHeight = 10, -- only used for tipimage
	Range = 5,
	TipImage = {
		Unit = Point(2,4),
		Target = Point (2,0),
		Enemy1 = Point(2,3),
		Enemy2 = Point(2,1),
	}
}

function vw_Zephyr_Cannon:GetTargetArea(origin)
	local ret = PointList()

	for dir = DIR_START, DIR_END do
		for distance = 1, self.Range do
			local target = origin + DIR_VECTORS[dir] * distance
			local tileIsInvalid = Board:IsValid(target) == false

			local tileIsBlocked = true
				and self.Artillery == false
				and Board:IsBlocked(target, PATH_PROJECTILE)

			if tileIsInvalid then
				break
			end

			ret:push_back(target)

			if tileIsBlocked then
				break
			end
		end
	end

	return ret
end

function vw_Zephyr_Cannon:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local isTipImage = Board:IsTipImage()
	local distance = p1:Manhattan(p2)
	local dir = GetDirection(p2 - p1)
	local events = { { origin = p1, target = p2, distance = distance } }

	local impactEvent = SpaceDamage()
	local smokeEvent = SpaceDamage()
	local impactSound = "/impact/generic/general"

	impactEvent.loc = p2
	impactEvent.iPush = dir
	impactEvent.sAnimation = "airpush_"..dir
	smokeEvent.iSmoke = EFFECT_CREATE

	ret:AddSound("/weapons/artillery_shot")
	ret:AddDelay(0.1)

	if self.Artillery then
		if distance > 3 then
			local halfPoint = getHalfPoint(p1, dir, distance)

			events[1] = { origin = p1, target = halfPoint, distance = p1:Manhattan(halfPoint) }
			events[2] = { origin = halfPoint, target = p2, distance = p2:Manhattan(halfPoint) }

			if isInvalidBounceTile(halfPoint) then
				events[1].destroy = true
				events[2] = nil
			end
		end
	else
		local from = p1
		local step = DIR_VECTORS[dir]
		for d = 1, distance do
			local dummyEvent = SpaceDamage(from + step)
			ret:AddProjectile(from, dummyEvent, "", NO_DELAY)
			from = from + step
		end
	end

	for i, event in ipairs(events) do
		local origin = event.origin
		local target = event.target
		local distance = event.distance

		for d = 1, distance do
			local delay = 0.08
			local artilleryHeight

			if self.Artillery then
				artilleryHeight = getArtilleryHeight(distance)
			else
				impactEvent.bHidePath = true
				artilleryHeight = distance * 1.5
			end

			local totalDelay = 0.8 * artilleryHeight / defaultArtilleryHeight
			delay = totalDelay / distance

			if d == 1 then
				impactEvent.loc = target

				if event.destroy then
					impactEvent.sImageMark = "combat/icons/vw_icon_zephyr_destroy.png"
				end

				-- if not isTipImage then
				worldConstants:setHeight(ret, artilleryHeight)
				-- end

				if Board:IsPawnSpace(target) == false then
					local isWater = Board:IsTerrain(target, TERRAIN_WATER)
					local isLava = Board:IsTerrain(target, TERRAIN_LAVA)
					local isAcid = Board:IsAcid(target)
					local isHole = Board:IsTerrain(target, TERRAIN_HOLE)

					if isWater then
						if isLava then
							impactSound = "props/lava_splash"
							impactEvent.sAnimation = "Splash_lava"
						elseif isAcid then
							impactSound = "props/acid_splash"
							impactEvent.sAnimation = "Splash_acid"
						else
							impactSound = "props/water_splash"
							impactEvent.sAnimation = "Splash"
						end
					elseif isHole then
						impactSound = "enemy/shared/fall"
						impactEvent.sAnimation = ""
					end
				end

				ret:AddArtillery(
					origin,
					impactEvent,
					"effects/vw_shotup_zephyr_missile.png",
					NO_DELAY
				)

				-- if not isTipImage then
					-- worldConstants:resetHeight(ret)
				-- end
			end

			if d < distance then
				-- each tile the canister is in transit
				ret:AddDelay(delay)
				smokeEvent.loc = origin + DIR_VECTORS[dir] * d
				ret:AddDamage(smokeEvent)
			else
				-- final tile before ground impact
				local soundDelay = math.max(0, delay - 0.16)
				ret:AddDelay(soundDelay)
				ret:AddSound(impactSound)
				ret:AddDelay(delay - soundDelay)
			end
		end
	end

	return ret
end
