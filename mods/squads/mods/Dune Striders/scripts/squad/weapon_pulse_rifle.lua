
local mod = mod_loader.mods[modApi.currentMod]
local utils = require(mod.scriptPath .."libs/utils")
local effectBurst = LApi.library:fetch("effectBurst")
local worldConstants = LApi.library:fetch("worldConstants")
modApi:copyAsset("img/combat/icons/icon_fire_immune_glow.png", "img/combat/icons/lmn_ds_icon_fire_immune_glow.png")

Location["combat/icons/lmn_ds_icon_fire_immune_glow.png"] = Point(-10,8)

local weaponPreview = LApi.library:fetch("weaponPreview")

lmn_ds_PulseRifle = Skill:new{
	Name = "Pulse Rifle",
	Description = "Teleport, and fire a damaging and pushing projectile back in the direction you came from.",
	Icon = "weapons/lmn_ds_pulse_rifle.png",
	Class = "Prime",
	PowerCost = 2,
	Range = INT_MAX,
	Damage = 1,
	DirectFire = false,
	LeaveSmoke = false,
	CanFireFromSmoke = true,
	CanFireFromWater = true,
	Upgrades = 2,
	UpgradeList = { "Direct Fire", "+2 Damage" },
	UpgradeCost = { 1, 4 },
	TipImage = {
		Unit = Point(2,3),
		Mountain = Point(2,2),
		Target = Point(2,0),
		Enemy1 = Point(2,1)
	}
}


lmn_ds_PulseRifle_A = lmn_ds_PulseRifle:new{
	UpgradeDescription = "Can fire directly at targets in line of sight.",
	DirectFire = true,
}

lmn_ds_PulseRifle_B = lmn_ds_PulseRifle:new{
	UpgradeDescription = "Increases damage by 1.",
	Damage = 3,
}

lmn_ds_PulseRifle_AB = lmn_ds_PulseRifle:new{
	DirectFire = true,
	Damage = 3,
}

function lmn_ds_PulseRifle:GetTargetArea(point)
	local ret = PointList()
	
	for dir = DIR_START, DIR_END do
		local lineOfSightIsBroken = false

		for dist = 1, self.Range do
			local curr = point + DIR_VECTORS[dir] * dist
			
			if not Board:IsValid(curr) then
				break
			end

			local teleportInvalidatedBySmoke = true
				and self.CanFireFromSmoke == false
				and Board:IsSmoke(curr)

			local teleportInvalidatedByWater = true
				and self.CanFireFromWater == false
				and Board:GetTerrain(point) == TERRAIN_WATER
				and Pawn:IsFlying() == false

			local teleportBlocked = false
				or Board:IsBlocked(curr, Pawn:GetPathProf())
				or Board:IsItem(curr)

			local targetInLineOfSight = true
				and self.DirectFire
				and	lineOfSightIsBroken == false
				and Board:IsBlocked(curr, PATH_PROJECTILE)

			local validTeleportLocation = true
				and teleportInvalidatedBySmoke == false
				and teleportInvalidatedByWater == false
				and teleportBlocked == false

			local validTarget = false
				or validTeleportLocation
				or targetInLineOfSight

			if validTarget then
				ret:push_back(curr)
			end

			if targetInLineOfSight then
				lineOfSightIsBroken = true
			end
		end
	end
	
	return ret
end

function lmn_ds_PulseRifle:GetSkillEffect(p1, p2)
	local isDirectFire = Board:IsBlocked(p2, PATH_PROJECTILE)
	local origin
	local target
	local dir

	if isDirectFire then
		ret = SkillEffect()
		origin = p1
		target = p2
		dir = GetDirection(target - origin)
	else
		ret = lmn_ds_Teleport.GetSkillEffect(self, p1, p2, lmn_ds_Teleport)
		origin = p2
		target = p1
		dir = GetDirection(target - origin)

		for dist = 1, self.Range do
			local curr = origin + DIR_VECTORS[dir] * dist

			if Board:IsValid(curr) then
				target = curr
			else
				break
			end

			if target ~= p1 and Board:IsBlocked(target, PATH_PROJECTILE) then
				break
			end
		end
	end
	
	local projectile = SpaceDamage(target, self.Damage, dir)
	projectile.sSound = "/props/electric_smoke_damage"
	projectile.sScript = string.format("Board:AddAnimation(%s, 'lmn_ds_explo_plasma', NO_DELAY)", target:GetString())
	
	ret:AddSound("/impact/generic/tractor_beam")
	ret:AddDelay(0.1)
	
	local laserDuration = 0.05
	for i = 1, 10 do
		if i < 7 and i % 2 == 0 or i >= 7 then
			ret:AddSound("/props/square_lightup")
		end
		
		worldConstants:setLaserDuration(ret, laserDuration + 0.05)
		ret:AddProjectile(origin, SpaceDamage(target), "effects/lmn_ds_laser", NO_DELAY)
		worldConstants:resetLaserDuration(ret)
		ret:AddDelay(laserDuration)
	end
	
	ret:AddSound("/weapons/burst_beam")
	
	if target == p1 then
		-- remove hp blinking if targeting its own location
		-- by previewing the opposite damage
		weaponPreview:AddDamage(SpaceDamage(p1, -self.Damage))
	end

	local velocity = 1.8
	worldConstants:setSpeed(ret, velocity)
	ret:AddProjectile(origin, projectile, "effects/lmn_ds_shot_plasma", NO_DELAY)
	worldConstants:resetSpeed(ret)
	
	return ret
end
