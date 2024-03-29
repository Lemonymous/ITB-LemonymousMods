
lmn_LiftAtk = Skill:new{
	Name = "Fork Lift",
	Description = "Bash a unit; or throw it, pushing adjacent tiles.",
	Icon = "weapons/dm_stacker.png",
	Class = "Prime",
	Damage = 2,
	Range = INT_MAX,
	AllyImmune = false,
	ImpactDamage = false,
	JudoToss = false,
	Crush = false,
	PushBash = false,
	PushAdjacent = true,
	DamageAdjacent = false,
	PowerCost = 1,
	Upgrades = 2,
	UpgradeCost = { 1 , 3 },
	UpgradeList = { "Impact", "Crush" },
	CustomTipImage = "lmn_LiftAtk_Tip",
	TipImage = {
		Unit = Point(2,3),
		Enemy = Point(2,2),
		Friendly = Point(1,1),
		Target = Point(2,2),
		Second_Origin = Point(2,3),
		Second_Target = Point(2,1),
	}
}

-- returns whether thrown pawn can crush target pawn.
function lmn_LiftAtk:CanCrush(thrown, target)
	return	target										and
			self.Crush									and		-- must have upgrade
			thrown:GetHealth() > target:GetHealth()		and		-- thrown pawn must have more hp than target
			not list_contains({0,1,2}, target:GetId())	and		-- filter out mechs because they leave a corpse
			not target.corpse							and		-- filter out other pawns that leave a corpse
			_G[target:GetType()].Corporate == false				-- filter out terraformer, and maybe others?
end

function lmn_LiftAtk:IsAvailableTile(tile)
	return	not Board:IsPawnSpace(tile)					and
			not Board:IsBlocked(tile, PATH_PROJECTILE)
end

local function IsThrowable(pawn)
	return _G[pawn:GetType()].Pushable
end

function lmn_LiftAtk:GetTargetArea(point)
	local ret = PointList()

	for dir = DIR_START, DIR_END do
		local curr = point + DIR_VECTORS[dir]

		if Board:IsValid(curr) then
			ret:push_back(curr)
			local thrownPawn = Board:GetPawn(curr)
			if	thrownPawn				and
				IsThrowable(thrownPawn)	then

				for k = 2, self.Range do
					local curr = point + DIR_VECTORS[dir] * k

					if not Board:IsValid(curr) then
						break
					end

					local targetPawn = Board:GetPawn(curr)

					if	not Board:IsBlocked(curr, PATH_PROJECTILE)
					or	(targetPawn									 and
						self:CanCrush(thrownPawn, targetPawn))		then

						ret:push_back(curr)
					end
				end
			end
		end
	end

	return ret
end

