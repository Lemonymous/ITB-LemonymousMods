
local mod = mod_loader.mods[modApi.currentMod]
local path = mod.resourcePath
local utils = require(path .."scripts/libs/utils")
local astar = require(path .."scripts/libs/astar")
local modUtils = require(path .."scripts/modApiExt/modApiExt")
local selected = require(path .."scripts/libs/selected")
local weaponApi = require(path .."scripts/weapons/api")
local multishot = require(path .."scripts/multishot/api")
local armorDetection = require(path .."scripts/libs/armorDetection")
local worldConstants = require(path .."scripts/libs/worldConstants")
local weaponArmed = require(path .."scripts/libs/weaponArmed")
local weaponHover = require(path .."scripts/libs/weaponHover")
local previewer = require(path .."scripts/weaponPreview/api")
local tips = require(path .."scripts/libs/tutorialTips")
local a = ANIMS
local this = {}


--	___________
--	 Resources
--	‾‾‾‾‾‾‾‾‾‾‾

-- portraits
local imgs = {
	"Swarmer.png",
	"Roach.png",
	"Spitter.png",
	"Wyrm.png",
	"Crusher.png"
}

local writepath = "img/portraits/pilots/Pilot_lmn_"
local readpath = path .. "img/portraits/pilots/"
for _, img in ipairs(imgs) do
	modApi:appendAsset(writepath .. img, readpath .. img)
end

-- weapons
modApi:appendAsset("img/weapons/lmn_swarmer.png", path .."img/weapons/swarmer.png")
modApi:appendAsset("img/weapons/lmn_roach.png", path .."img/weapons/roach.png")
modApi:appendAsset("img/weapons/lmn_spitter.png", path .."img/weapons/spitter.png")
modApi:appendAsset("img/weapons/lmn_wyrm.png", path .."img/weapons/wyrm.png")
modApi:appendAsset("img/weapons/lmn_crusher.png", path .."img/weapons/crusher.png")

-- extra
modApi:copyAsset("img/combat/arrow_hit.png", "img/combat/lmn_crusher_arrow_hit.png")
Location["combat/lmn_crusher_arrow_hit.png"] = Point(-17,5)

-- pawns
local imgs = {
	"swarmer.png",
	"swarmer_a.png",
	"swarmer_broken.png",
	"swarmer_h.png",
	"swarmer_ns.png",
	"swarmer_w.png",
	"swarmer_w_broken.png",
	"swarmer_emerge.png",
	"roach.png",
	"roach_a.png",
	"roach_broken.png",
	"roach_h.png",
	"roach_ns.png",
	"roach_w.png",
	"roach_w_broken.png",
	"roach_emerge.png",
	"spitter.png",
	"spitter_a.png",
	"spitter_broken.png",
	"spitter_h.png",
	"spitter_ns.png",
	"spitter_w.png",
	"spitter_w_broken.png",
	"spitter_emerge.png",
	"wyrm.png",
	"wyrm_a.png",
	"wyrm_broken.png",
	"wyrm_h.png",
	"wyrm_ns.png",
	"wyrm_w_broken.png",
	"wyrm_emerge.png",
	"crusher.png",
	"crusher_a.png",
	"crusher_broken.png",
	"crusher_h.png",
	"crusher_ns.png",
	"crusher_w.png",
	"crusher_w_broken.png",
	"crusher_emerge.png",
}

local writepath = "img/units/player/lmn_techno_"
local readpath = path .. "img/units/player/"
for _, img in ipairs(imgs) do
	modApi:appendAsset(writepath .. img, readpath .. img)
end

local imagepath = "units/player/lmn_techno_swarmer"
local base = a.MechUnit:new{Image = imagepath ..".png", PosX = -16, PosY = 1}
local emerge = a.Animation:new{
	NumFrames = 10,
	Loop = false,
	Time = .15,
	Sound = "/enemy/shared/crawl_out",
	Height = GetColorCount()
}

a.lmn_techno_swarmer = base
a.lmn_techno_swarmera = base:new{Image = imagepath .."_a.png", NumFrames = 4}
a.lmn_techno_swarmer_broken = base:new{Image = imagepath .."_broken.png"}
a.lmn_techno_swarmerw = base:new{Image = imagepath .."_w.png", PosY = 10}
a.lmn_techno_swarmerw_broken = base:new{Image = imagepath .."_w_broken.png", PosY = 10}
a.lmn_techno_swarmer_ns = a.MechIcon:new{Image = imagepath .."_ns.png"}
a.lmn_techno_swarmere = emerge:new{
	Image = imagepath .."_emerge.png",
	NumFrames = 8,
	PosX = -20,
	PosY = 4,
	Time = .1,
}

local imagepath = "units/player/lmn_techno_roach"
local base = a.MechUnit:new{Image = imagepath ..".png", PosX = -20, PosY = 0}

a.lmn_techno_roach = base
a.lmn_techno_roacha = base:new{Image = imagepath .."_a.png", NumFrames = 4}
a.lmn_techno_roach_broken = base:new{Image = imagepath .."_broken.png", PosX = -23} -- base.x - 3
a.lmn_techno_roachw = base:new{Image = imagepath .."_w.png", PosY = 9}
a.lmn_techno_roachw_broken = base:new{Image = imagepath .."_w_broken.png", PosX = -23, PosY = 9}
a.lmn_techno_roach_ns = a.MechIcon:new{Image = imagepath .."_ns.png"}
a.lmn_techno_roache = emerge:new{Image = imagepath .."_emerge.png", PosX = -21, PosY = 1}

local imagepath = "units/player/lmn_techno_spitter"
local base = a.MechUnit:new{Image = imagepath ..".png", PosX = -17, PosY = -12}

