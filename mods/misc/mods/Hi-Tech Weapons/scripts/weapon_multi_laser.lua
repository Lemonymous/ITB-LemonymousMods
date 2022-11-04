
local mod = mod_loader.mods[modApi.currentMod]
local worldConstants = mod.libs.worldConstants
local effectPreview = mod.libs.effectPreview
local virtualBoard = require(mod.scriptPath.."libs/virtualBoard")

totalAttacksRemaining = {}

lmn_Multi_Laser = Skill:new{
	Self = "lmn_Multi_Laser",
	Name = "Multi Laser",
	Description = "Fires a burst of 3 shots.",
	Class = "Brute",
	Icon = "weapons/lmn_multi_laser.png",
	PowerCost = 1,
	Damage = 1,
	Attacks = 3,
	Upgrades = 2,
	UpgradeCost = { 1, 2 },
	UpgradeList = { "+1 Attack", "+2 Attacks" },
	CustomTipImage = "lmn_Multi_Laser_Tip",
	TipImage = {
		Unit = Point(2,4),
		Enemy = Point(2,2),
		Enemy2 = Point(2,1),
		Enemy3 = Point(2,0),
		Target = Point(2,3),
		CustomEnemy = "Scarab1",
	},
	CustomRarity = 4,
}

-- custom GetProjectileEnd, for multishot purposes.
local function GetProjectileEnd(p1, p2)
	assert(type(p1) == 'userdata')
	assert(type(p1.x) == 'number')
	assert(type(p1.y) == 'number')
	assert(type(p2) == 'userdata')
	assert(type(p2.x) == 'number')
	assert(type(p2.y) == 'number')
	
	local dir = GetDirection(p2 - p1)
	local target = p1
	
	for k = 1, INT_MAX do
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

function lmn_Multi_Laser:GetTargetArea(p)
	local ret = PointList()
	
	for i = DIR_START, DIR_END do
		for k = 1, INT_MAX do
			local curr = p + DIR_VECTORS[i] * k
			
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

-- recursive function being run through scripts,
-- to ensure proper multishot functionality.
function lmn_Multi_Laser:FireWeapon(p1, p2, isTipImage)
	local shooter = Board:GetPawn(p1)
	if not shooter then
		return
	end
	
	local effect = SkillEffect()
	effect.iOwner = shooter:GetId()
	effect.piOrigin = p1
	
	-- if board is busy, wait until it is resolved.
	if Board:GetBusyState() ~= 0 then
		effect:AddScript([[
			local p1 = ]].. p1:GetString() ..[[;
			local p2 = ]].. p2:GetString() ..[[;
			_G[']].. self.Self ..[[']:FireWeapon(p1, p2, ]].. tostring(isTipImage) ..[[);
		]])
		Board:AddEffect(effect)
		return
	end
	
	local id = shooter:GetId()
	local dir = GetDirection(p2 - p1)
	local target = GetProjectileEnd(p1, p2)
	
	local pawn = Board:GetPawn(target)
	local attacksLeft = totalAttacksRemaining[id]
	local attacks = 1
	
	----------------------
	-- attack calculation
	----------------------
	if pawn then
		local health = pawn:GetHealth()
		-- unload shots into dead pawns.
		if health <= 0 then
			attacks = attacksLeft
		else
			local damage = self.Damage
			
			if pawn:IsAcid() then
				health = math.ceil(health / 2)
			elseif pawn:IsArmor() then
				damage = damage - 1
			end
			
			if pawn:IsShield() then
				health = health + 1
			end
			
			if pawn:IsFrozen() then
				health = health + 1
			end
			
			if Board:GetTerrain(target) == TERRAIN_ICE then
				local tileHealth = Board:GetHealth(target)
				attacks = math.max(1, math.min(tileHealth, attacks))
			else
				if damage > 0 then
					attacks = health / damage
				else
					attacks = attacksLeft
				end
			end
		end
		
	elseif not Board:IsBlocked(target, PATH_PROJECTILE) then
		-- unload shots on empty tiles.
		attacks = attacksLeft
		
	elseif Board:IsUniqueBuilding(target) then
		attacks = attacksLeft
		
	else
		local terrain = Board:GetTerrain(target)
		local health = Board:GetHealth(target)
		
		if Board:IsFrozen(target) then
			if terrain == TERRAIN_MOUNTAIN then
				attacks = health + 1
			elseif terrain == TERRAIN_BUILDING then
				attacks = 2
			end
		elseif terrain == TERRAIN_MOUNTAIN then
			attacks = health
		end
	end
	
	attacks = math.min(attacksLeft, attacks)
	totalAttacksRemaining[id] = totalAttacksRemaining[id] - attacks
	
	---------------------
	-- damage resolution
	---------------------
	for i = 1, attacks do
		local offset = math.random(1, 3)
		local beam = math.random(1, 3)
		
		effect:AddSound("/weapons/push_beam")
		
		if beam == 1 then
			effect:AddSound("/enemy/jelly/hurt")
		elseif beam == 2 then
			effect:AddSound("/weapons/refrigerate")
		end
		
		local weapon = SpaceDamage(target, self.Damage)
		weapon.sSound = "/props/shield_destroyed"
		weapon.sScript = "Board:AddAnimation(".. target:GetString() ..", 'lmn_ExploLaser".. offset .."_".. dir .."', NO_DELAY)"
		
		worldConstants:setSpeed(effect, 0.6)
		effect:AddProjectile(p1, weapon, "effects/lmn_multi_las_".. offset, NO_DELAY)
		worldConstants:resetSpeed(effect)
		
		-- minimum delay between shots.
		-- can take longer due to board being resolved.
		effect:AddDelay(0.09)
	end
	
	-------------------
	-- continue attack
	-------------------
	if totalAttacksRemaining[id] > 0 then
		effect:AddScript([[
			local p1 = ]].. p1:GetString() ..[[;
			local p2 = ]].. p2:GetString() ..[[;
			_G[']].. self.Self ..[[']:FireWeapon(p1, p2, ]].. tostring(isTipImage) ..[[);
		]])
	else
		------------------
		-- end resolution
		------------------
		
		if isTipImage then
			effect:AddDelay(1.3)
		end
		
		totalAttacksRemaining[id] = nil
	end
	
	Board:AddEffect(effect)
