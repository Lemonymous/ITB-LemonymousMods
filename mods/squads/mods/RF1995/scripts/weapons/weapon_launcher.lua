
local mod = mod_loader.mods[modApi.currentMod]
local resourcePath = mod.resourcePath
local scriptPath = mod.scriptPath

local modApiExt = LApi.library:fetch("ITB-ModUtils/modApiExt/modApiExt")
local shop = require(scriptPath .."libs/shop")
local worldConstants = LApi.library:fetch("worldConstants")
local virtualBoard = require(scriptPath .."libs/virtualBoard")
local effectPreview = LApi.library:fetch("effectPreview")
local effectBurst = LApi.library:fetch("effectBurst")

local hoveredTile

local function GetYVelocity(distance)
	return 6 + 16 * (distance / 8)
end

modApi:appendAsset("img/weapons/lmn_minelayer_launcher.png", resourcePath .."img/weapons/launcher.png")
modApi:appendAsset("img/effects/lmn_minelayer_shot_missile_U.png", resourcePath .."img/effects/shot_missile_U.png")
modApi:appendAsset("img/effects/lmn_minelayer_shot_missile_R.png", resourcePath .."img/effects/shot_missile_R.png")
modApi:appendAsset("img/effects/lmn_minelayer_shotup_missile.png", resourcePath .."img/effects/shotup_missile.png")

for i = 1, 4 do
	modApi:appendAsset("img/combat/lmn_minelayer_preview_arrow_".. i ..".png", resourcePath .."img/combat/preview_arrow_".. i ..".png")
	Location["combat/lmn_minelayer_preview_arrow_".. i ..".png"] = Point(-16, 0)
end

local angle_variance = 80
local angle_3 = 218 + angle_variance / 2

lmn_Emitter_Minelayer_Launcher_Small = Emitter_Missile:new{
	image = "effects/smoke/art_smoke.png",
	max_alpha = 0.4,
	x = -8,
	y = 15,
	angle = angle_3,
	angle_variance = angle_variance,
	variance = 0,
	variance_x = 10,
	variance_y = 7,
	burst_count = 1,
	lifespan = 1.8,
	speed = 0.4,
	layer = LAYER_BACK
}
lmn_Emitter_Minelayer_Launcher_Small_Front = lmn_Emitter_Minelayer_Launcher_Small:new{layer = LAYER_FRONT, max_alpha = 0.2}
lmn_Emitter_Minelayer_Launcher_Big = lmn_Emitter_Minelayer_Launcher_Small:new{burst_count = 5}

lmn_Emitter_Minelayer_Launcher_Trail = Emitter_Missile:new{
	image = "effects/smoke/art_smoke.png",
	max_alpha = 0.4,
	y = 10,
	variance = 0,
	variance_x = 5,
	variance_y = 8,
	burst_count = 3,
	layer = LAYER_FRONT
}

lmn_Minelayer_Launcher = Skill:new{
	Self = "lmn_Minelayer_Launcher",
	Name = "MR Launcher",
	Class = "Ranged",
	Icon = "weapons/lmn_minelayer_launcher.png",
	Description = "Launches 2 rockets in a straight line, or over obstacles.",
	UpShot = "effects/lmn_minelayer_shotup_missile.png",
	ProjectileArt = "effects/lmn_minelayer_shot_missile",
	Range = INT_MAX,
	Attacks = 2,
	AttacksRemaining = {},
	ArtilleryHeight = GetYVelocity(3),
	Damage = 1,
	PowerCost = 1,
	Upgrades = 2,
	UpgradeCost = {1, 2},
	UpgradeList = {"+1 Attack", "+2 Attacks"},
	CustomTipImage = "lmn_Minelayer_Launcher_Tip",
	TipImage = {
		CustomPawn = "lmn_MinelayerMech",
		CustomEnemy = "Spiderling1",
		Unit = Point(2,3),
		Enemy = Point(2,2),
		Mountain = Point(2,1),
		Enemy2 = Point(2,0),
		Target = Point(2,2),
		Second_Origin = Point(2,3),
		Second_Target = Point(2,0)
	}
}

