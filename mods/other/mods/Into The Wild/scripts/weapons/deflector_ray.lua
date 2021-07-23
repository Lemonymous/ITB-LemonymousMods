
local path = mod_loader.mods[modApi.currentMod].resourcePath
local worldConstants = require(path .."scripts/worldConstants")

-- icon
modApi:appendAsset("img/weapons/lmn_deflector_ray.png", path .."img/weapons/deflector_ray.png")
-- projectile
modApi:copyAsset("img/effects/laser_push_hit.png", "img/effects/lmn_shot_deflector_ray_smoke_R.png")
modApi:copyAsset("img/effects/laser_push_hit.png", "img/effects/lmn_shot_deflector_ray_smoke_U.png")
modApi:appendAsset("img/effects/lmn_shot_deflector_ray_acid_R.png", path .."img/effects/laser_acid_hit.png")
modApi:appendAsset("img/effects/lmn_shot_deflector_ray_acid_U.png", path .."img/effects/laser_acid_hit.png")
modApi:copyAsset("img/effects/laser_fire_hit.png", "img/effects/lmn_shot_deflector_ray_fire_R.png")
modApi:copyAsset("img/effects/laser_fire_hit.png", "img/effects/lmn_shot_deflector_ray_fire_U.png")
modApi:copyAsset("img/effects/laser_freeze_hit.png", "img/effects/lmn_shot_deflector_ray_frozen_R.png")
modApi:copyAsset("img/effects/laser_freeze_hit.png", "img/effects/lmn_shot_deflector_ray_frozen_U.png")
-- rem effect image mark
modApi:copyAsset("img/combat/icons/icon_smoke_immune_glow.png", "img/combat/icons/lmn_deflector_ray_rem_smoke.png")
modApi:copyAsset("img/combat/icons/icon_acid_immune_glow.png", "img/combat/icons/lmn_deflector_ray_rem_acid.png")
modApi:copyAsset("img/combat/icons/icon_fire_immune_glow.png", "img/combat/icons/lmn_deflector_ray_rem_fire.png")
modApi:appendAsset("img/combat/icons/lmn_deflector_ray_rem_frozen.png", path .."img/combat/icon_frozen_immune.png")
Location["combat/icons/lmn_deflector_ray_rem_frozen.png"] = Point(-10,8)
Location["combat/icons/lmn_deflector_ray_rem_smoke.png"] = Point(-10,8)
Location["combat/icons/lmn_deflector_ray_rem_fire.png"] = Point(-10,8)
Location["combat/icons/lmn_deflector_ray_rem_acid.png"] = Point(-10,8)
-- laser acid
modApi:appendAsset("img/effects/lmn_laser_acid_start.png", path .."img/effects/laser_acid_start.png")
modApi:appendAsset("img/effects/lmn_laser_acid_hit.png", path .."img/effects/laser_acid_hit.png")
modApi:appendAsset("img/effects/lmn_laser_acid_R.png", path .."img/effects/laser_acid_R.png")
modApi:appendAsset("img/effects/lmn_laser_acid_R1.png", path .."img/effects/laser_acid_R1.png")
modApi:appendAsset("img/effects/lmn_laser_acid_R2.png", path .."img/effects/laser_acid_R2.png")
modApi:appendAsset("img/effects/lmn_laser_acid_U.png", path .."img/effects/laser_acid_U.png")
modApi:appendAsset("img/effects/lmn_laser_acid_U1.png", path .."img/effects/laser_acid_U1.png")
modApi:appendAsset("img/effects/lmn_laser_acid_U2.png", path .."img/effects/laser_acid_U2.png")
Location["effects/lmn_laser_acid_U.png"] = Point(-12,3)
Location["effects/lmn_laser_acid_U1.png"] = Point(-12,3)
Location["effects/lmn_laser_acid_U2.png"] = Point(-12,3)
Location["effects/lmn_laser_acid_R.png"] = Point(-12,3)
Location["effects/lmn_laser_acid_R1.png"] = Point(-12,3)
Location["effects/lmn_laser_acid_R2.png"] = Point(-12,3)
Location["effects/lmn_laser_acid_hit.png"] = Point(-12,3)
Location["effects/lmn_laser_acid_start.png"] = Point(-12,3)

