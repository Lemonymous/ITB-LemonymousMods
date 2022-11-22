
local mod = mod_loader.mods[modApi.currentMod]
local path = mod.resourcePath
local modApiExt = mod.libs.modApiExt
local ID = mod.id .."_blobberlings"
local a = ANIMS
local writepath = "img/units/snowbots/"
local readpath = path .. writepath
local imagepath = writepath:sub(5,-1)
local this = {}

modApi:appendAsset(writepath .."snowshield1.png", readpath .."shieldbot1.png")
modApi:appendAsset(writepath .."snowshield1a.png", readpath .."shieldbot1a.png")
modApi:appendAsset(writepath .."snowshield1_off.png", readpath .."shieldbot1_off.png")
modApi:appendAsset(writepath .."snowshield1_death.png", readpath .."shieldbot1_death.png")

modApi:appendAsset(writepath .."snowshield2.png", readpath .."shieldbot2.png")
modApi:appendAsset(writepath .."snowshield2a.png", readpath .."shieldbot2a.png")
modApi:appendAsset(writepath .."snowshield2_off.png", readpath .."shieldbot2_off.png")
modApi:appendAsset(writepath .."snowshield2_death.png", readpath .."shieldbot2_death.png")

modApi:appendAsset("img/portraits/enemy/lmn_shieldbot1.png", mod.resourcePath.. "img/portraits/enemy/shieldbot1.png")
modApi:appendAsset("img/portraits/enemy/lmn_shieldbot2.png", mod.resourcePath.. "img/portraits/enemy/shieldbot2.png")
modApi:appendAsset("img/effects/lmn_shield_bot_pulse.png", mod.resourcePath.. "img/effects/explo_repulse_shield.png")
modApi:appendAsset("img/weapons/lmn_shieldbot.png", mod.resourcePath.. "img/weapons/weapon_icon.png")

local base =			a.BaseUnit:new{Image = imagepath .."snowshield1.png", PosX = -17, PosY = -4}

a.lmn_shieldbot1 =		base
a.lmn_shieldbot1a =		base:new{ Image = imagepath .."snowshield1a.png", NumFrames = 4 }
a.lmn_shieldbot1off =	base:new{ Image = imagepath .."snowshield1_off.png", PosY = 7 }
a.lmn_shieldbot1d =		base:new{ Image = imagepath .."snowshield1_death.png", PosX = -25, NumFrames = 11, Time = 0.12, Loop = false }

a.lmn_shieldbot2 =		a.lmn_shieldbot1:new{ Image = imagepath .."snowshield2.png" }
a.lmn_shieldbot2a =		a.lmn_shieldbot1a:new{ Image = imagepath .."snowshield2a.png" }
a.lmn_shieldbot2off =	a.lmn_shieldbot1off:new{ Image = imagepath .."snowshield2_off.png" }
a.lmn_shieldbot2d =		a.lmn_shieldbot1d:new{ Image = imagepath .."snowshield2_death.png" }

local function getQueuedSkill(pawn)
	if IsTestMechScenario() then
		return
	end

	assert(type(pawn) == 'userdata')

	local pawnId = pawn:GetId()
	local pawnType = pawn:GetType()
	local queuedAttack = pawn:GetQueued()

	if queuedAttack and queuedAttack.iQueuedSkill > 0 then
		return _G[pawnType].SkillList[queuedAttack.iQueuedSkill]
	end
end

lmn_ShieldBot1 = Pawn:new{
	Name = "Shield-Bot",
	Health = 1,
	MoveSpeed = 5,
	Image = "lmn_shieldbot1",
	Portrait = "enemy/lmn_shieldbot1",
	SkillList = { "lmn_ShieldBotAtk1" },
	SoundLocation = "/mech/science/science_mech/",
	DefaultTeam = TEAM_ENEMY,
	DefaultFaction = FACTION_BOTS,
	ImpactMaterial = IMPACT_METAL,
	Flying = true,
}
AddPawnName("lmn_ShieldBot1")

lmn_ShieldBotAtk1 = SelfTarget:new{
	Name = "NRG Shield Mark I",
	Description = "Raise a shield and overload it to push and damage adjacent tiles.",
	Icon = "weapons/lmn_shieldbot.png",
	Class = "Enemy",
	Damage = 1,
	Push = 1,
	TipImage = {
		Unit = Point(2,2),
		Enemy = Point(2,1),
		Enemy2 = Point(1,2),
		Target = Point(2,2),
		CustomPawn = "lmn_ShieldBot1",
	}
}

function lmn_ShieldBotAtk1:GetTargetScore(p1, p2)
	this.isTargetScore = true
	local ret = Skill.GetTargetScore(self, p1, p2)
	this.isTargetScore = nil

	-- make sure we shield ourself no matter what.
	if ret == 0 then
		ret = 1
	end
	return ret
end

function lmn_ShieldBotAtk1:GetSkillEffect(p1, p2)
	local ret = SkillEffect()

	local selfDamage = SpaceDamage(p1)
	selfDamage.iShield = 1
	ret:AddDamage(selfDamage)

	for i = DIR_START, DIR_END do
		local curr = p2 + DIR_VECTORS[i]

		if Board:IsValid(curr) then
			if this.isTargetScore then
				-- scoring for damage
				local spaceDamage = SpaceDamage(curr, self.Damage)
				ret:AddQueuedDamage(spaceDamage)

				local pawn = Board:GetPawn(curr)

				-- score push damage as well.
				if pawn and not pawn:IsGuarding() then
					spaceDamage.loc = curr + DIR_VECTORS[i]
					ret:AddQueuedDamage(spaceDamage)
				end
			else
				-- actual attack
				local spaceDamage = SpaceDamage(curr, self.Damage, i)
				spaceDamage.sAnimation = "exploout0_".. i
				ret:AddQueuedDamage(spaceDamage)
			end
		end
	end

	local selfDamage = SpaceDamage(p1)
	selfDamage.iShield = -1
	selfDamage.sAnimation = "lmn_ExploRepulseShield"
	selfDamage.sSound = "/weapons/science_repulse"
	ret:AddQueuedDamage(selfDamage)

	return ret
end

lmn_ShieldBot2 = lmn_ShieldBot1:new{
	Name = "Shield-Mech",
	Image = "lmn_shieldbot2",
	Portrait = "enemy/lmn_shieldbot2",
	SkillList = { "lmn_ShieldBotAtk2" },
	Tier = TIER_ALPHA,
}
AddPawnName("lmn_ShieldBot2")

lmn_ShieldBotAtk2 = lmn_ShieldBotAtk1:new{
	Name = "NRG Shield Mark II",
	Damage = 3,
	TipImage = {
		Unit = Point(2,2),
		Enemy = Point(2,1),
		Enemy2 = Point(1,2),
		Target = Point(2,2),
		CustomPawn = "lmn_ShieldBot2",
	}
}

ANIMS.lmn_ExploRepulseShield = ANIMS.ExploRepulse1:new{ Image = "effects/lmn_shield_bot_pulse.png" }

function this:load()
	modApiExt:addPawnIsShieldedHook(function(_, pawn, isShield)
		if not isShield then
			local queuedSkill = getQueuedSkill(pawn)

			if queuedSkill == "lmn_ShieldBotAtk1" or queuedSkill == "lmn_ShieldBotAtk2" then
				pawn:ClearQueued()
			end
		end
	end)
end

return this