end

function lmn_Multi_Laser:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local shooter = Board:GetPawn(p1)
	local isTipImage = Board:IsTipImage()
	if not shooter then
		return ret
	end
	
	local id = shooter:GetId()
	local distance = p1:Manhattan(p2)
	local dir = GetDirection(p2 - p1)
	totalAttacksRemaining[id] = self.Attacks
	
	----------------
	-- damage marks
	----------------
	if isTipImage then
		-- mark tipimage.
		worldConstants:setSpeed(ret, 999)
		ret:AddProjectile(p1, SpaceDamage(self.TipProjectileEnd), "", NO_DELAY)
		worldConstants:resetSpeed(ret)
		
		for i, v in ipairs(self.TipMarks) do
			local tile = v[1]
			local damage = v[2]
			local mark = SpaceDamage(tile, damage)
			
			if tile ~= self.TipProjectileEnd then
				mark.sImageMark = "combat/lmn_multi_laser_preview_".. damage ..".png"
			end
			
			effectPreview:addDamage(ret, mark)
		end
	else
		local vBoard = virtualBoard.new()
		local target = p1
		for i = 1, self.Attacks do
			
			-- GetProjectileEnd
			for k = 1, INT_MAX do
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
			vBoard:DamageSpace(SpaceDamage(target, self.Damage))
		end
		
		-- preview projectile path.
		worldConstants:setSpeed(ret, 999)
		ret:AddProjectile(p1, SpaceDamage(target), "", NO_DELAY)
		worldConstants:resetSpeed(ret)
		
		-- mark tiles with vBoard state.
		vBoard:MarkDamage(ret, id, "lmn_Multi_Laser")
	end
	
	---------------------
	-- damage resolution
	---------------------
	ret:AddScript([[
		local p1 = ]].. p1:GetString() ..[[;
		local p2 = ]].. p2:GetString() ..[[;
		_G[']].. self.Self ..[[']:FireWeapon(p1, p2, ]].. tostring(isTipImage) ..[[);
	]])
	
	return ret
end

lmn_Multi_Laser_A = lmn_Multi_Laser:new{
	Self = "lmn_Multi_Laser_A",
	UpgradeDescription = "Increases shots fired by 1.",
	Attacks = 4,
	CustomTipImage = "lmn_Multi_Laser_Tip_A",
}

lmn_Multi_Laser_B = lmn_Multi_Laser:new{
	Self = "lmn_Multi_Laser_B",
	UpgradeDescription = "Increases shots fired by 2.",
	Attacks = 5,
	CustomTipImage = "lmn_Multi_Laser_Tip_B",
}

lmn_Multi_Laser_AB = lmn_Multi_Laser:new{
	Self = "lmn_Multi_Laser_AB",
	Attacks = 6,
	CustomTipImage = "lmn_Multi_Laser_Tip_AB",
}

lmn_Multi_Laser_Tip = lmn_Multi_Laser:new{
	Self = "lmn_Multi_Laser_Tip",
	TipProjectileEnd = Point(2,1),
	TipMarks = {
		{Point(2,2), 2},
		{Point(2,1), 1},
	}
}

