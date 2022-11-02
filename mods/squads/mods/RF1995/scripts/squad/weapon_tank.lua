
local mod = modApi:getCurrentMod()
local scriptPath = mod.scriptPath
local worldConstants = mod.libs.worldConstants
local virtualBoard = require(scriptPath .."libs/virtualBoard")
local effectPreview = mod.libs.effectPreview

lmn_Tank_Cannon = Skill:new{
	Self = "lmn_Tank_Cannon",
	Name = "Snubnose Cannon",
	Class = "Brute",
	Icon = "weapons/rf_cannon.png",
	Description = "Fires a pushing projectile 3 tiles.",
	ProjectileArt = "effects/rf_shot_cannon",
	Range = 3,
	Damage = 1,
	Push = true,
	Attacks = 1,
	PowerCost = 1,
	Upgrades = 2,
	UpgradeCost = {2, 3},
	UpgradeList = {"+1 Damage", "Double Shot"},
	CustomTipImage = "lmn_Tank_Cannon_Tip",
	TipImage = {
		CustomPawn = "lmn_TankMech",
		Unit = Point(2,3),
		Enemy = Point(2,1),
		Target = Point(2,1)
	}
}

function lmn_Tank_Cannon:GetTargetArea(point)
	local ret = PointList()
	for i = DIR_START, DIR_END do
		for k = 1, self.Range do
			local curr = DIR_VECTORS[i] * k + point
			if not Board:IsValid(curr) then
				break
			end
			ret:push_back(curr)
			if Board:IsBlocked(curr, PATH_PROJECTILE) then
				break
			end
		end
	end

	return ret
end

-- custom GetProjectileEnd, for multishot purposes.
function lmn_Tank_Cannon:GetProjectileEnd(p1, p2)
	assert(type(p1) == 'userdata')
	assert(type(p1.x) == 'number')
	assert(type(p1.y) == 'number')
	assert(type(p2) == 'userdata')
	assert(type(p2.x) == 'number')
	assert(type(p2.y) == 'number')

	local dir = GetDirection(p2 - p1)
	local target = p1

	for k = 1, self.Range do
		curr = p1 + DIR_VECTORS[dir] * k

		if not Board:IsValid(curr) then
			break
		end

		target = curr

		if Board:IsBlocked(target, PATH_PROJECTILE) then
			local pawn = Board:GetPawn(target)
			if	not pawn					or
				pawn:GetHealth() > 0		or	-- healthy pawns block shots
				pawn:IsMech()				or	-- mechs always block shots
				_G[pawn:GetType()].Corpse		-- corpses always block shots
			then
				break
			end
		end
	end

	return target
end

function lmn_Tank_Cannon:GetSkillEffect(p1, p2, numberOfAttacks)
	local ret = SkillEffect()
	local shooter = Board:GetPawn(p1)
	if not shooter then
		return ret
	end

	local id = shooter:GetId()
	local distance = p1:Manhattan(p2)
	local dir = GetDirection(p2 - p1)

	if numberOfAttacks then
		-- GetSkillEffect called recursively.
		ret.iOwner = shooter:GetId()
		ret.piOrigin = p1

		local target = self:GetProjectileEnd(p1, p2)
		local pawn = Board:GetPawn(target)
		local attacks = 1

		if not Board:IsBlocked(target, PATH_PROJECTILE) then
			-- unload shots on empty tiles.
			attacks = numberOfAttacks
		end

		for i = 1, attacks do
			numberOfAttacks = numberOfAttacks - 1

			ret:AddSound("/weapons/stock_cannons")

			local weapon = SpaceDamage(target, self.Damage)
			weapon.iPush = self.Push and dir or DIR_NONE
			weapon.sSound = "/impact/generic/explosion"
			weapon.sScript = string.format("Board:AddAnimation(%s, 'explopush1_%s', NO_DELAY)", target:GetString(), dir)

			worldConstants:setSpeed(ret, 1)
			ret:AddProjectile(p1, weapon, "effects/rf_shot_cannon", NO_DELAY)
			worldConstants:resetSpeed(ret)

			-- minimum delay between shots.
			-- can take longer due to board being resolved.
			ret:AddDelay(0.3)
		end
	else
		-- GetSkillEffect called by the game.

		----------------
		-- damage marks
		----------------
		if Board:IsTipImage() then
			-- hardcoded tipimage marks.
			worldConstants:setSpeed(ret, 999)
			ret:AddProjectile(p1, SpaceDamage(self.TipProjectileEnd), "", NO_DELAY)
			worldConstants:resetSpeed(ret)

			for i, v in ipairs(self.TipMarks) do
				local tile = v[1]
				local damage = v[2]
				local mark = SpaceDamage(tile)
				mark.iPush = 0

				if Board:IsPawnSpace(tile) then
					mark.iDamage = damage
					if tile ~= self.TipProjectileEnd then
						mark.sImageMark = "combat/rf_preview_arrow_" .. damage ..".png"
					end
				elseif tile == self.TipProjectileEnd then
					mark.sImageMark = "combat/rf_faded_".. damage ..".png"
				end

				effectPreview:addDamage(ret, mark)
			end
		else
			-- mark board.
			local vBoard = virtualBoard.new()

			local target = p1
			for i = 1, self.Attacks do

				-- GetProjectileEnd
				for k = 1, self.Range do
					local curr = p1 + DIR_VECTORS[dir] * k
					if not Board:IsValid(curr) then
						break
					end

					target = curr

					if vBoard:IsBlocked(curr) then
						break
					end
				end

				-- apply damage to virtual board.
				vBoard:DamageSpace(SpaceDamage(target, self.Damage, self.Push and dir or DIR_NONE))
			end

			-- preview projectile path.
			worldConstants:setSpeed(ret, 999)
			ret:AddProjectile(p1, SpaceDamage(target), "", NO_DELAY)
			worldConstants:resetSpeed(ret)

			-- mark tiles with vBoard state.
			vBoard:MarkDamage(ret)
		end
	end

	if numberOfAttacks == nil then
		numberOfAttacks = self.Attacks
	end

	if numberOfAttacks > 0 then
		ret:AddScript(string.format([=[
			local fx = SkillEffect();
			fx:AddScript([[
				Board:AddEffect(_G[%q]:GetSkillEffect(%s, %s, %s));
			]]);
			Board:AddEffect(fx);
		]=], self.Self, p1:GetString(), p2:GetString(), numberOfAttacks))

	elseif Board:IsTipImage() then
		ret:AddDelay(1.3)
	end

	return ret