function lmn_LiftAtk:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local distance = p1:Manhattan(p2)
	local dir = GetDirection(p2 - p1)
	local dir_back = (dir + 2)%4
	local pawnFront = Board:GetPawn(p1 + DIR_VECTORS[dir])
	local pawnBack = Board:GetPawn(p1 + DIR_VECTORS[dir_back])
	local bash = true
	local thrownPawn
	local pawnSpace

	if distance > 1 then
		if pawnFront then
			thrownPawn = pawnFront
			bash = false
		end
	elseif distance == 1 then
		if self.JudoToss and pawnBack then
			if self:IsAvailableTile(p1 + DIR_VECTORS[dir]) or self:CanCrush(pawnBack, pawnFront) then
				thrownPawn = pawnBack
				bash = false
			end
		end
	end

	if bash then
		local fx = SpaceDamage(p2)
		fx.sSound = "/weapons/titan_fist"
		if self.PushBash then
			fx.sAnimation = "explopush1_".. dir
			fx.iPush = dir
		else
			fx.sAnimation = "explosmash_".. dir
		end
		ret:AddDamage(fx)
		ret:AddDelay(0.05)

		ret:AddMelee(p1, SpaceDamage(p2), 0.20)

		local dmg = SpaceDamage(p2, self.Damage)
		ret:AddDamage(dmg)

	elseif thrownPawn then
		local throwFrom = thrownPawn:GetSpace()
		local crushedPawn = Board:GetPawn(p2)

		local damage = 0
		if self.ImpactDamage then
			local isEnemy =	isEnemy(Pawn:GetTeam(), thrownPawn:GetTeam())
			if isEnemy or not self.AllyImmune then
				damage = self.Damage
			end
		end

		local fx = SpaceDamage(throwFrom)
		fx.sSound = "/weapons/titan_fist"
		fx.sAnimation = "dm_exploforklift_".. GetDirection(throwFrom - p1)
		ret:AddDamage(fx)

		ret:AddMelee(p1, SpaceDamage(throwFrom), NO_DELAY)

		ret:AddDelay(0.1)
		local id = thrownPawn:GetId()
		-- hide pawn we are about to throw.
		ret:AddScript(string.format("Board:GetPawn(%s):SetSpace(Point(-1, -1))", id))
		-- preview damage to thrown pawn on it's original tile.
		local spaceDamage = SpaceDamage(throwFrom, damage)

		if self.PushAdjacent and throwFrom == p2 - DIR_VECTORS[dir] then
			spaceDamage.iPush = 5
			spaceDamage.sImageMark = "combat/dm_arrow_off_".. dir_back ..".png"
		end

		ret:AddDamage(spaceDamage)

		-- return pawn we are about to throw.
		ret:AddScript(string.format("Board:GetPawn(%s):SetSpace(%s)", id, throwFrom:GetString()))

		-- empty damage event to apply fire, etc.
		local spaceDamage = SpaceDamage(throwFrom)
		ret:AddDamage(spaceDamage)

		local leap = PointList()
		leap:push_back(throwFrom)
		leap:push_back(p2)

		ret:AddLeap(leap, NO_DELAY)

		if thrownPawn:IsMech() then
			ret:AddDelay(0.48)
			ret:AddSound("mech/land")
			ret:AddDelay(0.32)
		else
			ret:AddDelay(0.8)
		end

		-- hide thrown pawn.
		ret:AddScript(string.format("Board:GetPawn(%s):SetSpace(Point(-1, -1))", id))
		-- kill pawn being crushed.
		if crushedPawn then
			local death = SpaceDamage(p2, 499)	-- custom hidden DAMAGE_DEATH
			ret:AddDamage(death)				-- hides skull, but shows hp blinking.
			if
				crushedPawn:IsFrozen()	or
				crushedPawn:IsShield()	or
				crushedPawn:IsAcid()	or
				thrownPawn:IsAcid()		or
				Board:IsAcid(p2)		or
				crushedPawn:IsArmor()	or
				thrownPawn:IsArmor()
			then
				local death = SpaceDamage(p2, DAMAGE_DEATH)	-- show the skull to hide unwanted
				ret:AddDamage(death)						-- acid/frozen/shield/armor icons
			end
		end
		-- return thrown pawn.
		ret:AddScript(string.format("Board:GetPawn(%s):SetSpace(%s)",id , p2:GetString()))

		-- deal damage we previewed to thrown pawn at it's destination.
		ret:AddScript(string.format([[
			local p2, damage, id = %s, %s, %s
			local spaceDamage = SpaceDamage(p2, damage);
			if Board:GetTerrain(p2) == TERRAIN_WATER then
				Board:DamageSpace(spaceDamage);
			else
				local fx = SkillEffect();
				fx:AddSafeDamage(spaceDamage);
				for i = 1, fx.effect:size() do
					local d = fx.effect:index(i);
					Board:DamageSpace(d);
				end
			end
		]], p2:GetString(), damage, id))

		if self.PushAdjacent then
			local dirs = {0, 1, 2, 3}
			for _, i in ipairs(dirs) do
				local curr = p2 + DIR_VECTORS[i]
				if Board:IsValid(curr) then
					local dmg = self.DamageAdjacent and self.Damage or 0
					local spaceDamage = SpaceDamage(curr, dmg)
					spaceDamage.sAnimation = "exploout0_".. i

					if curr == p1 + DIR_VECTORS[dir] then
						spaceDamage.iPush = 5
						spaceDamage.sImageMark = "combat/dm_arrow_off_".. i ..".png"
					else
						spaceDamage.iPush = i
					end
					ret:AddDamage(spaceDamage)
				end
			end
		end
	end

	return ret