function lmn_Minelayer_Launcher.UpdateArtilleryHeight()
	local hoveredSkill = modApi:getHoveredSkill()
	if hoveredSkill then return end

	if hoveredTile then
		local pawn = Board:GetSelectedPawn()
		local distance = pawn:GetSpace():Manhattan(hoveredTile)
		Values.y_velocity = GetYVelocity(distance)
	end
end

lmn_Minelayer_Launcher_A = lmn_Minelayer_Launcher:new{
	Self = "lmn_Minelayer_Launcher_A",
	UpgradeDescription = "Increases number of rockets by 1",
	Attacks = 3,
	CustomTipImage = "lmn_Minelayer_Launcher_Tip_A",
	TipImage = shallow_copy(lmn_Minelayer_Launcher.TipImage)
}
lmn_Minelayer_Launcher_A.TipImage.CustomEnemy = "Scarab1"

lmn_Minelayer_Launcher_B = lmn_Minelayer_Launcher:new{
	Self = "lmn_Minelayer_Launcher_B",
	UpgradeDescription = "Increases number of rockets by 2",
	Attacks = 4,
	CustomTipImage = "lmn_Minelayer_Launcher_Tip_B",
	TipImage = shallow_copy(lmn_Minelayer_Launcher.TipImage)
}
lmn_Minelayer_Launcher_B.TipImage.CustomEnemy = "Scorpion1"

lmn_Minelayer_Launcher_AB = lmn_Minelayer_Launcher:new{
	Self = "lmn_Minelayer_Launcher_AB",
	Attacks = 5,
	CustomTipImage = "lmn_Minelayer_Launcher_Tip_AB",
	TipImage = shallow_copy(lmn_Minelayer_Launcher.TipImage)
}
lmn_Minelayer_Launcher_AB.TipImage.CustomEnemy = "Scarab2"

-- returns true if pawn will die on this tile
local function InPit(pawn)
	local tile = pawn:GetSpace()
	local terrain = Board:GetTerrain(tile)
	
	local surviveHole = pawn:IsFlying() and not pawn:IsFrozen()
	local surviveWater = _G[pawn:GetType()].Massive or surviveHole
	
	return
		(terrain == TERRAIN_WATER and not surviveWater) or
		(terrain == TERRAIN_HOLE and not surviveHole)
end

local function GetTileHealth(tile, isTipImage)
	if
		GetCurrentMission()			and
		not IsTestMechScenario()	and
		not isTipImage
	then
		return modApiExt.board:getTileHealth(tile)
	end
	
	return 1
end

function lmn_Minelayer_Launcher:GetTargetArea(point)
	local ret = PointList()
	
	for i = DIR_START, DIR_END do
		for k = 1, self.Range do
			local curr = DIR_VECTORS[i]*k + point
			if not Board:IsValid(curr) then
				break
			end
			ret:push_back(curr)
		end
	end
	
	return ret
end

-- custom GetProjectileEnd, for multishot purposes.
function lmn_Minelayer_Launcher:GetProjectileEnd(p1, p2)
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

