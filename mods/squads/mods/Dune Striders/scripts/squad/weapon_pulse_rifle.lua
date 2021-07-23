
local mod = mod_loader.mods[modApi.currentMod]
local utils = require(mod.scriptPath .."libs/utils")
local effectPreview = require(mod.scriptPath .."libs/effectPreview")
local effectBurst = require(mod.scriptPath .."libs/effectBurst")
local worldConstants = LApi.worldConstants

modApi:appendAsset("img/effects/lmn_ds_explo_smoke.png", mod.resourcePath .."img/effects/explo_smoke.png")
modApi:appendAsset("img/effects/lmn_ds_explo_plasma.png", mod.resourcePath .."img/effects/explo_plasma.png")
modApi:appendAsset("img/effects/lmn_ds_laser_start.png", mod.resourcePath .."img/effects/laser_start.png")
modApi:appendAsset("img/effects/lmn_ds_laser_hit.png", mod.resourcePath .."img/effects/laser_hit.png")
modApi:appendAsset("img/effects/lmn_ds_laser_R.png", mod.resourcePath .."img/effects/laser_R.png")
modApi:appendAsset("img/effects/lmn_ds_laser_R1.png", mod.resourcePath .."img/effects/laser_R1.png")
modApi:appendAsset("img/effects/lmn_ds_laser_R2.png", mod.resourcePath .."img/effects/laser_R2.png")
modApi:appendAsset("img/effects/lmn_ds_laser_U.png", mod.resourcePath .."img/effects/laser_U.png")
modApi:appendAsset("img/effects/lmn_ds_laser_U1.png", mod.resourcePath .."img/effects/laser_U1.png")
modApi:appendAsset("img/effects/lmn_ds_laser_U2.png", mod.resourcePath .."img/effects/laser_U2.png")
modApi:appendAsset("img/effects/lmn_ds_shot_plasma_U.png", mod.resourcePath .."img/effects/shot_plasma_U.png")
modApi:appendAsset("img/effects/lmn_ds_shot_plasma_R.png", mod.resourcePath .."img/effects/shot_plasma_R.png")
modApi:appendAsset("img/weapons/lmn_ds_pulse_rifle.png", mod.resourcePath .."img/weapons/pulse_rifle.png")
modApi:copyAsset("img/combat/icons/icon_fire_immune_glow.png", "img/combat/icons/lmn_ds_icon_fire_immune_glow.png")

ANIMS.lmn_ds_explo_smoke = ANIMS.ExploAir2:new{ Image = "effects/lmn_ds_explo_smoke.png" }
ANIMS.lmn_ds_explo_plasma = ANIMS.ExploAir1:new{ Image = "effects/lmn_ds_explo_plasma.png" }

local laser_loc = Point(-12,3)
Location["effects/lmn_ds_laser_U.png"] = laser_loc
Location["effects/lmn_ds_laser_U1.png"] = laser_loc
Location["effects/lmn_ds_laser_U2.png"] = laser_loc
Location["effects/lmn_ds_laser_R.png"] = laser_loc
Location["effects/lmn_ds_laser_R1.png"] = laser_loc
Location["effects/lmn_ds_laser_R2.png"] = laser_loc
Location["effects/lmn_ds_laser_hit.png"] = laser_loc
Location["effects/lmn_ds_laser_start.png"] = laser_loc

Location["combat/icons/lmn_ds_icon_fire_immune_glow.png"] = Point(-10,8)


lmn_ds_PulseRifle = Skill:new{
	Name = "Pulse Rifle",
	Description = "Teleport, and fire a damaging and pushing projectile back in the direction you came from.",
	Icon = "weapons/lmn_ds_pulse_rifle.png",
	Class = "Prime",
	PowerCost = 1,
	Range = INT_MAX,
	Damage = 1,
	LeaveSmoke = false,
	CanFireFromSmoke = true,
	CanFireFromWater = true,
	Upgrades = 2,
	UpgradeList = { "Leave Smoke", "+2 Damage" },
	UpgradeCost = { 1, 3 },
	TipImage = {
		Unit = Point(2,3),
		Mountain = Point(2,2),
		Target = Point(2,0),
		Enemy1 = Point(2,1)
	}
}


lmn_ds_PulseRifle_A = lmn_ds_PulseRifle:new{
	UpgradeDescription = "Create smoke and extinguishing fire at origin before teleporting.",
	LeaveSmoke = true
}

lmn_ds_PulseRifle_B = lmn_ds_PulseRifle:new{
	UpgradeDescription = "Increases damage by 2.",
	Damage = 3
}

lmn_ds_PulseRifle_AB = lmn_ds_PulseRifle:new{
	LeaveSmoke = true,
	Damage = 3
}

function lmn_ds_PulseRifle:GetTargetArea(point)
	local ret = PointList()
	
	for dir = DIR_START, DIR_END do
		for k = 1, self.Range do
			local curr = point + DIR_VECTORS[dir] * k
			
			if not Board:IsValid(curr) then
				break
			end
			
			if
				not Board:IsBlocked(curr, Pawn:GetPathProf())                            and
				(not utils.IsTerrainWaterLogging(curr, Pawn) or self.CanFireFromWater)   and
				not Board:IsItem(curr)                                                   and
				(not Board:IsSmoke(curr) or self.CanFireFromSmoke)
			then
				ret:push_back(curr)
			end
		end
	end
	
	return ret
end

function lmn_ds_PulseRifle:GetSkillEffect(p1, p2)
	local ret = lmn_ds_Teleport.GetSkillEffect(self, p1, p2, lmn_ds_Teleport)
	local dir = GetDirection(p1 - p2)
	local target = p1
	
	for k = 1, self.Range do
		local curr = p2 + DIR_VECTORS[dir] * k
		
		if Board:IsValid(curr) then
			target = curr
		else
			break
		end
		
		if target ~= p1 and Board:IsBlocked(target, PATH_PROJECTILE) then
			break
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
		ret:AddProjectile(p2, SpaceDamage(target), "effects/lmn_ds_laser", NO_DELAY)
		worldConstants:resetLaserDuration(ret)
		ret:AddDelay(laserDuration)
	end
	
	ret:AddSound("/weapons/burst_beam")
	
	local velocity = 1.8
	worldConstants:setSpeed(ret, velocity)
	ret:AddProjectile(p2, projectile, "effects/lmn_ds_shot_plasma", NO_DELAY)
	worldConstants:resetSpeed(ret)
	
	return ret
end