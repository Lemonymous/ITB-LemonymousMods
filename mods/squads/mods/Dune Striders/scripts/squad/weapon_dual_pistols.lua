
local mod = mod_loader.mods[modApi.currentMod]
local utils = require(mod.scriptPath .."libs/utils")
local effectBurst = LApi.library:fetch("effectBurst")
local trueMoveSpeed = LApi.library:fetch("trueMoveSpeed")

local function isEnemy(tile1, tile2)
	local invalidCheck = false
		or tile1 == nil
		or tile2 == nil
		or Board:IsPawnSpace(tile1) == false
		or Board:IsPawnSpace(tile2) == false

	if invalidCheck then
		return false
	end

	local team1 = Board:GetPawnTeam(tile1)
	local team2 = Board:GetPawnTeam(tile2)

	return team1 ~= team2
end

lmn_ds_DualPistols = Skill:new{
	Name = "Dual Pistols",
	Description = "Dash forward and fire to both sides when passing an enemy.\n\nMax move distance is equal to your Mech's movement speed.",
	Icon = "weapons/lmn_ds_dual_pistols.png",
	Class = "Brute",
	PowerCost = 2,
	Damage = 1,
	DamagePerShot = 1,
	Range = INT_MAX,
	MaxAttacks = 1,
	HoldFire = false,
	FocusFire = false,
	Upgrades = 2,
	UpgradeList = { "Hold Fire", "Focus Fire" },
	UpgradeCost = { 2, 3 },
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,1),
		Enemy1 = Point(1,2),
		Enemy2 = Point(1,1),
		Building3 = Point(3,2),
	}
}

lmn_ds_DualPistols_A = lmn_ds_DualPistols:new{
	UpgradeDescription = "Hold fire until passing the last enemy.",
	HoldFire = true,
}

lmn_ds_DualPistols_B = lmn_ds_DualPistols:new{
	UpgradeDescription = "Focus both shots when passing a single enemy.",
	MinDamage = 1,
	Damage = 2,
	FocusFire = true,
}

lmn_ds_DualPistols_AB = lmn_ds_DualPistols_B:new{
	HoldFire = true,
}

function lmn_ds_DualPistols:GetTargetArea(point)
	local ret = PointList()
	local terrain = Board:GetTerrain(point)

	for dir = DIR_START, DIR_END do
		for distance = 1, trueMoveSpeed:get(Pawn) do
			local curr = point + DIR_VECTORS[dir] * distance

			local isTraversableTile = true
				and Board:IsValid(curr)
				and utils.IsTilePassable(curr, Pawn)

			if isTraversableTile == false then
				break
			end

			local isValidEndTile = true
				-- and distance >= self.MinMove
				and Board:IsBlocked(curr, Pawn:GetPathProf()) == false

			if isValidEndTile then
				ret:push_back(curr)
			end
		end
	end

	return ret
end

function lmn_ds_DualPistols:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local distance = p1:Manhattan(p2)
	local dir_forward = GetDirection(p2 - p1)
	local dir_right = (dir_forward+1)%4
	local dir_left = (dir_forward-1)%4
	local vec_forward = DIR_VECTORS[dir_forward]
	local vec_right = DIR_VECTORS[dir_right]
	local vec_left = DIR_VECTORS[dir_left]
	local attackCount = 0
	local events = {}

	local first, last, step = 0, distance, 1

	if self.HoldFire then
		first, last, step = last, first, -step
	end

	-- find targets
	for dist = first, last, step do
		local curr = p1 + vec_forward * dist
		local right = utils.GetProjectileEnd(curr, curr + vec_right, nil, self.Range)
		local left = utils.GetProjectileEnd(curr, curr + vec_left, nil, self.Range)

		if right == curr then
			right = nil
		elseif left == curr then
			left = nil
		end

		local rightIsEnemy = isEnemy(p1, right)
		local leftIsEnemy = isEnemy(p1, left)

		if rightIsEnemy or leftIsEnemy then
			attackCount = attackCount + 1

			if self.FocusFire then
				if rightIsEnemy and not leftIsEnemy then
					left = right
				elseif leftIsEnemy and not rightIsEnemy then
					right = left
				end
			end

			events[dist] = {
				right = right,
				left = left,
			}

			if attackCount >= self.MaxAttacks then
				break
			end
		end
	end

	ret:AddSound("/mech/prime/punch_mech/move")
	ret:AddDelay(0.2)
	ret:AddSound("/enemy/shared/moved")
	ret:AddCharge(Board:GetPath(p1, p2, Pawn:GetPathProf()), NO_DELAY)

	-- add projectile events
	for dist = 0, distance do
		local curr = p1 + vec_forward * dist
		local event = events[dist]

		effectBurst.Add(ret, curr, "Emitter_Burst_$tile", dir_forward)
		effectBurst.Add(ret, curr, "Emitter_Burst_$tile", dir_forward)

		if event then
			local projectile = SpaceDamage(self.DamagePerShot)
			local effect
			local explosion
			projectile.sSound = "/props/electric_smoke_damage"

			if event.right and event.left then
				ret:AddSound("/weapons/fire_beam")
				ret:AddSound("/weapons/mirror_shot")
			else
				ret:AddSound("/weapons/fire_beam")
				ret:AddSound("/weapons/modified_cannons")
			end

			local isFocusFire = event.right == event.left
			for _, target in pairs(event) do
				local dir = GetDirection(target - curr)
				projectile.loc = target
				projectile.iPush = dir

				if isFocusFire then
					projectile.iDamage = self.DamagePerShot * 2
					effect = "effects/lmn_ds_shot_pistol_focus"
					if dir % 2 == 0 then
						explosion = "lmn_ds_explo_plasma_dual_U"
					else
						explosion = "lmn_ds_explo_plasma_dual_R"
					end
				else
					effect = "effects/lmn_ds_shot_pistol"
					explosion = "lmn_ds_explo_plasma"
				end

				projectile.sScript = string.format(
					"Game:TriggerSound(%q) "..
					"Board:AddAnimation(%s, %q, NO_DELAY) ",
					utils.GetImpactSound(target),
					target:GetString(),
					explosion
				)

				ret:AddProjectile(curr, projectile, effect, NO_DELAY)

				if isFocusFire then
					break
				end
			end
		end

		ret:AddDelay(0.08)
	end

	return ret
end
