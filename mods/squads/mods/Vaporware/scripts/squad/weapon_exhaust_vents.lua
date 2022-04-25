
modApi:addWeaponDrop("vw_Exhaust_Vents")


vw_Exhaust_Vents = Skill:new{
	Name = "Exhaust Vents",
	Description = "Cover 3 nearby tiles in Smoke.",
	Icon = "weapons/vw_exhaust_vents.png",
	Class = "Prime",
	PowerCost = 1,
	Range = 1,
	Upgrades = 2,
	UpgradeList = { "Push Smoke", "Range: 2" },
	UpgradeCost = { 1, 3 },
	TipImage = {
		Unit = Point(2,3),
		Target = Point (2,2),
		Enemy1 = Point(2,2),
	}
}

vw_Exhaust_Vents_A = vw_Exhaust_Vents:new{
	UpgradeDescription = "Push Smoke already present to the next tile.",
	PushSmoke = true,
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,2),
		Enemy1 = Point(2,1),
		Smoke1 = Point(2,2),
	}
}

vw_Exhaust_Vents_B = vw_Exhaust_Vents:new{
	UpgradeDescription = "Increases range to 2. Removes Smoke at range 1 when used at range 2.",
	Range = 2,
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,1),
		Enemy1 = Point(2,1),
		Smoke2 = Point(1,2),
	}
}

vw_Exhaust_Vents_AB = vw_Exhaust_Vents_A:new{
	Range = 2,
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,1),
		Enemy1 = Point(2,0),
		Smoke1 = Point(1,2),
		Smoke2 = Point(2,1),
	}
}

function vw_Exhaust_Vents:GetTargetArea(point)
	local ret = PointList()

	for dir = DIR_START, DIR_END do
		for distance = 1, self.Range do
			local curr = point + DIR_VECTORS[dir] * distance
			local tileIsInvalid = Board:IsValid(curr) == false

			if tileIsInvalid then
				break
			end

			ret:push_back(curr)
		end
	end

	return ret
end

function vw_Exhaust_Vents:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local distance = p1:Manhattan(p2)
	local dir = GetDirection(p2 - p1)
	local dir_right = (dir+1)%4
	local dir_left = (dir-1)%4
	local vec = DIR_VECTORS[dir]
	local vec_right = DIR_VECTORS[dir_right]
	local vec_left = DIR_VECTORS[dir_left]
	local pushSmoke = self.PushSmoke
	local pushUnits = self.PushUnits

	local smoke_create = SpaceDamage()
	smoke_create.iSmoke = EFFECT_CREATE
	smoke_create.sAnimation = "exploout0_"..dir

	local smoke_remove = SpaceDamage()
	smoke_remove.iSmoke = EFFECT_REMOVE
	smoke_remove.sAnimation = "airpush_"..dir
	smoke_remove.sImageMark = "combat/icons/vw_icon_smoke_immune_glow.png"

	ret:AddSound("/weapons/leap")

	for dist = 1, distance do
		local locs = {
			p1 + vec * dist,
			p1 + vec * dist + vec_right,
			p1 + vec * dist + vec_left,
		}

		for _, loc in ipairs(locs) do
			if dist == distance then
				smoke_create.loc = loc

				if pushSmoke and Board:IsSmoke(loc) then
					smoke_remove.loc = loc
					smoke_create.loc = loc + vec

					ret:AddDamage(smoke_remove)
				end

				ret:AddDamage(smoke_create)
			else
				smoke_remove.loc = loc
				ret:AddDamage(smoke_remove)
			end
		end

		ret:AddDelay(0.16)
	end

	return ret
end
