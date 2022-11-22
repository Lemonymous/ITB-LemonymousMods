
local mod = mod_loader.mods[modApi.currentMod]
local path = mod.resourcePath
local worldConstants = mod.libs.worldConstants
local getModOptions = require(path .."scripts/libs/getModOptions")
local tips = mod.libs.tutorialTips
local id_spit = mod.id .."_roach_spit"
local a = ANIMS
local writepath = "img/units/aliens/"
local readpath = path .. writepath
local imagepath = writepath:sub(5,-1)
local this = {}

modApi:appendAsset(writepath .."lmn_roach.png", readpath .."roach.png")
modApi:appendAsset(writepath .."lmn_roacha.png", readpath .."roacha.png")
modApi:appendAsset(writepath .."lmn_roach_death.png", readpath .."roach_death.png")
modApi:appendAsset(writepath .."lmn_roach_emerge.png", readpath .."roach_emerge.png")
modApi:appendAsset(writepath .."lmn_roach_Bw.png", readpath .."roach_Bw.png")

modApi:appendAsset("img/portraits/enemy/lmn_Roach1.png", path .."img/portraits/enemy/Roach1.png")
modApi:appendAsset("img/portraits/enemy/lmn_Roach2.png", path .."img/portraits/enemy/Roach2.png")
modApi:appendAsset("img/portraits/enemy/lmn_RoachB.png", path .."img/portraits/enemy/RoachB.png")

local base = a.EnemyUnit:new{Image = imagepath .."lmn_roach.png", PosX = -24, PosY = 1}
local baseEmerge = a.BaseEmerge:new{Image = imagepath .."lmn_roach_emerge.png", PosX = -24, PosY = 1}

a.lmn_roach  =	base
a.lmn_roache =	baseEmerge
a.lmn_roacha =	base:new{ Image = "units/aliens/lmn_roacha.png", NumFrames = 4 }
a.lmn_roachd =	base:new{ Image = "units/aliens/lmn_roach_death.png", NumFrames = 8, Time = 0.14, Loop = false }
a.lmn_roachw =	base:new{ Image = "units/aliens/lmn_roach_Bw.png", PosY = 10 }

local function IsRoach(pawn)
	return
		list_contains(_G[pawn:GetType()].SkillList, "lmn_RoachAtk1") or
		list_contains(_G[pawn:GetType()].SkillList, "lmn_RoachAtk2") or
		list_contains(_G[pawn:GetType()].SkillList, "lmn_RoachAtkB")
end

lmn_Roach1 = Pawn:new{
	Name = "Roach",
	Health = 2,
	MoveSpeed = 4,
	Armor = true,
	Image = "lmn_roach",
	ImageOffset = 0,
	SkillList = { "lmn_RoachAtk1" },
	SoundLocation = "/enemy/scorpion_soldier_1/",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_INSECT,
	Portrait = "enemy/lmn_Roach1",
}
AddPawnName("lmn_Roach1")

lmn_Roach2 = lmn_Roach1:new{
	Name = "Alpha Roach",
	Health = 4,
	MoveSpeed = 4,
	Image = "lmn_roach",
	ImageOffset = 1,
	SkillList = { "lmn_RoachAtk2" },
	SoundLocation = "/enemy/scorpion_soldier_2/",
	Tier = TIER_ALPHA,
	Portrait = "enemy/lmn_Roach2",
}
AddPawnName("lmn_Roach2")

lmn_RoachBoss = lmn_Roach1:new{
	Name = "Roach Leader",
	Health = 6,
	MoveSpeed = 4,
	Image = "lmn_roach",
	ImageOffset = 2,
	SkillList = { "lmn_RoachAtkB" },
	SoundLocation = "/enemy/scorpion_soldier_2/",
	Tier = TIER_BOSS,
	Portrait = "enemy/lmn_RoachB",
	Massive = true,
}
AddPawnName("lmn_RoachBoss")