a.lmn_techno_spitter = base
a.lmn_techno_spittera = base:new{Image = imagepath .."_a.png", NumFrames = 4}
a.lmn_techno_spitter_broken = base:new{Image = imagepath .."_broken.png"} -- base.x - 4
a.lmn_techno_spitterw = base:new{Image = imagepath .."_w.png", PosY = 1}
a.lmn_techno_spitterw_broken = base:new{Image = imagepath .."_w_broken.png", PosY = 1} -- base.x - 4
a.lmn_techno_spitter_ns = a.MechIcon:new{Image = imagepath .."_ns.png"}
a.lmn_techno_spittere = emerge:new{Image = imagepath .."_emerge.png", PosX = -27, PosY = -12}

local imagepath = "units/player/lmn_techno_wyrm"
local base = a.MechUnit:new{Image = imagepath ..".png", PosX = -18, PosY = -21, Time = 0.24}

a.lmn_techno_wyrm = base
a.lmn_techno_wyrma = base:new{Image = imagepath .."_a.png", NumFrames = 5}
a.lmn_techno_wyrm_broken = base:new{Image = imagepath .."_broken.png"}
a.lmn_techno_wyrmw_broken = base:new{Image = imagepath .."_w_broken.png", PosY = -10}
a.lmn_techno_wyrm_ns = a.MechIcon:new{Image = imagepath .."_ns.png"}
a.lmn_techno_wyrme = emerge:new{Image = imagepath .."_emerge.png", PosX = -15, PosY = -13}

local imagepath = "units/player/lmn_techno_crusher"
local base = a.MechUnit:new{Image = imagepath ..".png", PosX = -24, PosY = -4}

a.lmn_techno_crusher = base
a.lmn_techno_crushera = base:new{Image = imagepath .."_a.png", NumFrames = 4}
a.lmn_techno_crusher_broken = base:new{Image = imagepath .."_broken.png"}
a.lmn_techno_crusherw = base:new{Image = imagepath .."_w.png", PosX = -22, PosY = 3}
a.lmn_techno_crusherw_broken = base:new{Image = imagepath .."_w_broken.png", PosX = -22, PosY = 3}
a.lmn_techno_crusher_ns = a.MechIcon:new{Image = imagepath .."_ns.png"}
a.lmn_techno_crushere = emerge:new{Image = imagepath .."_emerge.png", PosX = -26, PosY = -2}


--	_______
--	 Pawns
--	‾‾‾‾‾‾‾

lmn_Swarmer = Pawn:new{
	Name = "Techno-Swarmer",
	Class = "TechnoVek",
	Health = 1,
	MoveSpeed = 5,
	Image = "lmn_techno_swarmer",
	ImageOffset = 8,
	SkillList = { "lmn_SwarmerAtk" },
	SoundLocation = "/enemy/spiderling_1/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_INSECT,
	Portrait = "pilots/Pilot_lmn_Swarmer",
	Massive = true,
}

lmn_Roach = Pawn:new{
	Name = "Techno-Roach",
	Class = "TechnoVek",
	Health = 2,
	MoveSpeed = 3,
	Image = "lmn_techno_roach",
	ImageOffset = 8,
	SkillList = { "lmn_RoachAtk" },
	SoundLocation = "/enemy/scorpion_soldier_1/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_INSECT,
	Massive = true,
	Armor = true,
}

lmn_Spitter = Pawn:new{
	Name = "Techno-Spitter",
	Class = "TechnoVek",
	Health = 3,
	MoveSpeed = 3,
	Image = "lmn_techno_spitter",
	ImageOffset = 8,
	SkillList = { "lmn_SpitterAtk" },
	SoundLocation = "/enemy/centipede_1/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_INSECT,
	Massive = true,
}

lmn_Wyrm = Pawn:new{
	Name = "Techno-Wyrm",
	Class = "TechnoVek",
	Health = 2,
	MoveSpeed = 3,
	Image = "lmn_techno_wyrm",
	ImageOffset = 8,
	SkillList = { "lmn_WyrmAtk" },
	SoundLocation = "/enemy/hornet_1/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_INSECT,
	Massive = true,
	Flying = true,
}

lmn_Crusher = Pawn:new{
	Name = "Techno-Crusher",
	Class = "TechnoVek",
	Health = 4,
	MoveSpeed = 3,
	Image = "lmn_techno_crusher",
	ImageOffset = 8,
	SkillList = { "lmn_CrusherAtk" },
	SoundLocation = "/enemy/goo_boss/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_INSECT,
	Massive = true,
}

lmn_CrusherAtkDummy = Pawn:new{
	Name = "",
	-- very high hp produces almost no hp bar.
	-- to high hp lags the game. 200 is sweet spot.
	Health = 200,
	Image = "",
	-- flying lowers the hp bar slightly,
	-- making it almost imperceptible on another unit's tile.
	Flying = true,
	Pushable = false,
	SpaceColor = false,
	IsPortrait = false,
}

local podMarkedTiles = {}

--	.________________.
--	  Swarmer Attack
--	'‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾'

lmn_SwarmerAtk = Skill:new{
	Name = "Swarm",
	Description = "Swarm a target from each adjacent tile within your movement distance.",
	Icon = "weapons/lmn_swarmer.png",
	Class = "TechnoVek",
	PathSize = 1,
	Damage = 1,
	Attacks = 1,
	PowerCost = 0,
	LaunchSound = "",
	Upgrades = 1,
	UpgradeCost = {3},
	UpgradeList = {"+1 Attack"},
	CustomTipImage = "lmn_SwarmerAtk_Tip",
	TipImage = {
		CustomPawn = "lmn_Swarmer",
		Unit = Point(2,2),
		Enemy = Point(2,1),
		Target = Point(2,1),
	}
}