end

lmn_Tank_Cannon_A = lmn_Tank_Cannon:new{
	Self = "lmn_Tank_Cannon_A",
	UpgradeDescription = "Increases damage by 1.",
	Damage = 2,
	CustomTipImage = "lmn_Tank_Cannon_Tip_A",
}

lmn_Tank_Cannon_B = lmn_Tank_Cannon:new{
	Self = "lmn_Tank_Cannon_B",
	UpgradeDescription = "Shoots twice.",
	Attacks = 2,
	CustomTipImage = "lmn_Tank_Cannon_Tip_B",
}

lmn_Tank_Cannon_AB = lmn_Tank_Cannon:new{
	Self = "lmn_Tank_Cannon_AB",
	Damage = 2,
	Attacks = 2,
	CustomTipImage = "lmn_Tank_Cannon_Tip_AB",
}

lmn_Tank_Cannon_Tip = lmn_Tank_Cannon:new{
	Self = "lmn_Tank_Cannon_Tip",
	TipProjectileEnd = Point(2,1),
	TipMarks = {
		{Point(2,1), 1}
	}
}

function lmn_Tank_Cannon_Tip:GetSkillEffect(p1, p2, ...)
	return lmn_Tank_Cannon.GetSkillEffect(self, p1, p2, ...)
end

lmn_Tank_Cannon_Tip_A = lmn_Tank_Cannon_A:new{
	Self = "lmn_Tank_Cannon_Tip_A",
	TipProjectileEnd = Point(2,1),
	TipMarks = {
		{Point(2,1), 2}
	}
}

lmn_Tank_Cannon_Tip_B = lmn_Tank_Cannon_B:new{
	Self = "lmn_Tank_Cannon_Tip_B",
	TipProjectileEnd = Point(2,0),
	TipMarks = {
		{Point(2,1), 2},
		{Point(2,0), 1}
	}
}

lmn_Tank_Cannon_Tip_AB = lmn_Tank_Cannon_AB:new{
	Self = "lmn_Tank_Cannon_Tip_AB",
	TipProjectileEnd = Point(2,0),
	TipMarks = {
		{Point(2,1), 4},
		{Point(2,0), 2}
	}
}

lmn_Tank_Cannon_Tip_A.GetSkillEffect = lmn_Tank_Cannon_Tip.GetSkillEffect
lmn_Tank_Cannon_Tip_B.GetSkillEffect = lmn_Tank_Cannon_Tip.GetSkillEffect
lmn_Tank_Cannon_Tip_AB.GetSkillEffect = lmn_Tank_Cannon_Tip.GetSkillEffect


modApi:addWeaponDrop("lmn_Tank_Cannon")