lmn_RoachAtk1 = Skill:new{
	Name = "Scything Talons",
	Description = "Spit A.C.I.D. on an adjacent target, preparing to slice it.",
	Icon = "weapons/lmn_roach.png",
	Class = "Enemy",
	PathSize = 1,
	Damage = 1,
	Range = 1,
	Acid = 1,
	VelY = 1,
	LaunchSound = "",
	Shot = "effects/shot_roach",
	Upshot = "effects/shotup_acid_roach.png",
	MeleeSound = "/enemy/scorpion_soldier_1/attack",
	MeleeArt = "SwipeClaw1",
	Explo = "lmn_ExploRoach",
	AcidSound1 = "/impact/dynamic/enemy_projectile",
	AcidSound2 = "/enemy/spider_boss_1/attack_egg_land",
	CustomTipImage = "lmn_RoachAtk1_Tip",
	TipImage = {
		CustomPawn = "lmn_Roach1",
		Unit = Point(2,2),
		Enemy = Point(2,1),
		Target = Point(2,1),
	}
}

local isTargetScore = false
function lmn_RoachAtk1:GetTargetScore(p1, p2)

	isTargetScore = true
	local result = Skill.GetTargetScore(self, p1, p2)
	isTargetScore = false

	return result
end

function lmn_RoachAtk1:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)

	-- Queued attacks are weird. Make sure
	-- we have the correct pawn.
	local pawn = Board:GetPawn(p1)
	if not pawn or not IsRoach(pawn) then
		return ret
	end

	if isTargetScore then
		-- simulate attack for attack score
		local scoredPawn = false

		for k = 1, self.Range do
			local curr = p1 + DIR_VECTORS[dir] * k

			if Board:IsBlocked(curr, PATH_PROJECTILE) then
				if Board:IsPawnSpace(curr) then
					-- score only first pawn.
					if not scoredPawn then
						ret:AddQueuedDamage(SpaceDamage(curr, 1))
						scoredPawn = true
					end
				else
					-- end scoring at solid obstacle.
					ret:AddQueuedDamage(SpaceDamage(curr, 1))
					break
				end
			end
		end
	else
		-- actual attack

		if Board:IsTipImage() then
			ret:AddDelay(0.8)

		elseif self == lmn_RoachAtkB then
			ret:AddScript(string.format([[
				local tips = mod_loader.mods.lmn_bots_and_bugs.libs.tutorialTips;
				tips:trigger("Roach_Boss_Atk", %s);
			]], p1:GetString()))
		end

		for k = 1, self.Range do
			local curr = p1 + DIR_VECTORS[dir] * k

			if not Board:IsValid(curr) then
				break
			end

			p2 = curr

			if Board:IsBlocked(curr, PATH_PROJECTILE) then
				break
			end
		end

		local distance = p1:Manhattan(p2)
		local shouldSpit = not this.delay_roach_spit

		if this.delay_roach_spit then
			local m = GetCurrentMission()
			if m then
				m[id_spit] = m[id_spit] or {}
				shouldSpit = m[id_spit][pawn:GetId()]
			end
		end

		if Board:IsTipImage() or shouldSpit then
			local spit = SpaceDamage(p2)
			spit.iAcid = self.Acid
			spit.sSound = self.AcidSound1
			spit.sAnimation = self.Explo

			local sound = SpaceDamage(p2)
			sound.bHide = true
			sound.sSound = self.AcidSound2

			if distance == 1 then
				ret:AddProjectile(p1, spit, self.Shot, NO_DELAY)
				ret:AddProjectile(p1, sound, "", NO_DELAY)
			else
				worldConstants:setHeight(ret, self.VelY)
				ret:AddArtillery(p1, spit, self.Upshot, NO_DELAY)
				ret:AddArtillery(p1, sound, "", NO_DELAY)
				worldConstants:resetHeight(ret)
			end
		end

		if distance == 1 then
			local d = SpaceDamage(p2, self.Damage)
			d.sAnimation = self.MeleeArt

			local s = SpaceDamage(p2)
			s.sSound = self.MeleeSound
			ret:AddQueuedDamage(s)
			ret:AddQueuedMelee(p1, d)
		else
			-- hack to preview projectile dots.
			worldConstants:queuedSetSpeed(ret, 999)
			ret:AddQueuedProjectile(SpaceDamage(p2), "", NO_DELAY)
			worldConstants:queuedResetSpeed(ret)

			local ranged = SpaceDamage(p2, self.Damage)
			ranged.bHidePath = true
			ranged.iAcid = 1
			ranged.sSound = self.AcidSound1

			local sound = SpaceDamage(p2)
			sound.bHide = true
			sound.sSound = self.AcidSound2

			worldConstants:queuedSetHeight(ret, self.VelY)
			ret:AddQueuedArtillery(ranged, self.Upshot, NO_DELAY)
			ret:AddQueuedArtillery(sound, "", NO_DELAY)
			worldConstants:queuedResetHeight(ret)
		end
	end

	return ret