lmn_SwarmerAtk_A = lmn_SwarmerAtk:new{
	CustomTipImage = "lmn_SwarmerAtk_Tip_A",
	UpgradeDescription = "Increases number of attacks by 1.",
	Attacks = 2,
}

lmn_SwarmerAtk_Tip = lmn_SwarmerAtk:new{}
lmn_SwarmerAtk_Tip_A = lmn_SwarmerAtk_A:new{}

function lmn_SwarmerAtk_Tip:GetSkillEffect(p1, p2, parentSkill, isTipImage, ...)
	return lmn_SwarmerAtk.GetSkillEffect(self, p1, p2, parentSkill, true, ...)
end

lmn_SwarmerAtk_Tip_A.GetSkillEffect = lmn_SwarmerAtk_Tip.GetSkillEffect

function lmn_SwarmerAtk:GetSkillEffect(p1, p2, parentSkill, isTipImage)
	local ret = SkillEffect()
	local pathing = Pawn:GetPathProf()
	local pathingMod = pathing % 16
	local goalPathing = pathingMod == PATH_FLYER and PATH_FLYER or PATH_GROUND
	
	-- fetch all vacant tiles around target.
	local agents = {}
	for i = DIR_START, DIR_END do
		local curr = p2 + DIR_VECTORS[i]
		
		if not Board:IsBlocked(curr, goalPathing) then
			agents[#agents+1] = {goal = curr, mine = Board:IsDangerousItem(curr)}
		end
	end
	
	-- pathing function.
	local function isValidTile(p)
		if pathingMod == PATH_FLYER or pathingMod == PATH_ROADRUNNER then
			return not Board:IsBlocked(p, pathing) or Board:IsPawnSpace(p)
		end
		
		return not Board:IsBlocked(p, pathing) or (Board:GetPawnTeam(p) == TEAM_PLAYER)
	end
	
	for i = #agents, 1, -1 do
		local agent = agents[i]
		agent.path = astar.GetPath(p1, agent.goal, isValidTile)
		
		-- remove agents that cannot reach the target in time.
		if #agent.path == 0 or (#agent.path - 1) > Pawn:GetMoveSpeed() then
			table.remove(agents, i)
		end
	end
	
	-- sort agents so agents with the longest paths come first.
	table.sort(agents, function(a,b)
		return #a.path > #b.path
	end)
	
	local pawnType, pawnId = Pawn:GetType(), Pawn:GetId()
	for _, agent in ipairs(agents) do
		local unit_preview = SpaceDamage(agent.goal)
		unit_preview.sPawn = pawnType
		ret:AddDamage(unit_preview)
		ret:AddScript(string.format("Board:RemovePawn(Board:GetPawn(Point(%s)))", agent.goal:GetString()))
		
		ret:AddScript(string.format([[
			local pawnType, pawnId, isTipImage = %q, %s, %s;
			local recolor = pawnId >= 0 and pawnId <= 2 and not isTipImage;
			local oldColor, oldNeutral;
			
			if recolor then
				oldColor = _G[pawnType].ImageOffset;
				_G[pawnType].ImageOffset = GameData.current.colors[pawnId + 1];
			end;
			
			local oldNeutral = _G[pawnType].Neutral;
			_G[pawnType].Neutral = true;
			
			local clone = PAWN_FACTORY:CreatePawn(pawnType);
			
			if recolor then
				_G[pawnType].ImageOffset = oldColor;
			end;
			
			_G[pawnType].Neutral = oldNeutral;
			
			Board:AddPawn(clone, %s);
			clone:Move(%s);
		]], pawnType, pawnId, tostring(isTipImage), p1:GetString(), agent.goal:GetString()))
		ret:AddDelay(0.2)
	end
	
	local d = SpaceDamage(p2, self.Damage)
	d.sImageMark = multishot.GetMark(self.Attacks * (1 + #agents), p2)
	
	local function attack(from)
		local s = SpaceDamage(p2)
		s.sSound = "enemy/spider_boss_1/attack_egg_land"
		ret:AddDamage(s)
		
		ret:AddMelee(from, d)
	end
	
	for k = 1, self.Attacks do
		attack(p1)
		
		for _, agent in ipairs(agents) do
			if not agent.mine then
				attack(agent.goal)
			end
		end
	end
	
	
	for _, agent in ipairs(agents) do
		if a[_G[pawnType].Image .."e"] then
			ret:AddScript(string.format([[
				local loc, path = %s, %q;
				local tips = require(path .."scripts/libs/tutorialTips");
				local pawn = Board:GetPawn(loc);
				if pawn then
					if pawn:IsFrozen() then
						tips:Trigger("Swarmer_Frozen", loc);
						pawn:SetFrozen(false);
					end
				else
					tips:Trigger("Swarmer_Dead", loc);
				end;
			]], agent.goal:GetString(), path))
			
			ret:AddScript(string.format([[
				local pawnType, p1, clone = %q, %s, Board:GetPawn(%s);
				if clone then
					local old = _G[pawnType].Burrows;
					_G[pawnType].Burrows = true;
					clone:Move(Point(-1,-1));
					_G[pawnType].Burrows = old;
					
					local fx = SkillEffect();
					fx:AddScript(string.format('Board:RemovePawn(Board:GetPawn(%%s))', clone:GetId()));
					Board:AddEffect(fx);
				end;
			]], pawnType, p1:GetString(), agent.goal:GetString()))
		else
			ret:AddScript(string.format([[
				local clone = Board:GetPawn(%s);
				
				if clone then
					Board:RemovePawn(clone);
				end;
			]], agent.goal:GetString()))
		end
		
		ret:AddDelay(0.2)
	end
	
	return ret
end


--	.______________.
--	  Roach Attack
--	'‾‾‾‾‾‾‾‾‾‾‾‾‾‾'

lmn_RoachAtk = lmn_RoachAtk1:new{
	Name = "Scything Talons",
	Description = "Lob A.C.I.D. a short distance, and slash in the same direction.",
	Icon = "weapons/lmn_roach.png",
	Class = "TechnoVek",
	Range = 4,
	Damage = 1,
	Push = false,
	PowerCost = 0,
	Upgrades = 2,
	UpgradeCost = {1, 3},
	UpgradeList = {"Push", "+2 Damage"},
	CustomTipImage = "",
	GetTargetScore = Skill.GetTargetScore,
	TipImage = {
		CustomPawn = "lmn_Roach",
		Unit = Point(2,3),
		Enemy = Point(2,2),
		Enemy2 = Point(2,1),
		Target = Point(2,2),
		Second_Origin = Point(2,3),
		Second_Target = Point(2,1)
	}
}

lmn_RoachAtk_A = lmn_RoachAtk:new{
	UpgradeDescription = "Both attacks will now push.",
	Push = true
}

lmn_RoachAtk_B = lmn_RoachAtk:new{
	UpgradeDescription = "Increases damage by 2.",
	Damage = 3,
}

lmn_RoachAtk_AB = lmn_RoachAtk:new{
	Push = true,
	Damage = 3,
}

function lmn_RoachAtk:GetTargetArea(p)
	local ret = PointList()
	
	for dir = DIR_START, DIR_END do
		for k = 1, self.Range do
			local curr = p + DIR_VECTORS[dir] * k
			
			if not Board:IsValid(curr) then
				break
			end
			
			ret:push_back(curr)
		end
	end
	
	return ret
end

function lmn_RoachAtk.GetYVelocity(distance)
	return -3 + 3 * distance / 1
end

function lmn_RoachAtk:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	local distance = p1:Manhattan(p2)
	
	local s = SpaceDamage(p2)
	s.bHide = true
	
	if distance == 1 then
		local d = SpaceDamage(p2)
		d.iAcid = 1
		d.sAnimation = self.Explo
	
		d.sSound = "/impact/dynamic/enemy_projectile"
		ret:AddProjectile(p1, d, self.Shot, NO_DELAY)
		s.sSound = "/enemy/spider_boss_1/attack_egg_land"
		ret:AddProjectile(s, "")
	else
		ret:AddScript("lmn_tempvar = Emitter_Acid")
		ret:AddScript("Emitter_Acid = lmn_Emitter_Roach")
		
		ret:AddSound("enemy/firefly_soldier_1/attack")
		ret:AddSound("impact/generic/web")
		
		local d = SpaceDamage(p2, 0, self.Push and dir or DIR_NONE)
		d.iAcid = 1
		d.sAnimation = self.Explo
		
		d.sSound = "/impact/dynamic/enemy_projectile"
		ret:AddArtillery(p1, d, self.Upshot, NO_DELAY)
		s.sSound = "/props/acid_splash"
		ret:AddArtillery(p1, s, "", NO_DELAY)
		s.sSound = "/enemy/scorpion_soldier_1/attack_web"
		ret:AddArtillery(p1, s, "", NO_DELAY)
		s.sSound = "/enemy/spider_boss_1/attack_egg_land"
		ret:AddArtillery(p1, s, "", NO_DELAY)
		
		ret:AddScript("Emitter_Acid = lmn_tempvar")
		ret:AddScript("lmn_tempvar = nil")
		
		s.sSound = ""
		ret:AddArtillery(s, "")
	end
	
	ret:AddDelay(.5)
	
	local p3 = p1 + DIR_VECTORS[dir]
	
	s.loc = p3
	s.sSound = "/enemy/scorpion_soldier_1/attack"
	ret:AddDamage(s)
	
	local d = SpaceDamage(p3, self.Damage, self.Push and dir or DIR_NONE)
	d.sAnimation = "SwipeClaw1"
	d.bHide = distance == 1
	
	ret:AddScript(string.format("lmn_RoachAtk.WasAcid = Board:IsAcid(%s)", p3:GetString()))
	ret:AddMelee(p1, d, NO_DELAY)
	
	-- at distance 1, both attacks need to be previewed at once.
	-- weaponPreview is ideal for this, without causing changes to the board.
	if distance == 1 then
		local d = SpaceDamage(p3, self.Damage * 2 + 1, self.Push and dir or DIR_NONE)
		d.iAcid = 1
		
		local pawn = Board:GetPawn(p3)
		if pawn and not pawn:IsAcid() and not pawn:IsShield() and not pawn:IsFrozen() then
			if armorDetection.IsArmor(pawn) then
				d.iDamage = self.Damage * 2 + 1
			else
				d.iDamage = self.Damage * 2
			end
		else
			d.iDamage = self.Damage
		end
		
		previewer:AddDamage(d)
	end
	
	return ret
end

local roachAtk = {
	"lmn_RoachAtk",
	"lmn_RoachAtk_A",
	"lmn_RoachAtk_B",
	"lmn_RoachAtk_AB",
}

local function isRoachAtk(skillType)
	return list_contains(roachAtk, skillType)
end

weaponHover:addWeaponHoverHook(function(skill, skillType)
	if isRoachAtk(skillType) then
		local VelY = lmn_RoachAtk.GetYVelocity(3)
		Values.y_velocity = VelY
	end
end)

weaponHover:addWeaponUnhoverHook(function(skill, skillType)
	if isRoachAtk(skillType) then
		Values.y_velocity = worldConstants.GetDefaultHeight()
	end
end)

weaponArmed:addWeaponUnarmedHook(function(skill, skillType)
	if isRoachAtk(skillType) then
		Values.y_velocity = worldConstants.GetDefaultHeight()
	end
end)


--	.________________.
--	  Spitter Attack
--	'‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾'

lmn_SpitterAtk = lmn_SpitterAtk1:new{
	Name = "Needle Spines",
	Description = "Eject a needle spine, damaging and pushing its target.",
	Icon = "weapons/lmn_spitter.png",
	Class = "TechnoVek",
	Damage = 1,
	MinDamage = -1,
	Range = INT_MAX,
	MeleeArt = "SwipeClaw2",
	Upgrades = 2,
	UpgradeCost = {2, 2},
	UpgradeList = {"+1 Damage", "+2 Melee"},
	TipImage = {
		CustomPawn = "lmn_Spitter",
		Unit = Point(2,3),
		Enemy = Point(2,1),
		Target = Point(2,1),
	}
}

function lmn_SpitterAtk:GetTargetArea(p)
	local ret = PointList()
	
	for dir = DIR_START, DIR_END do
		for k = 1, self.Range do
			local curr = p + DIR_VECTORS[dir] * k
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

function lmn_SpitterAtk:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	local target = utils.GetProjectileEnd(p1, p2, self.Range)
	local distance = p1:Manhattan(target)
	local damage_ranged = self.Damage
	local damage_melee = self.MinDamage
	
	if self.MinDamage > 0 then
		damage_ranged = self.MinDamage
		damage_melee = self.Damage
	end
	
	if distance == 1 and damage_melee > 0 then
		-- melee
		utils.EffectAddAttackSound(ret, target, "/enemy/burrower_1/attack")
		
		local d = SpaceDamage(target, damage_melee, dir)
		d.sAnimation = self.MeleeArt
		
		ret:AddMelee(p1, d)
	else
		-- ranged
		ret:AddSound("enemy/firefly_soldier_1/attack")
		ret:AddSound("enemy/spider_soldier_1/attack_egg_land")
		ret:AddSound("enemy/spider_soldier_1/hurt")
		ret:AddSound("impact/generic/metal")
		ret:AddAnimation(p1, self.RangedLaunchArt .. dir)
		
		worldConstants.SetSpeed(ret, 1)
		
		local d = SpaceDamage(target)
		d.sSound = self.RangedImpactSound1
		ret:AddProjectile(p1, d, "", NO_DELAY)
		
		d.iDamage = damage_ranged
		d.iPush = dir
		d.sAnimation = self.RangedImpactArt
		d.sSound = self.RangedImpactSound2
		ret:AddProjectile(p1, d, self.ProjectileArt, NO_DELAY)
		
		worldConstants.ResetSpeed(ret)
	end
	
	return ret
end

lmn_SpitterAtk_A = lmn_SpitterAtk:new{
	UpgradeDescription = "Increases damage by 1.",
	Damage = 2
}

lmn_SpitterAtk_B = lmn_SpitterAtk:new{
	UpgradeDescription = "Increases melee damage by 2.",
	Damage = 3,
	MinDamage = 1,
	TipImage = {
		CustomPawn = "lmn_Spitter",
		Unit = Point(3,3),
		Enemy = Point(3,1),
		Enemy2 = Point(2,3),
		Target = Point(2,3),
		Second_Origin = Point(3,3),
		Second_Target = Point(3,1),
	}
}

lmn_SpitterAtk_AB = lmn_SpitterAtk:new{
	Damage = 4,
	MinDamage = 2,
	lmn_SpitterAtk_B.TipImage
}


--	._____________.
--	  Wyrm Attack
--	'‾‾‾‾‾‾‾‾‾‾‾‾‾'

lmn_WyrmAtk = lmn_WyrmAtk1:new{
	Name = "Glaive Wurm",
	Description = "Fire a shot at point blank. The shot bounces to nearby objects, halving the damage each jump. Pushes the final tile.",
	Icon = "weapons/lmn_wyrm.png",
	Class = "TechnoVek",
	Damage = 2,
	Range = 2,
	PowerCost = 0,
	Upgrades = 2,
	UpgradeCost = {1, 3},
	UpgradeList = {"Avoid Buildings", "+2 Damage"},
	CustomTipImage = "lmn_WyrmAtk_Tip",
	Path = {},
	TipImage = {
		CustomPawn = "lmn_Wyrm",
		Unit = Point(2,3),
		Enemy = Point(2,1),
		Building = Point(1,1),
		Target = Point(2,2),
	}
}

function lmn_WyrmAtk.IsValidTarget(p)
	return
		Board:IsBlocked(p, PATH_PROJECTILE)
end

-- this function needs to be overwritten on upgrades with new range.
function lmn_WyrmAtk.IsValidTile(p, moved)
	if moved > lmn_WyrmAtk.Range then
		return false
	end
	
	return lmn_WyrmAtk.IsValidTarget(p) or moved <= 1
end

function lmn_WyrmAtk:GetTargetArea(p)
	local ret = PointList()
	
	self.Traversable = astar.GetTraversable(p, self.IsValidTile)
	
	for _, node in pairs(self.Traversable) do
		ret:push_back(node.loc)
	end
	
	return ret
end

-- prepare to look into the void...
function lmn_WyrmAtk:GetSkillEffect(p1, p2, parentSkill, isTipImage)
	local ret = SkillEffect()
	local path
	
	if isTipImage then
		path = {}
		for i, loc in ipairs(self.Path) do
			path[i] = {loc = loc}
		end
	else
		-- reset path on origin.
		if p1 == p2 then
			self.Path = {}
			self.Prev = nil
			return ret
		end
		
		-- ensure GetTargetArea has been called.
		if not self.Traversable then
			self:GetTargetArea(p1)
		end
		
		-- returns if cached path is valid.
		local function pathIsValid()
			if #self.Path <= 1 or self.Path[1].loc ~= p1 then
				return false
			end
			
			return not utils.list_predicates(
				self.Path,
				function(n)
					return not self.Traversable[p2idx(n.loc)]
				end
			)
		end
		
		local function pathContains(p)
			return utils.list_predicates(
				self.Path,
				function(n)
					return n.loc == p
				end
			)
		end
		
		-- save and index old path.
		local old_p2 = self.Prev
		local old_path = self.Path
		local old_path_indexed = {}
		for i, n in ipairs(old_path) do
			old_path_indexed[p2idx(n.loc)] = i
		end
		
		local resetPath = true
		
		if pathIsValid() then
			if pathContains(p2) then
				resetPath = false
			elseif self.IsValidTarget(p2, 0) then
				assert(old_p2)
				assert(old_path)
				
				-- if p2 is adjacent path.
				-- adjust path to contain p2.
				local index
				
				if utils.isAdjacent(p2, old_p2) then
					index = old_path_indexed[p2idx(old_p2)]
				else
					for i = 2, #self.Path do
						if utils.isAdjacent(p2, self.Path[i].loc) then
							index = i
							break
						end
					end
				end
				
				if index then
					table.insert(self.Path, index + 1, self.Traversable[p2idx(p2)])
					
					index = index + 2
					while #self.Path >= index do
						if utils.isAdjacent(self.Path[index].loc, p2) then
							break
						else
							table.remove(self.Path, index)
						end
					end
					
					if #self.Path - 1 <= self.Range then
						-- our path is valid.
						resetPath = false
					end
				end
			end
		end
		
		if resetPath then
			-- construct the first end of a new fresh path.
			self.Path = {}
			local node = self.Traversable[p2idx(p2)]
			
			repeat
				table.insert(self.Path, node)
				node = node.cameFrom
			until (not node)
			
			self.Path = reverse_table(self.Path)
		end
		
		-- make this madness somewhat readable.
		path = self.Path
		
		-- this must be true.
		assert(#path >= 2)
		
		-- while we are not at max path length,
		-- lengthen path with a direction bias.
		for k = #path,  self.Range do
			local picks = {}
			local tail = self.Traversable[p2idx(path[k].loc)]
			local dir_bias = GetDirection(path[k].loc - path[k - 1].loc)
			
			for _, node in ipairs(tail.links) do
				if not utils.list_predicates(path, function(a) return a.loc == node.loc end) then
					-- make sure to not have an unblocked tile at the tail.
					if self.IsValidTarget(node.loc, k - 1) then
						table.insert(picks, node)
					end
				end
			end
			
			-- dead end reached. exit.
			if #picks == 0 then
				break
			end
			
			utils.shuffle(picks)
			
			table.sort(picks, function(a,b)
				local a_isPri = old_path_indexed[p2idx(a.loc)]
				local b_isPri = old_path_indexed[p2idx(b.loc)]
				
				-- maybe we only need one of these checks?
				if a_isPri and not b_isPri then
					return true
				end
				
				-- do both ways just to be sure.
				if b_isPri and not a_isPri then
					return false
				end
				
				-- directional bias when not enough information is available
				-- to streamline targetting and make it feel predictable.
				return dir_bias == GetDirection(a.loc - path[k].loc)
			end)
			
			table.insert(path, picks[1])
		end
		
		self.Path = path
		self.Prev = p2
	end
	
	-- damage resolution
	local dmg = self.Damage
	local pawnId = Pawn:GetId()
	
	for i = 2, #path do
		local loc = path[i].loc
		local from = path[i-1].loc
		local dir = GetDirection(loc - from)
		local d = SpaceDamage(loc, dmg)
		
		if i == #path then
			d.iPush = dir
		end
		
		if i == 2 then
			-- attack sounds
			ret:AddSound("enemy/jelly/hurt")
			ret:AddSound("enemy/spider_soldier_1/hurt")
			ret:AddSound("impact/generic/web")
			
			worldConstants.SetSpeed(ret, .3)
			ret:AddProjectile(p1, d, "effects/shot_firefly2", NO_DELAY)
			worldConstants.ResetSpeed(ret)
			
			-- delay should be about 0.06 divided by projectile speed
			-- the correct delay will cause explosion to align with projectile collision,
			-- and not set pawn on fire if it is pushed away from a forest tile being set on fire.
			--ret:AddDelay(0.28) -- speed .2
			--ret:AddDelay(0.20) -- speed .3
			--ret:AddDelay(0.16) -- speed .4
			--ret:AddDelay(0.12) -- speed .5
			--ret:AddDelay(0.11) -- speed .6
			--ret:AddDelay(0.06) -- speed 1.0
			
			ret:AddDelay(0.20)
			ret:AddScript(string.format("Board:AddAnimation(%s, 'ExploFirefly2', NO_DELAY)", loc:GetString()))
			
			-- impact sounds
			ret:AddSound("enemy/centipede_1/attack")
			ret:AddSound("props/freezing_mine")
			ret:AddSound("impact/generic/web")
			
			-- delay must be > 0 and should be
			-- >= final delay in else block.
			ret:AddDelay(0.02)
		else
			-- fire bouncing projectile.
			ret:AddScript(string.format("lmn_WyrmAtk1:Bounce(%s, %s, %s)", from:GetString(), loc:GetString(), pawnId))
			
			d.sImageMark = "combat/lmn_wyrm_arrow_".. dir ..".png"
			
			-- see above about projectile delay.
			ret:AddDelay(0.12)
			ret:AddDamage(d)
			ret:AddScript(string.format("Board:AddAnimation(%s, 'ExploFirefly2', NO_DELAY)", loc:GetString()))
			
			-- impact sounds
			ret:AddSound("enemy/centipede_1/attack")
			ret:AddSound("props/freezing_mine")
			ret:AddSound("impact/generic/web")
			
			-- delay must be > 0
			ret:AddDelay(0.02)
		end
		
		dmg = math.floor(dmg / 2)
	end
	
	return ret
end

lmn_WyrmAtk_A = lmn_WyrmAtk:new{
	CustomTipImage = "lmn_WyrmAtk_Tip_A",
	UpgradeDescription = "The wurm will no longer seek out buildings.",
}

lmn_WyrmAtk_B = lmn_WyrmAtk:new{
	CustomTipImage = "lmn_WyrmAtk_Tip_B",
	UpgradeDescription = "Increases damage by 2 (and range by 1).",
	Damage = 4,
	Range = 3
}

lmn_WyrmAtk_AB = lmn_WyrmAtk:new{
	CustomTipImage = "lmn_WyrmAtk_Tip_AB",
	Damage = 4,
	Range = 3
}

function lmn_WyrmAtk_A.IsValidTarget(p)
	return
		Board:IsBlocked(p, PATH_PROJECTILE) and
		not Board:IsBuilding(p)
end

function lmn_WyrmAtk_A.IsValidTile(p, moved)
	if moved > lmn_WyrmAtk_A.Range then
		return false
	end
	
	return lmn_WyrmAtk_A.IsValidTarget(p) or moved <= 1
end

function lmn_WyrmAtk_B.IsValidTile(p, moved)
	if moved > lmn_WyrmAtk_B.Range then
		return false
	end
	
	return lmn_WyrmAtk_B.IsValidTarget(p) or moved <= 1
end

function lmn_WyrmAtk_AB.IsValidTile(p, moved)
	if moved > lmn_WyrmAtk_AB.Range then
		return false
	end
	
	return lmn_WyrmAtk_A.IsValidTarget(p) or moved <= 1
end

lmn_WyrmAtk_Tip = lmn_WyrmAtk:new{
	Path = {
		Point(2,3),
		Point(2,2),
		Point(2,1)
	}
}

lmn_WyrmAtk_Tip_A = lmn_WyrmAtk_A:new{
	Path = {
		Point(2,2),
		Point(2,1)
	},
	TipImage = {
		CustomPawn = "lmn_Wyrm",
		Unit = Point(2,2),
		Enemy = Point(2,1),
		Building = Point(1,1),
		Target = Point(2,1),
	}
}

lmn_WyrmAtk_Tip_B = lmn_WyrmAtk_B:new{
	Path = {
		Point(2,3),
		Point(2,2),
		Point(2,1),
		Point(1,1)
	},
	TipImage = {
		CustomPawn = "lmn_Wyrm",
		Unit = Point(2,3),
		Enemy = Point(2,1),
		Building = Point(1,1),
		Target = Point(2,2),
	}
}

lmn_WyrmAtk_Tip_AB = lmn_WyrmAtk_AB:new{
	Path = lmn_WyrmAtk_Tip_B.Path,
	TipImage = lmn_WyrmAtk_Tip_A.TipImage
}

function lmn_WyrmAtk_Tip:GetSkillEffect(p1, p2, parentSkill, isTipImage, ...)
	return lmn_WyrmAtk.GetSkillEffect(self, p1, p2, parentSkill, true, ...)
end

lmn_WyrmAtk_Tip_A.GetSkillEffect = lmn_WyrmAtk_Tip.GetSkillEffect
lmn_WyrmAtk_Tip_B.GetSkillEffect = lmn_WyrmAtk_Tip.GetSkillEffect
lmn_WyrmAtk_Tip_AB.GetSkillEffect = lmn_WyrmAtk_Tip.GetSkillEffect


--	.________________.
--	  Crusher Attack
--	'‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾'

lmn_CrusherAtk = Skill:new{
	Name = "Kaizer Blades",
	Description = "Crush 3 tiles, mashing units towards the center.",
	Icon = "weapons/lmn_crusher.png",
	Class = "TechnoVek",
	PathSize = 1,
	Damage = 1,
	PowerCost = 0,
	Upgrades = 2,
	UpgradeCost = {2, 2},
	UpgradeList = {"+1 Damage", "Center Damage"},
	LaunchSound = "",
	SoundBase = "/enemy/burrower_1/",
	TipImage = {
		CustomPawn = "lmn_Crusher",
		Unit = Point(2,2),
		Enemy = Point(2,1),
		Enemy2 = Point(1,1),
		Target = Point(2,1),
	}
}

function lmn_CrusherAtk:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	local dir_left = (dir + 3) % 4
	local dir_right = (dir + 1) % 4
	local left = p2 + DIR_VECTORS[dir_left]
	local right = p2 + DIR_VECTORS[dir_right]
	
	ret:AddSound("/weapons/sword")
	
	local function isPushablePawnSpace(p)
		local pawn = Board:GetPawn(p)
		
		return pawn and not pawn:IsGuarding()
	end
	
	ret:AddDelay(0.05)
	
	local damage_center = self.Damage
	local damage_corner = self.Damage
	
	if self.MinDamage > 0 then
		damage_center = self.Damage
		damage_corner = self.MinDamage
	end
	
	local d = SpaceDamage(p2, damage_center)
	local d_left = SpaceDamage(left, damage_corner, dir_right)
	local d_right = SpaceDamage(right, damage_corner, dir_left)
	
	local shouldCollide = false
	local is_pawn_left = isPushablePawnSpace(left)
	local is_blocked_center = Board:IsBlocked(p2, PATH_PROJECTILE)
	local is_pawn_right = isPushablePawnSpace(right)
	
	if is_pawn_left and is_pawn_right then
		shouldCollide = true
		
		if not is_blocked_center then
			d.sImageMark = "combat/lmn_crusher_arrow_hit.png"
			
			-- iPush = 220 previews a single bump damage even if it has no pawn to bump into.
			--
			-- many values of iPush does this, seemingly randomly distributed.
			-- 7 is the smallest, but it seemed unstable, crashing the game
			-- occationally when targeting a unit, without any predictable
			-- pattern that I could find.
			--
			-- I did not test every number extensively, but 220 seems a lot more stable,
			-- and did not crash the game after targeting every tile on a 100 different
			-- test board configurations.
			--
			-- The numbers I did test was 7, 20 and 220.
			-- 7 crashes regularly in intensive testing. 20 less so. 220 I have yet to get a crash with.
			--
			-- 220 seems to crash on tiles pods has previously landed on.
			-- so we track those tiles and use another number (230) for them.
			--
			-- it is possible that 230 is stable for all tiles states,
			-- but I am not going to thoroughly test it, so this band-aid will hopefully be enough.
			
			local mission = GetCurrentMission()
			if mission then
				mission.podMarkedTiles = mission.podMarkedTiles or {}
				for _, loc in ipairs{left, right} do
					local t = SpaceDamage(loc)
					if list_contains(mission.podMarkedTiles, loc) then
						t.iPush = 230
					else
						t.iPush = 220
					end
					previewer:AddDamage(t)
				end
			end
		end
		
	elseif is_blocked_center and (is_pawn_left or is_pawn_right) then
		shouldCollide = true
	end
	
	ret:AddAnimation(p2, "lmn_explo_crusher_kaizerA_".. dir)
	ret:AddAnimation(p2, "lmn_explo_crusher_kaizerB_".. dir)
	
	ret:AddDamage(d_left)
	ret:AddDamage(d_right)
	
	ret:AddDelay(0.05)
	ret:AddDamage(d)
	
	if shouldCollide then
		-- spawn blocker in center.
		ret:AddScript(string.format([[
			local dummy = PAWN_FACTORY:CreatePawn("lmn_CrusherAtkDummy");
			local dummyId = dummy:GetId();
			local p2, setInvisible = %s, %s;
			
			if setInvisible then
				dummy:SetInvisible(true);
			end;
			
			Board:AddPawn(dummy, p2);
			
			local units = {};
			while true do
				local pawn = Board:GetPawn(p2);
				
				if not pawn or pawn:GetId() == dummyId then
					break;
				end;
				
				units[#units+1] = {pawn = pawn, loc = pawn:GetSpace()};
				pawn:SetSpace(Point(-1,-1));
			end;
			
			for _, unit in ipairs(units) do
				unit.pawn:SetSpace(unit.loc);
			end;
		]], p2:GetString(), tostring(not Board:IsPawnSpace(p2))))
	end
	
	ret:AddDelay(0.5)
	
	-- clean up.
	ret:AddScript([[
		for _, pawnId in ipairs(extract_table(Board:GetPawns(TEAM_ANY))) do
			local pawn = Board:GetPawn(pawnId);
			if pawn:GetType() == "lmn_CrusherAtkDummy" then
				pawn:SetSpace(Point(-1,-1));
				Board:RemovePawn(pawn);
			end;
		end;
	]])
	
	return ret
end

lmn_CrusherAtk_A = lmn_CrusherAtk:new{
	UpgradeDescription = "Increases damage by 1.",
	Damage = 2
}

lmn_CrusherAtk_B = lmn_CrusherAtk:new{
	UpgradeDescription = "Increases damage to center tile by 2.",
	Damage = 3,
	MinDamage = 1
}

lmn_CrusherAtk_AB = lmn_CrusherAtk:new{
	Damage = 4,
	MinDamage = 2
}


--	____________
--	 Additional
--	‾‾‾‾‾‾‾‾‾‾‾‾

function this:load()
	modApi:addMissionUpdateHook(function()
		local _, armedType = weaponArmed:GetCurrent()
		local tileFocused = Board:GetHighlighted()
		local weaponHovered = weaponHover:GetCurrent()
		local selected = selected:Get()
		
		-- change artillery height when hovering weapon.
		if isRoachAtk(armedType) then
			if not weaponHovered and tileFocused and selected then
				local distance = selected:GetSpace():Manhattan(tileFocused)
				Values.y_velocity = lmn_RoachAtk.GetYVelocity(distance)
			end
		end
	end)
	
	modUtils:addPodLandedHook(function(p)
		local mission = GetCurrentMission()
		if not mission then return end
		
		mission.podMarkedTiles = mission.podMarkedTiles or {}
		table.insert(mission.podMarkedTiles, p)
	end)

	local function IsSwarmer(pawn)
		return
			list_contains(_G[pawn:GetType()].SkillList, "lmn_SwarmerAtk") or
			list_contains(_G[pawn:GetType()].SkillList, "lmn_SwarmerAtk_A")
	end
	
	modUtils:addPawnIsGrappledHook(function(m, pawn, isGrappled)
		if isGrappled and IsSwarmer(pawn) then
			tips:Trigger("Swarmer_Webbed", pawn:GetSpace())
		end
	end)
end

weaponHover:registerWeapon("lmn_RoachAtk")
weaponHover:registerWeapon("lmn_RoachAtk_A")
weaponHover:registerWeapon("lmn_RoachAtk_B")
weaponHover:registerWeapon("lmn_RoachAtk_AB")

return this