lmn_Deflector_Ray = Skill:new{
	Name = "Deflector Ray",
	Description = "Clear all environment effects, and beam them to your target.\n(A.C.I.D, Smoke, Fire, then Ice)",
	Rarity = 1,
	Class = "Science",
	Icon = "weapons/lmn_deflector_ray.png",
	PowerCost = 0,
	Upgrades = 2,
	UpgradeCost = { 1, 1 },
	UpgradeList = { "Piercing", "Adjacent" },
	CustomTipImage = "lmn_Deflector_Ray_Tip"
}

lmn_Deflector_Ray_A = lmn_Deflector_Ray:new{
	UpgradeDescription = "Pierces target and applies effects to each unit hit.",
	Piercing = true,
	CustomTipImage = "lmn_Deflector_Ray_Tip_A"
}

lmn_Deflector_Ray_B = lmn_Deflector_Ray:new{
	UpgradeDescription = "Clears environment effects from adjacent tiles as well.",
	Adjacent = true,
	CustomTipImage = "lmn_Deflector_Ray_Tip_B"
}

lmn_Deflector_Ray_AB = lmn_Deflector_Ray:new{
	Piercing = true,
	Adjacent = true,
	CustomTipImage = "lmn_Deflector_Ray_Tip_AB"
}

lmn_Deflector_Ray_Tip = lmn_Deflector_Ray:new{
	TipImage = {
		Unit = Point(2,3),
		Fire = Point(2,3),
		Enemy = Point(2,1),
		Target = Point(2,1)
	}
}

lmn_Deflector_Ray_Tip_A = lmn_Deflector_Ray_A:new{
	TipImage = {
		Unit = Point(2,3),
		Fire = Point(2,3),
		Enemy1 = Point(2,0),
		Enemy2 = Point(2,1),
		Enemy3 = Point(2,2),
		Target = Point(2,1)
	}
}

lmn_Deflector_Ray_Tip_B = lmn_Deflector_Ray_B:new{
	TipImage = {
		Unit = Point(2,3),
		Acid = Point(2,4),
		Smoke = Point(1,3),
		Fire = Point(2,3),
		Ice = Point(3,3),
		Enemy = Point(2,1),
		Target = Point(2,1)
	}
}

lmn_Deflector_Ray_Tip_AB = lmn_Deflector_Ray_AB:new{
	TipImage = {
		Unit = Point(2,3),
		Acid = Point(2,4),
		Smoke = Point(1,3),
		Fire = Point(2,3),
		Ice = Point(3,3),
		Enemy1 = Point(2,0),
		Enemy2 = Point(2,1),
		Enemy3 = Point(2,2),
		Target = Point(2,1)
	}
}

function lmn_Deflector_Ray_Tip:GetSkillEffect(p1, p2, ...)
	if self.TipImage.Acid then
		local d = SpaceDamage(self.TipImage.Acid)
		d.iAcid = 1
		Board:DamageSpace(d)
	end
	
	if self.TipImage.Sand then
		Board:SetTerrain(self.TipImage.Sand, TERRAIN_SAND)
	end
	
	if self.TipImage.Ice then
		Board:SetTerrain(self.TipImage.Ice, TERRAIN_ICE)
	end
	
	return lmn_Deflector_Ray.GetSkillEffect(self, p1, p2, ...)
end

lmn_Deflector_Ray_Tip_A.GetSkillEffect = lmn_Deflector_Ray_Tip.GetSkillEffect
lmn_Deflector_Ray_Tip_B.GetSkillEffect = lmn_Deflector_Ray_Tip.GetSkillEffect
lmn_Deflector_Ray_Tip_AB.GetSkillEffect = lmn_Deflector_Ray_Tip.GetSkillEffect

function lmn_Deflector_Ray:GetTargetArea(p)
	local ret = PointList()
	
	for i = DIR_START, DIR_END do
		for k = 1, INT_MAX do
			local curr = p + DIR_VECTORS[i] * k
			if not Board:IsValid(curr) then
				break
			end
			
			ret:push_back(curr)
			
			if self.Piercing then
				local pawn = Board:GetPawn(curr)
				if not pawn and Board:IsBlocked(curr, PATH_PROJECTILE) then
					break
				end
			elseif Board:IsBlocked(curr, PATH_PROJECTILE) then
				break
			end
		end
	end
	
	return ret