function lmn_Minelayer_Launcher:GetSkillEffect(p1, p2, parentSkill, isTipImage, isScript, useArtillery)
	local ret = SkillEffect()
	local shooter = Board:GetPawn(p1)
	if not shooter then
		return ret
	end
	
	local id = shooter:GetId()
	local distance = p1:Manhattan(p2)
	local dir = GetDirection(p2 - p1)
	
	if isScript then
		-- GetSkillEffect called recursively.
		ret.iOwner = shooter:GetId()
		ret.piOrigin = p1
		
		effectBurst.Add(ret, p1, "lmn_Emitter_Minelayer_Launcher_Small", DIR_NONE)
		effectBurst.Add(ret, p1, "lmn_Emitter_Minelayer_Launcher_Small_Front", DIR_NONE)
		
		local id = shooter:GetId()
		local dir = GetDirection(p2 - p1)
		local target
		
		----------------------
		-- attack calculation
		----------------------
		local attacksLeft = lmn_Minelayer_Launcher.AttacksRemaining[id] or 0
		local attacks = 1
		
		if useArtillery then
			target = p2
			attacks = attacksLeft
		else
			target = self:GetProjectileEnd(p1, p2)
			
			local pawn = Board:GetPawn(target)
			
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
				local health = Board:GetHealth(target)
				
				if Board:IsFrozen(target) then
					health = health + 1
				end
				
				if Board:IsShield(target) then
					health = health + 1
				end
				
				attacks = health
			end
		end
		
		local distance = p1:Manhattan(target)
		attacks = math.min(attacksLeft, attacks)
		lmn_Minelayer_Launcher.AttacksRemaining[id] = lmn_Minelayer_Launcher.AttacksRemaining[id] - attacks
		
		local time = 0
		local events = {}
		
		local function AddTrailWhile(func)
			while func() do
				while events[#events] and events[#events].time < time do
					effectBurst.Add(ret, events[#events].tile, events[#events].emitter, dir)
					table.remove(events, #events)
				end
				
				time = time + 0.1
				ret:AddDelay(0.1)
			end
		end
		
		---------------------
		-- damage resolution
		---------------------
		for i = 1, attacks do
			effectBurst.Add(ret, p1, "lmn_Emitter_Minelayer_Launcher_Big", DIR_NONE)
			effectBurst.Add(ret, p1, "lmn_Emitter_Minelayer_Launcher_Small_Front", DIR_NONE)
			effectBurst.Add(ret, p1, "lmn_Emitter_Minelayer_Launcher_Small_Front", DIR_NONE)
			ret:AddSound("/weapons/rocket_launcher")
			ret:AddSound("/weapons/boulder_throw")
			
			local weapon = SpaceDamage(target, self.Damage)
			weapon.sSound = "/impact/generic/explosion"
			
			if useArtillery then
				weapon.sScript = string.format("Board:AddAnimation(%s, 'ExploArt1', NO_DELAY)", target:GetString())
				worldConstants:setHeight(ret, GetYVelocity(distance) * math.random(80, 120) / 100)
				ret:AddArtillery(p1, weapon, self.UpShot, NO_DELAY)
				worldConstants:resetHeight(ret)
			else
				local speed = math.random(55, 70) / 100
				
				weapon.sScript = string.format("Board:AddAnimation(%s, 'ExploAir1', NO_DELAY)", target:GetString())
				worldConstants:setSpeed(ret, speed)
				ret:AddProjectile(p1, weapon, self.ProjectileArt, NO_DELAY)
				worldConstants:resetSpeed(ret)
				
				for k = 0, distance do
					local iMax = 3
					for i = 1, iMax do
						table.insert(
							events,
							{
								time = time + 0.1 + (k - 1 + i/iMax) * 0.08 * worldConstants:getDefaultSpeed() / speed,
								tile = p1 + DIR_VECTORS[dir] * k,
								emitter = "lmn_Emitter_Minelayer_Launcher_Trail"
							}
						)
					end
				end
				
				table.sort(events, function(a, b) return a.time > b.time end)
			end
			
			-- minimum delay between shots.
			-- can take longer due to board being resolved.
			local delay = time + math.random(5, 40) / 100
			
			AddTrailWhile(function() return time < delay end)
		end
		
		AddTrailWhile(function() return #events > 0 end)
		
	else
		for k = 1, distance - 1 do
			if Board:IsBlocked(DIR_VECTORS[dir]*k + p1, PATH_PROJECTILE) then
				useArtillery = true
			end
		end
		
		----------------
		-- damage marks
		----------------
		if isTipImage then
			-- mark tipimage.
			if useArtillery then
				local tile = self.TipImage.Second_Target
				
				worldConstants:setHeight(ret, 0)
				ret:AddArtillery(p1, SpaceDamage(tile), "", NO_DELAY)
				worldConstants:resetHeight(ret)
				
				local mark = SpaceDamage(tile, self.Attacks)
				effectPreview:AddDamage(ret, mark)
			else
				worldConstants:setSpeed(ret, 999)
				ret:AddProjectile(p1, SpaceDamage(self.TipProjectileEnd), "", NO_DELAY)
				worldConstants:resetSpeed(ret)
				
				for i, v in ipairs(self.TipMarks) do
					local tile = v[1]
					local damage = v[2]
					local mark = SpaceDamage(tile, damage)
					mark.sImageMark = "combat/lmn_minelayer_preview_"
					
					if tile ~= self.TipProjectileEnd then
						mark.sImageMark = mark.sImageMark .."arrow_"
					end
					
					mark.sImageMark = mark.sImageMark .. damage ..".png"
					
					effectPreview:AddDamage(ret, mark)
					
					-- hack to replace mountain we just did damage to.
					if tile == self.TipProjectileEnd then
						ret:AddScript("Board:SetTerrain(".. tile:GetString() ..", TERRAIN_MOUNTAIN)")
					end
				end
			end
		else
			hoveredTile = p2
			
			local vBoard = virtualBoard.new()
			local target = p1
			for i = 1, self.Attacks do
				
				if useArtillery then
					target = p2
				else
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
				end
				
				-- apply damage to virtual board.
				vBoard:DamageSpace(SpaceDamage(target, self.Damage))
			end
			
			if useArtillery then
				-- preview projectile path.
				worldConstants:setHeight(ret, 0)
				ret:AddArtillery(p1, SpaceDamage(target), "", NO_DELAY)
				worldConstants:resetHeight(ret)
			else
				-- preview projectile path.
				worldConstants:setSpeed(ret, 999)
				ret:AddProjectile(p1, SpaceDamage(target), "", NO_DELAY)
				worldConstants:resetSpeed(ret)
			end
			
			-- mark tiles with vBoard state.
			vBoard:MarkDamage(ret, id, "lmn_Minelayer_Launcher")
		end
	end
	
	if not lmn_Minelayer_Launcher.AttacksRemaining[id] or lmn_Minelayer_Launcher.AttacksRemaining[id] > 0 then
		
		local attacks = lmn_Minelayer_Launcher.AttacksRemaining[id] or self.Attacks
		
		-------------------
		-- continue attack
		-------------------
		ret:AddScript(string.format([=[
			local fx = SkillEffect();
			fx:AddScript([[
				lmn_Minelayer_Launcher.AttacksRemaining[%s] = %s;
				Board:AddEffect(_G[%q]:GetSkillEffect(%s, %s, nil, %s, true, %s));
			]]);
			Board:AddEffect(fx);
		]=], id, attacks, self.Self, p1:GetString(), p2:GetString(), tostring(isTipImage), tostring(useArtillery)))
		
	else
		lmn_Minelayer_Launcher.AttacksRemaining[id] = nil
		
		if isTipImage then
			ret:AddDelay(1.3)
		end
	end
	
	return ret
end

lmn_Minelayer_Launcher_Tip = lmn_Minelayer_Launcher:new{
	Self = "lmn_Minelayer_Launcher_Tip",
	TipProjectileEnd = Point(2,1),
	TipMarks = {
		{Point(2,2), 1},
		{Point(2,1), 1}
	}
}

lmn_Minelayer_Launcher_Tip_A = lmn_Minelayer_Launcher_A:new{
	Self = "lmn_Minelayer_Launcher_Tip_A",
	TipProjectileEnd = Point(2,1),
	TipMarks = {
		{Point(2,2), 2},
		{Point(2,1), 1}
	}
}

lmn_Minelayer_Launcher_Tip_B = lmn_Minelayer_Launcher_B:new{
	Self = "lmn_Minelayer_Launcher_Tip_B",
	TipProjectileEnd = Point(2,1),
	TipMarks = {
		{Point(2,2), 3},
		{Point(2,1), 1}
	}
}

lmn_Minelayer_Launcher_Tip_AB = lmn_Minelayer_Launcher_AB:new{
	Self = "lmn_Minelayer_Launcher_Tip_AB",
	TipProjectileEnd = Point(2,1),
	TipMarks = {
		{Point(2,2), 4},
		{Point(2,1), 1}
	}
}

function lmn_Minelayer_Launcher_Tip:GetSkillEffect(p1, p2, parentSkill, isTipImage, ...)
	return lmn_Minelayer_Launcher.GetSkillEffect(self, p1, p2, parentSkill, true, ...)
end

lmn_Minelayer_Launcher_Tip_A.GetSkillEffect = lmn_Minelayer_Launcher_Tip.GetSkillEffect
lmn_Minelayer_Launcher_Tip_B.GetSkillEffect = lmn_Minelayer_Launcher_Tip.GetSkillEffect
lmn_Minelayer_Launcher_Tip_AB.GetSkillEffect = lmn_Minelayer_Launcher_Tip.GetSkillEffect

shop:addWeapon{ id = "lmn_Minelayer_Launcher", desc = "Adds MR Launcher to the store." }

local function init() end
local function load() end

return { init = init, load = load }
