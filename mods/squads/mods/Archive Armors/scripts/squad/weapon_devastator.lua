
lmn_DevastatorCannon = Skill:new{
	Name = "Devastator",
	Class = "Brute",
	Icon = "weapons/aa_devastaor.png",
	Description = "Devastating projectile damaging its target and 3 adjacent tiles.\nPushes outer tiles and the shooter.",
	sExplosion = "ExploAir2",
	sProjectileEffect = "effects/aa_shot_devastator",
	sLaunchSound = "/weapons/wide_shot",
	sImpactSound = "/impact/generic/explosion_large",
	Range = INT_MAX,
	Push = 1,
	Damage = 3,
	SecondaryDamage = 3,
	PowerCost = 2,
	Upgrades = 1,
	UpgradeCost = {2},
	UpgradeList = {"Center Damage"},
	TipImage = {
		Unit = Point(2,3),
		CustomPawn = "lmn_DevastatorMech",
		Enemy = Point(2,1),
		Enemy2 = Point(3,1),
		Friendly = Point(1,1),
		Target = Point(2,1)
	},
}

function lmn_DevastatorCannon:GetTargetArea(point)
	local ret = PointList()

	-- allow the player to select any tile in every direction,
	-- since all we care about is the direction of the shot.
	for i = DIR_START, DIR_END do
		for k = 1, self.Range do
			if Board:IsValid(DIR_VECTORS[i]*k + point) then
				ret:push_back(DIR_VECTORS[i]*k + point)
			else
				break
			end
		end
	end

	return ret
end


function lmn_DevastatorCannon:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	local target = p2

	-- calculate the end of the projectile.
	for k = 1, self.Range do
		local point = DIR_VECTORS[dir]*k + p1
		if not Board:IsValid(point) or Board:IsBlocked(point, PATH_PROJECTILE) then
			target = point
			break
		end
	end
	target = GetProjectileEnd(p1,target,PATH_PROJECTILE)

	-- push back tank.
	local damage = SpaceDamage(p1, 0, GetDirection(p1 - p2))
	damage.sAnimation = "airpush_" .. GetDirection(p1 - p2)
	ret:AddDamage(damage)
	ret:AddBounce(p1, 2)

	if self.Smoke == 1 and p1 + DIR_VECTORS[dir] ~= target then
		-- first apply smoke.
		damage = SpaceDamage(p1 + DIR_VECTORS[dir])
		damage.iSmoke = 1
		ret:AddDamage(damage)

		--[[
			then overwrite the smoke mark
			with our own custom smoke mark
			with projectile arrow integrated.
		--]]
		damage.iSmoke = 0
		damage.sImageMark = "combat/projectile_over_smoke_".. dir ..".png"
		ret:AddDamage(damage)
	end

	-- main damage to target.
	damage = SpaceDamage(target, self.Damage)
	damage.sAnimation = self.sExplosion
	damage.sSound = self.sImpactSound
	if self.Smoke == 1 and p1 + DIR_VECTORS[dir] == target then
		damage.iSmoke = 1
	end
	ret:AddSound(self.sLaunchSound)
	ret:AddProjectile(damage, self.sProjectileEffect)
	ret:AddBounce(target, self.Damage)
	ret:AddDelay(0.2)

	-- damage to outer tiles.
	local outerPoint = { DIR_VECTORS[dir], DIR_VECTORS[(dir+1)%4], DIR_VECTORS[(dir-1)%4] }
	for k = 1, 3 do
		if Board:IsValid(outerPoint[k] + target) then
			damage = SpaceDamage(outerPoint[k] + target, self.SecondaryDamage)
			if self.Push == 1 then
				damage.iPush = GetDirection(outerPoint[k])
				damage.sAnimation = "explopush2_" .. GetDirection(outerPoint[k])
			else
				damage.sAnimation = self.sExplosion
			end
			ret:AddDamage(damage)
			ret:AddBounce(outerPoint[k] + target, self.SecondaryDamage)
		end
	end

	return ret
end

lmn_DevastatorCannon_A = lmn_DevastatorCannon:new{
	UpgradeDescription = "Increases damage to center tile by 2.",
	Damage = 5,
}

modApi:addWeaponDrop("lmn_DevastatorCannon")