function lmn_Multi_Laser_Tip:GetSkillEffect(p1, p2)
	return lmn_Multi_Laser.GetSkillEffect(self, p1, p2)
end

lmn_Multi_Laser_Tip_A = lmn_Multi_Laser_A:new{
	Self = "lmn_Multi_Laser_Tip_A",
	TipProjectileEnd = Point(2,1),
	TipMarks = {
		{Point(2,2), 2},
		{Point(2,1), 2},
	}
}

lmn_Multi_Laser_Tip_B = lmn_Multi_Laser_B:new{
	Self = "lmn_Multi_Laser_Tip_B",
	TipProjectileEnd = Point(2,0),
	TipMarks = {
		{Point(2,2), 2},
		{Point(2,1), 2},
		{Point(2,0), 1},
	}
}

lmn_Multi_Laser_Tip_AB = lmn_Multi_Laser_AB:new{
	Self = "lmn_Multi_Laser_Tip_AB",
	TipProjectileEnd = Point(2,0),
	TipMarks = {
		{Point(2,2), 2},
		{Point(2,1), 2},
		{Point(2,0), 2},
	}
}

lmn_Multi_Laser_Tip_A.GetSkillEffect = lmn_Multi_Laser_Tip.GetSkillEffect
lmn_Multi_Laser_Tip_B.GetSkillEffect = lmn_Multi_Laser_Tip.GetSkillEffect
lmn_Multi_Laser_Tip_AB.GetSkillEffect = lmn_Multi_Laser_Tip.GetSkillEffect

modApi:addWeaponDrop("lmn_Multi_Laser")

modApi:appendAsset("img/weapons/lmn_multi_laser.png", mod.resourcePath .."img/weapons/multi_laser.png")
modApi:appendAsset("img/effects/lmn_multi_las_1_R.png", mod.resourcePath .."img/effects/laser_01_R.png")
modApi:appendAsset("img/effects/lmn_multi_las_1_U.png", mod.resourcePath .."img/effects/laser_01_U.png")
modApi:appendAsset("img/effects/lmn_multi_las_2_R.png", mod.resourcePath .."img/effects/laser_02_R.png")
modApi:appendAsset("img/effects/lmn_multi_las_2_U.png", mod.resourcePath .."img/effects/laser_02_U.png")
modApi:appendAsset("img/effects/lmn_multi_las_3_R.png", mod.resourcePath .."img/effects/laser_03_R.png")
modApi:appendAsset("img/effects/lmn_multi_las_3_U.png", mod.resourcePath .."img/effects/laser_03_U.png")

modApi:appendAsset("img/effects/lmn_explo_laser1.png", mod.resourcePath .."img/effects/explo_laser1.png")

for i = 1, 6 do
	modApi:appendAsset("img/combat/lmn_multi_laser_preview_".. i ..".png", mod.resourcePath .."img/combat/preview_arrow_".. i ..".png")
	Location["combat/lmn_multi_laser_preview_".. i ..".png"] = Point(-16, 0)
end

setfenv(1, ANIMS)
--laser 1
lmn_ExploLaser1_0 = Animation:new{
	Image = "effects/lmn_explo_laser1.png",
	NumFrames = 8,
	Time = 0.1,
	
	PosX = -10,
	PosY = 5
}
lmn_ExploLaser1_1 = lmn_ExploLaser1_0:new{}
lmn_ExploLaser1_2 = lmn_ExploLaser1_0:new{}
lmn_ExploLaser1_3 = lmn_ExploLaser1_0:new{}

-- laser 2
lmn_ExploLaser2_0 = lmn_ExploLaser1_0:new{
	PosX = lmn_ExploLaser1_0.PosX + 5,
	PosY = lmn_ExploLaser1_0.PosY + 4
}
lmn_ExploLaser2_1 = lmn_ExploLaser1_0:new{
	PosX = lmn_ExploLaser1_0.PosX - 5,
	PosY = lmn_ExploLaser1_0.PosY + 4
}
lmn_ExploLaser2_2 = lmn_ExploLaser2_0:new{}
lmn_ExploLaser2_3 = lmn_ExploLaser2_1:new{}

-- laser 3
lmn_ExploLaser3_0 = lmn_ExploLaser1_0:new{
	PosX = lmn_ExploLaser1_0.PosX - 5,
	PosY = lmn_ExploLaser1_0.PosY - 4
}
lmn_ExploLaser3_1 = lmn_ExploLaser1_0:new{
	PosX = lmn_ExploLaser1_0.PosX + 5,
	PosY = lmn_ExploLaser1_0.PosY - 4
}
lmn_ExploLaser3_2 = lmn_ExploLaser3_0:new{}
lmn_ExploLaser3_3 = lmn_ExploLaser3_1:new{}
