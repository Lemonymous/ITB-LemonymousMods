
lmn_ChemicalAtk = Skill:new{
	Name = "Acid Jet",
	Description = "Push and spray an adjacent tile with A.C.I.D.\n\nDamage units already inflicted with A.C.I.D.",
	Icon = "weapons/dm_acidjet.png",
	Class = "Science",
	Range = 1,
	Push = 1,
	Damage = 2,
	Upgrades = 2,
	UpgradeCost = { 1 , 2 },
	UpgradeList = { "+1 Range", "+1 Damage" },
	CustomTipImage = "lmn_ChemicalAtk_Tip",
	-- unsure about using the flamethrower sound.
	-- just the acid splash sounds a bit lacking.
	-- using both for the time being.
	LaunchSound = "/weapons/flamethrower",
	ImpactSound = "/props/acid_splash",			
	TipImage = {
		Unit = Point(2,2),
		Enemy = Point(2,1),
		Target = Point(2,1),
		Enemy2 = Point(1,2),
		Second_Origin = Point(2,2),
		Second_Target = Point(1,2),
	},
}

function lmn_ChemicalAtk:GetTargetArea(point)
	local ret = PointList()
	for i = DIR_START, DIR_END do
		for k = 1, self.Range do
			local curr = DIR_VECTORS[i] * k + point
			ret:push_back(curr)
			if not Board:IsValid(curr) or Board:GetTerrain(curr) == TERRAIN_MOUNTAIN then
				break
			end
		end
	end
	
	return ret
end

function lmn_ChemicalAtk:GetSkillEffect(p1, p2)
	local ret = effect or SkillEffect()
	local dir = GetDirection(p2 - p1)
	local distance = p1:Manhattan(p2)
	local sound = SpaceDamage(p2)
	sound.sSound = self.ImpactSound		-- add the acid splash sound immediately.
	ret:AddDamage(sound)

	for i = 1, distance do
		local curr = p1 + DIR_VECTORS[dir] * i
		local push = (i == distance) and dir * self.Push or DIR_NONE
		local damage = SpaceDamage(curr, 0, push)
		damage.iAcid = EFFECT_CREATE
		
		if Board:IsPawnSpace(curr) then
			--damage.sSound = self.ImpactSound
			if Board:GetPawn(curr):IsAcid() then
				damage.iDamage = damage.iDamage + self.Damage
				damage.sAnimation = "ExploAcid1"
			end
		end
		
		if i == distance then
			damage.sAnimation = "dm_acidthrower".. distance .."_".. dir 
		end
		ret:AddDamage(damage)
		
		if i == distance then
			ret:AddDelay(0.4)
			local damage = SpaceDamage(curr)
			damage.iAcid = EFFECT_CREATE
			damage.bHide = true
			ret:AddDamage(damage)
		end
	end

	return ret
end

lmn_ChemicalAtk_A = lmn_ChemicalAtk:new{
	UpgradeDescription = "Extends range by 1 tile. Pushes furthest tile.",
	CustomTipImage = "",
	Range = 2,
	TipImage = {
		Unit = Point(2,3),
		Enemy = Point(2,2),
		Enemy2 = Point(2,1),
		Target = Point(2,1),
		Second_Origin = Point(2,3),
		Second_Target = Point(2,2),
	},
}

lmn_ChemicalAtk_B = lmn_ChemicalAtk:new{
	UpgradeDescription = "Increases damage by 1.",
	CustomTipImage = "lmn_ChemicalAtk_Tip_B",
	Damage = 3,
}

lmn_ChemicalAtk_AB = lmn_ChemicalAtk_A:new{
	Range = 2,
	Damage = 3,
	TipImage = lmn_ChemicalAtk_A.TipImage,
}

lmn_ChemicalAtk_Tip = lmn_ChemicalAtk:new{}
lmn_ChemicalAtk_Tip_B = lmn_ChemicalAtk_B:new{}

function lmn_ChemicalAtk_Tip:GetSkillEffect(p1, p2)
	local damage = SpaceDamage(Point(1,2))
	damage.iAcid = EFFECT_CREATE
	Board:DamageSpace(damage)
	return lmn_ChemicalAtk.GetSkillEffect(self, p1, p2)
end

lmn_ChemicalAtk_Tip_B.GetSkillEffect = lmn_ChemicalAtk_Tip.GetSkillEffect

modApi:addWeaponDrop("lmn_ChemicalAtk")
	