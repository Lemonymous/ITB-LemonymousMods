
local mod = mod_loader.mods[modApi.currentMod]
local resourcePath = mod.resourcePath
local imageOffset = modApi:getPaletteImageOffset(mod.id)
local shop = LApi.library:fetch("shop")

lmn_ChemMech = Pawn:new{
	Name = "Dissolver Mech",
	Class = "Science",
	Health = 3,
	MoveSpeed = 3,
	Image = "lmn_MechDissolver",
	ImageOffset = imageOffset,
	SkillList = { "lmn_ChemicalAtk" },
	SoundLocation = "/mech/science/pulse_mech/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Massive = true,
}
AddPawnName("lmn_ChemMech")

lmn_ChemicalAtk = Skill:new{
	Name = "Acid Jet",
	Description = "Push and spray an adjacent tile with A.C.I.D.\n\nDamage units already inflicted with A.C.I.D.",
	Icon = "weapons/lmn_weapon_chem.png",
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
			damage.sAnimation = "lmn_acidthrower".. distance .."_".. dir 
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

function lmn_ChemicalAtk_Tip:GetSkillEffect(p1, p2, parentSkill)
	local damage = SpaceDamage(Point(1,2))
	damage.iAcid = EFFECT_CREATE
	Board:DamageSpace(damage)
	return lmn_ChemicalAtk.GetSkillEffect(self, p1, p2, parentSkill, isTipImage)
end

lmn_ChemicalAtk_Tip_B.GetSkillEffect = lmn_ChemicalAtk_Tip.GetSkillEffect

shop:addWeapon({
	id = "lmn_ChemicalAtk",
	desc = "Adds Acid Jet to the store."
})

modApi:appendAsset("img/units/player/lmn_mech_dissolver.png", resourcePath.. "img/units/player/dissolver.png")
modApi:appendAsset("img/units/player/lmn_mech_dissolver_a.png", resourcePath.. "img/units/player/dissolver_a.png")
modApi:appendAsset("img/units/player/lmn_mech_dissolver_w.png", resourcePath.. "img/units/player/dissolver_w.png")
modApi:appendAsset("img/units/player/lmn_mech_dissolver_broken.png", resourcePath.. "img/units/player/dissolver_broken.png")
modApi:appendAsset("img/units/player/lmn_mech_dissolver_w_broken.png", resourcePath.. "img/units/player/dissolver_w_broken.png")
modApi:appendAsset("img/units/player/lmn_mech_dissolver_ns.png", resourcePath.. "img/units/player/dissolver_ns.png")
modApi:appendAsset("img/units/player/lmn_mech_dissolver_h.png", resourcePath.. "img/units/player/dissolver_h.png")

modApi:appendAsset("img/weapons/lmn_weapon_chem.png", resourcePath .."img/weapons/acidjet.png")
for k = 1, 3 do
	for _, dir in ipairs({"D", "L", "R", "U"}) do
		local ext = k .."_".. dir ..".png"
		modApi:appendAsset("img/effects/lmn_acidthrower".. ext, resourcePath .."img/effects/acidthrower".. ext)
	end
end

setfenv(1, ANIMS)
lmn_MechDissolver =			MechUnit:new{ Image = "units/player/lmn_mech_dissolver.png", PosX = -19, PosY = 0 }
lmn_MechDissolvera =		lmn_MechDissolver:new{ Image = "units/player/lmn_mech_dissolver_a.png", NumFrames = 4 }
lmn_MechDissolver_broken =	lmn_MechDissolver:new{ Image = "units/player/lmn_mech_dissolver_broken.png" }
lmn_MechDissolverw =		lmn_MechDissolver:new{ Image = "units/player/lmn_mech_dissolver_w.png", PosY = 8 }
lmn_MechDissolverw_broken =	lmn_MechDissolverw:new{ Image = "units/player/lmn_mech_dissolver_w_broken.png" }
lmn_MechDissolver_ns =		MechIcon:new{ Image = "units/player/lmn_mech_dissolver_ns.png" }

lmn_acidthrower1_0 = Animation:new{
	Image = "effects/lmn_acidthrower1_U.png",
	NumFrames = 9,
	Time = 0.07,
	PosX = -60,
	PosY = -8
}
lmn_acidthrower2_0 = lmn_acidthrower1_0:new{ Image = "effects/lmn_acidthrower2_U.png" }
lmn_acidthrower3_0 = lmn_acidthrower1_0:new{ Image = "effects/lmn_acidthrower3_U.png" }

lmn_acidthrower1_1 = lmn_acidthrower1_0:new{
	Image = "effects/lmn_acidthrower1_R.png",
	PosX = -62,
	PosY = -34
}
lmn_acidthrower2_1 = lmn_acidthrower1_1:new{ Image = "effects/lmn_acidthrower2_R.png" }
lmn_acidthrower3_1 = lmn_acidthrower1_1:new{ Image = "effects/lmn_acidthrower3_R.png" }

lmn_acidthrower1_2 = lmn_acidthrower1_0:new{
	Image = "effects/lmn_acidthrower1_D.png",
	PosX = -25,
	PosY = -34
}
lmn_acidthrower2_2 = lmn_acidthrower1_2:new{ Image = "effects/lmn_acidthrower2_D.png" }
lmn_acidthrower3_2 = lmn_acidthrower1_2:new{ Image = "effects/lmn_acidthrower3_D.png" }

lmn_acidthrower1_3 = lmn_acidthrower1_0:new{
	Image = "effects/lmn_acidthrower1_L.png",
	PosX = -22,
	PosY = -8
}
lmn_acidthrower2_3 = lmn_acidthrower1_3:new{ Image = "effects/lmn_acidthrower2_L.png" }
lmn_acidthrower3_3 = lmn_acidthrower1_3:new{ Image = "effects/lmn_acidthrower3_L.png" }
	