end

lmn_RoachAtk2 = lmn_RoachAtk1:new{
	Name = "Rending Talons",
	Damage = 3,
	MeleeSound = "/enemy/scorpion_soldier_2/attack",
	MeleeArt = "SwipeClaw2",
	CustomTipImage = "lmn_RoachAtk2_Tip",
	TipImage = {
		CustomPawn = "lmn_Roach2",
		Unit = Point(2,2),
		Enemy = Point(2,1),
		Target = Point(2,1),
	}
}

lmn_RoachAtkB = lmn_RoachAtk2:new{
	Name = "Acid Glands",
	Description = "Spit A.C.I.D. up to 2 tiles, preparing to attack.",
	Range = 2,
	CustomTipImage = "lmn_RoachAtkB_Tip",
	TipImage = {
		CustomPawn = "lmn_RoachBoss",
		Unit = Point(2,2),
		Enemy = Point(2,0),
		Building = Point(2,1),
		Target = Point(2,1),
		Second_Origin = Point(2,2),
		Second_Target = Point(2,0)
	}
}

lmn_RoachAtk1_Tip = lmn_RoachAtk1:new{}
lmn_RoachAtk2_Tip = lmn_RoachAtk2:new{}
lmn_RoachAtkB_Tip = lmn_RoachAtkB:new{}

function lmn_RoachAtk1_Tip:GetSkillEffect(p1, p2)
	return lmn_RoachAtk1.GetSkillEffect(self, p1, p2)
end

lmn_RoachAtk2_Tip.GetSkillEffect = lmn_RoachAtk1_Tip.GetSkillEffect

function lmn_RoachAtkB_Tip:GetTargetArea(p, ...)
	return Board:GetSimpleReachable(p, 2, false)
end

function lmn_RoachAtkB_Tip:GetSkillEffect(p1, p2)
	if p2 == self.TipImage.Target then
		Board:SetTerrain(self.TipImage.Building, TERRAIN_MOUNTAIN)
		Board:SetTerrain(self.TipImage.Building, TERRAIN_BUILDING)
	else
		p2 = self.TipImage.Target
	end
	local ret = lmn_RoachAtkB.GetSkillEffect(self, p1, p2)
	ret:AddDelay(0.8)

	return ret
end

local function enableSpit(m)
	local pawns = extract_table(Board:GetPawns(TEAM_ENEMY))

	m[id_spit] = m[id_spit] or {}
	for _, pawnId in ipairs(pawns) do
		local pawn = Board:GetPawn(pawnId)
		if IsRoach(pawn) then
			m[id_spit][pawnId] = true
		end
	end
end

function this:load()
	local modOptions = getModOptions()
	this.delay_roach_spit = modOptions["option_roach_delay_spit"].enabled

	if this.delay_roach_spit then
		modApi:addMissionStartHook(function(m)
			enableSpit(m)
		end)

		modApi:addNextTurnHook(function(m)
			if Game:GetTeamTurn() == TEAM_PLAYER then
				enableSpit(m)
			end
		end)
	end
end

return this