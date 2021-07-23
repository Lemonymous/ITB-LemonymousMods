
local path = mod_loader.mods[modApi.currentMod].resourcePath
local utils = require(path .."scripts/utils")
local worldConstants = require(path .."scripts/worldConstants")

modApi:appendAsset("img/weapons/lmn_confusion_strike.png", path .."img/weapons/confusion_strike.png")

lmn_Confusion_Strike = Skill:new{
	Name = "Confusion Strike",
	Description = "Call in a strike on a single tile anywhere on the map, confusing the target.",
	Icon = "weapons/lmn_confusion_strike.png",
	Rarity = 1,
	PowerCost = 0,
	LaunchSound = "",
	Upgrades = 1,
	UpgradeCost = {1},
	UpgradeList = { "Push" },
	Limited = 1,
	CustomTipImage = "lmn_Confusion_Strike_Tip",
	TipImage = {
		Unit = Point(5,3),
		Enemy = Point(2,2),
		Friendly = Point(2,1),
		Target = Point(2,2)
	}
}

lmn_Confusion_Strike_A = lmn_Confusion_Strike:new{
	UpgradeDescription = "Pushes adjacent tiles.",
	CustomTipImage = "lmn_Confusion_Strike_Tip_A",
	Push = 1,
}

function lmn_Confusion_Strike:GetTargetArea(p)
	local ret = PointList()
	
	for _, p in ipairs(utils.getBoard()) do
		ret:push_back(p)
	end
	
	return ret
end

function lmn_Confusion_Strike:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	
	ret:AddSound("/props/airstrike")
	worldConstants.SetSpeed(ret, .5)
	ret:AddAirstrike(p2, "units/mission/lmn_specimen_plane.png")
	ret.effect:index(ret.effect:size()).fDelay = 0
	worldConstants.ResetSpeed(ret)
	
	ret:AddDelay(.15 + .20 * (p2.x + 1))
	ret:AddScript(string.format("Board:AddAnimation(%s, 'lmn_Specimen_Drop_1', ANIM_NO_DELAY)", p2:GetString()))
	
	ret:AddDelay(.30)
	ret:AddSound("/impact/generic/general")
	ret:AddSound("/enemy/shared/moved")
	ret:AddScript(string.format("Board:AddAnimation(%s, 'lmn_Specimen_Explo_Smoke2', ANIM_NO_DELAY)", p2:GetString()))
	
	ret:AddDamage(SpaceDamage(p2, 0, DIR_FLIP))
	
	if self.Push == 1 then
		for i = DIR_START, DIR_END do
			local d = SpaceDamage(p2 + DIR_VECTORS[i], 0, i)
			d.sAnimation = "exploout0_".. i
			ret:AddDamage(d)
		end
	end
	
	return ret
end

lmn_Confusion_Strike_Tip = lmn_Confusion_Strike:new{}
lmn_Confusion_Strike_Tip_A = lmn_Confusion_Strike:new{ Push = 1 }

function lmn_Confusion_Strike_Tip:GetSkillEffect(p1, p2, ...)
	Board:GetPawn(self.TipImage.Enemy):FireWeapon(self.TipImage.Friendly, 1)
	local ret = lmn_Confusion_Strike.GetSkillEffect(self, p1, p2, ...)
	ret:AddDelay(2)
	
	return ret
end

lmn_Confusion_Strike_Tip_A.GetSkillEffect = lmn_Confusion_Strike_Tip.GetSkillEffect