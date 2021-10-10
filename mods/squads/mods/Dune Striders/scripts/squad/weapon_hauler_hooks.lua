
local mod = mod_loader.mods[modApi.currentMod]
local utils = require(mod.scriptPath .."libs/utils")
local effectPreview = LApi.library:fetch("effectPreview")
local effectBurst = LApi.library:fetch("effectBurst")
local worldConstants = LApi.library:fetch("worldConstants")

lmn_ds_HaulerHooks = Skill:new{
	Name = "Hauler Hooks",
	Description = "Charge up to 4 tiles, and haul any units behind you along.",
	Icon = "weapons/lmn_ds_hauler_hooks.png",
	Class = "Science",
	PowerCost = 1,
	MinMove = 1,
	MaxMove = 4,
	Velocity = 0.4,
	Upgrades = 2,
	UpgradeList = { "+1 Move", "+2 Move" },
	UpgradeCost = { 1, 2 },
	TipImage = {
		Unit = Point(2,2),
		Target = Point(2,1),
		Enemy1 = Point(2,3),
	}
}

lmn_ds_HaulerHooks_A = lmn_ds_HaulerHooks:new{
	UpgradeDescription = "Increase move distance by 1.",
	MaxMove = 5,
	Velocity = 0.5,
}

lmn_ds_HaulerHooks_B = lmn_ds_HaulerHooks:new{
	UpgradeDescription = "Increase move distance by 2.",
	MaxMove = 6,
	Velocity = 0.6,
}

lmn_ds_HaulerHooks_AB = lmn_ds_HaulerHooks_A:new{
	MaxMove = 7,
	Velocity = 0.7,
}

function lmn_ds_HaulerHooks:GetTargetArea(point)
	local ret = PointList()
	local pathing = Pawn:GetPathProf()

	for dir = DIR_START, DIR_END do
		for distance = 1, self.MaxMove do
			local curr = point + DIR_VECTORS[dir] * distance

			local isTraversableTile = true
				and Board:IsValid(curr)
				and utils.IsTilePassable(curr, Pawn)

			if isTraversableTile == false then
				break
			end

			local isValidEndTile = true
				and distance >= self.MinMove
				and Board:IsBlocked(curr, Pawn:GetPathProf()) == false

			if isValidEndTile then
				ret:push_back(curr)
			end
		end
	end

	return ret
end

function lmn_ds_HaulerHooks:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local distance = p1:Manhattan(p2)
	local dir_forward = GetDirection(p2 - p1)
	local dir_back = (dir_forward+2)%4
	local dir_right = (dir_forward+1)%4
	local dir_left = (dir_forward-1)%4
	local vec_forward = DIR_VECTORS[dir_forward]
	local vec_right = DIR_VECTORS[dir_right]
	local vec_left = DIR_VECTORS[dir_left]
	local velocity = self.Velocity
	local events = {}
	local cargo = nil
	local emitter_wind = "lmn_ds_Emitter_Wind_"

	if self.Velocity >= 0.6 then
		emitter_wind = "lmn_ds_Emitter_Tempest_"
	end

	-- create a list of pawns to haul: {pawn, from, to}
	for dist = -1, distance - 1 do
		local curr = p1 + vec_forward * dist
		local pawn = Board:GetPawn(curr)
		local terrain = Board:GetTerrain(curr)

		local tileHasHaulablePawn = true
			and curr ~= p1
			and pawn ~= nil
			and pawn:IsGuarding() == false

		local tileIsBlocked = true
			and curr ~= p1
			and Board:IsBlocked(curr, PATH_PROJECTILE)

		local cargoCanEnterTile = true
			and cargo ~= nil
			and tileIsBlocked == false

		local terrainKillsCargo = true
			and cargoCanEnterTile
			and utils.IsTerrainPathable(terrain, cargo.pawn:GetPathProf()) == false

		if cargoCanEnterTile then
			cargo.to = curr

			if terrainKillsCargo then
				cargo = nil
			end
		else
			cargo = nil
		end

		if tileHasHaulablePawn then
			events[dist] = { pawn = pawn, from = curr }
			cargo = events[dist]
		end
	end


	-- move pawns according to the list we made previously
	for dist = -1, distance do
		local curr = p1 + vec_forward * dist
		local draggedPawn = events[dist]
		local nextPawn = events[dist+1]
		local soundPawn = dist == -1 and draggedPawn or nextPawn
		local chargeSelf = dist == -1
		local createWindParticles = dist < distance - 1

		local playGrappleSound = true
			and soundPawn ~= nil
			and soundPawn.to ~= nil

		local chargeCargo = true
			and draggedPawn ~= nil
			and draggedPawn.to ~= nil

		if playGrappleSound then
			ret:AddSound("weapons/grapple")
			ret:AddSound("impact/generic/grapple")
		end

		ret:AddDelay(0.08 * worldConstants:getDefaultSpeed() / velocity)

		if chargeCargo then
			worldConstants:setSpeed(ret, velocity)
			ret:AddCharge(Board:GetPath(draggedPawn.from, draggedPawn.to, PATH_FLYER), NO_DELAY)
			worldConstants:resetSpeed(ret)
		end

		if chargeSelf then
			worldConstants:setSpeed(ret, velocity)
			ret:AddSound("/enemy/shared/moved")
			ret:AddCharge(Board:GetPath(p1, p2, Pawn:GetPathProf()), NO_DELAY)
			worldConstants:resetSpeed(ret)
		end

		if createWindParticles then
			effectBurst.Add(ret, curr + vec_forward, emitter_wind..dir_forward, DIR_NONE)
		end
	end

	-- weapon preview looks better if we end with the main charge
	effectPreview:addCharge(ret, p1, p2, Pawn:GetPathProf())

	return ret
end