end

function lmn_Deflector_Ray:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	
	local shooter = Board:GetPawn(p1)
	if not shooter then return end
	
	local dir = GetDirection(p2 - p1)
	local targets = {}
	for k = 1, INT_MAX do
		local curr = p1 + DIR_VECTORS[dir] * k
		if not Board:IsValid(curr) then
			break
		end
		
		local pawn = Board:GetPawn(curr)
		local nonPawnObstacle = not pawn and Board:IsBlocked(curr, PATH_PROJECTILE)
		if pawn or nonPawnObstacle then
			targets[#targets+1] = curr
			
			if not self.Piercing or nonPawnObstacle then
				break
			end
		elseif not Board:IsValid(curr + DIR_VECTORS[dir]) then
			targets[#targets+1] = curr
			break
		end
	end
	
	local pts = {{p = p1}}
	if self.Adjacent then
		for i = DIR_START, DIR_END do
			local p = p1 + DIR_VECTORS[i]
			if Board:IsValid(p) then
				pts[#pts+1] = {p = p}
			end
		end
	end
	
	local delay = {
		get = .1,
		shoot = 0.08 * (p1:Manhattan(targets[#targets]) + 2),
		pre_shoot = .3,
		post_shoot = .7
	}
	
	-- lasers:
	-- red (recolored green for acid): "effects/lmn_laser_acid"
	-- yellow (smoke?): "effects/laser_push"
	-- fire: "effects/laser_fire"
	-- frozen: "effects/laser_freeze"
	
	for _, v in ipairs(pts) do
		local d = SpaceDamage(v.p)
		local pawn = Board:GetPawn(v.p)
		if Board:IsTerrain(v.p, TERRAIN_SAND) then pts.smoke, v.smoke = true, true end
		if Board:IsTerrain(v.p, TERRAIN_ICE) then pts.frozen, v.frozen = true, true end
		if Board:IsSmoke(v.p) then pts.smoke, v.smoke = true, true end
		if Board:IsAcid(v.p) then pts.acid, v.acid = true, true end
		if Board:IsFire(v.p) then pts.fire, v.fire, v.iFire = true, true, 2 end
		if Board:IsFrozen(v.p) then pts.frozen, v.frozen = true, true end
		if Board:IsTerrain(v.p, TERRAIN_LAVA) then pts.fire, v.fire = true, true end
		if pawn and pawn:IsAcid() then pts.acid, v.acid, v.iAcid = true, true, 2 end
		if pawn and pawn:IsFire() then pts.fire, v.fire, v.iFire = true, true, 2 end
	end
	
	-- start up beam.
	local laser = SpaceDamage(targets[#targets])
	
	local function fireLaser(art, duration)
		worldConstants.SetLaserDuration(ret, duration)
		ret:AddProjectile(laser, art, NO_DELAY)
		worldConstants.ResetLaserDuration(ret)
	end
	
	if pts.acid then
		for _, v in ipairs(pts) do
			if v.acid then
				ret:AddScript(string.format("Board:Ping(%s, GL_Color(0, 255, 100))", v.p:GetString()))
				ret:AddScript(string.format("Board:SetAcid(%s,false)", v.p:GetString()))
				if v.iAcid then
					local d = SpaceDamage(v.p)
					d.iAcid = 2
					ret:AddDamage(d)
				end
				ret:AddSound("/props/square_lightup")
				ret:AddSound("/props/acid_splash")
				ret:AddDelay(delay.get)
			end
		end
		
		ret:AddDelay(delay.pre_shoot)
		ret:AddSound("/weapons/basic_beam")
		fireLaser("effects/lmn_laser_acid", delay.shoot)
		for _, target in ipairs(targets) do
			local d = SpaceDamage(target)
			d.iAcid = 1
			--d.sSound = "/props/acid_splash"
			ret:AddProjectile(d, "effects/lmn_shot_deflector_ray_acid", NO_DELAY)
		end
		ret:AddDelay(delay.post_shoot)
	end
	
	if pts.smoke then
		for _, v in ipairs(pts) do
			if v.smoke then
				ret:AddScript(string.format("Board:Ping(%s, GL_Color(255, 255, 150))", v.p:GetString()))
				ret:AddScript(string.format("Board:SetSmoke(%s,false,false)", v.p:GetString()))
				ret:AddSound("/props/square_lightup")
				ret:AddSound("/props/smoke_cloud")
				if Board:IsTerrain(v.p, TERRAIN_SAND) then
					ret:AddScript(string.format("Board:SetTerrain(%s, TERRAIN_ROAD)", v.p:GetString()))
				end
				ret:AddDelay(delay.get)
			end
		end
		
		ret:AddDelay(delay.pre_shoot)
		ret:AddSound("/weapons/push_beam")
		fireLaser("effects/laser_push", delay.shoot)
		for _, target in ipairs(targets) do
			local d = SpaceDamage(target)
			d.iSmoke = 1
			--d.sSound = "/props/smoke_cloud"
			ret:AddProjectile(d, "effects/lmn_shot_deflector_ray_smoke", NO_DELAY)
		end
		ret:AddDelay(delay.post_shoot)
	end
	
	if pts.fire then
		for _, v in ipairs(pts) do
			if v.fire then
				ret:AddScript(string.format("Board:Ping(%s, GL_Color(255, 100, 0))", v.p:GetString()))
				ret:AddScript(string.format("Board:SetLava(%s,false)", v.p:GetString()))
				if v.iFire then
					local d = SpaceDamage(v.p)
					d.iFire = 2
					ret:AddDamage(d)
				end
				ret:AddSound("/props/square_lightup")
				ret:AddSound("/props/fire_damage")
				ret:AddDelay(delay.get)
			end
		end
		
		ret:AddDelay(delay.pre_shoot)
		ret:AddSound("/weapons/fire_beam")
		fireLaser("effects/laser_fire", delay.shoot)
		for _, target in ipairs(targets) do
			local d = SpaceDamage(target)
			d.iFire = 1
			--d.sSound = "/props/fire_damage"
			ret:AddProjectile(d, "effects/lmn_shot_deflector_ray_fire", NO_DELAY)
		end
		ret:AddDelay(delay.post_shoot)
	end
	
	if pts.frozen then
		for _, v in ipairs(pts) do
			if v.frozen then
				ret:AddScript(string.format("Board:Ping(%s, GL_Color(100, 255, 255))", v.p:GetString()))
				ret:AddScript(string.format("Board:SetFrozen(%s,false)", v.p:GetString()))
				ret:AddSound("/props/square_lightup")
				ret:AddSound("/weapons/refrigerate")
				if Board:IsTerrain(v.p, TERRAIN_ICE) then
					ret:AddScript(string.format("Board:SetTerrain(%s, TERRAIN_WATER)", v.p:GetString()))
				end
				ret:AddDelay(delay.get)
			end
		end
		
		ret:AddDelay(delay.pre_shoot)
		ret:AddSound("/weapons/freeze_beam")
		fireLaser("effects/laser_freeze", delay.shoot)
		for _, target in ipairs(targets) do
			local d = SpaceDamage(target)
			d.iFrozen = 1
			--d.sSound = "/weapons/refrigerate"
			ret:AddProjectile(d, "effects/lmn_shot_deflector_ray_frozen", NO_DELAY)
		end
		ret:AddDelay(delay.post_shoot)
	end
	
	for _, v in ipairs(pts) do
		if not list_contains(targets, v.p) then
			local d = SpaceDamage(v.p)
			local isMark = true
			if v.frozen then
				d.sImageMark = "combat/icons/lmn_deflector_ray_rem_frozen.png"
			elseif v.fire then
				d.sImageMark = "combat/icons/lmn_deflector_ray_rem_fire.png"
			elseif v.smoke then
				d.sImageMark = "combat/icons/lmn_deflector_ray_rem_smoke.png"
			elseif v.acid then
				d.sImageMark = "combat/icons/lmn_deflector_ray_rem_acid.png"
			else
				isMark = false
			end
			if isMark then
				ret:AddDamage(d)
			end
		end
	end
	
	return ret
end