end

lmn_LiftAtk_A = lmn_LiftAtk:new{
	UpgradeDescription = "Enemies take damage when thrown.",
	ImpactDamage = true,
	AllyImmune = true,
	CustomTipImage = "lmn_LiftAtk_Tip_A",
	TipImage = {
		Unit = Point(2,3),
		Enemy = Point(2,2),
		--Forest = Point(2,2),
		Friendly = Point(1,1),
		Target = Point(2,1),
	},
}

lmn_LiftAtk_B = lmn_LiftAtk:new{
	UpgradeDescription = "Allows thrown unit to target and crush units with less health.",
	Crush = true,
	Crush_Target = Point(2,1),
	Crush_Type = "Scarab1",
	Crush_Anim = "scarab",
	CustomTipImage = "lmn_LiftAtk_Tip_B",
	TipImage = {
		Unit = Point(2,3),
		Enemy = Point(2,2),
		Friendly = Point(1,1),
		Target = Point(2,1),
	},
}

lmn_LiftAtk_AB = lmn_LiftAtk:new{
	ImpactDamage = true,
	AllyImmune = true,
	Crush = true,
	Crush_Target = lmn_LiftAtk_B.Crush_Target,
	Crush_Type = lmn_LiftAtk_B.Crush_Type,
	Crush_Anim = lmn_LiftAtk_B.Crush_Anim,
	CustomTipImage = "lmn_LiftAtk_Tip_AB",
	TipImage = lmn_LiftAtk_A.TipImage,
}

lmn_LiftAtk_Tip = lmn_LiftAtk:new{}
lmn_LiftAtk_Tip_A = lmn_LiftAtk_A:new{}
lmn_LiftAtk_Tip_B = lmn_LiftAtk_B:new{}
lmn_LiftAtk_Tip_AB = lmn_LiftAtk_AB:new{}

function lmn_LiftAtk_Tip:GetTargetArea(point)
	return lmn_LiftAtk.GetTargetArea(self, point)
end

function lmn_LiftAtk_Tip:GetSkillEffect(p1, p2)
	if
		self.Crush_Target	and
		self.Crush_Type		and
		self.Crush_Anim
	then

		Board:ClearSpace(self.Crush_Target)
		local unit = SpaceDamage(self.Crush_Target)
		unit.sPawn = self.Crush_Type
		Board:DamageSpace(unit)
		Board:GetPawn(self.Crush_Target):SetCustomAnim(self.Crush_Anim)
	end

	local ret = lmn_LiftAtk.GetSkillEffect(self, p1, p2)
	ret:AddDelay(1.5)
	return ret
end

lmn_LiftAtk_Tip_A.GetTargetArea = lmn_LiftAtk_Tip.GetTargetArea
lmn_LiftAtk_Tip_B.GetTargetArea = lmn_LiftAtk_Tip.GetTargetArea
lmn_LiftAtk_Tip_AB.GetTargetArea = lmn_LiftAtk_Tip.GetTargetArea
lmn_LiftAtk_Tip_A.GetSkillEffect = lmn_LiftAtk_Tip.GetSkillEffect
lmn_LiftAtk_Tip_B.GetSkillEffect = lmn_LiftAtk_Tip.GetSkillEffect
lmn_LiftAtk_Tip_AB.GetSkillEffect = lmn_LiftAtk_Tip.GetSkillEffect

modApi:addWeaponDrop("lmn_LiftAtk")
