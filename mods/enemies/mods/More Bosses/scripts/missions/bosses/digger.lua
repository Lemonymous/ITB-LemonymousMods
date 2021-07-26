
local this = {
	desc = "Adds the Digger Leader",
	sMission = "Mission_DiggerBoss",
	islandLock = 3,
}

Mission_DiggerBoss = Mission_Boss:new{
	BossPawn = "DiggerBoss",
	SpawnStartMod = -1,
	SpawnMod = -2,
	BossText = "Destroy the Digger Leader"
}

DiggerBoss = Pawn:new{
	Name = "Digger Leader",
	Health = 5,
	MoveSpeed = 3,
	Image = "digger",
	ImageOffset = 2,
	SkillList = { "lmn_DiggerAtkB" },
	SoundLocation = "/enemy/digger_2/",
	Massive = true,
	ImpactMaterial = IMPACT_INSECT,
	DefaultTeam = TEAM_ENEMY,
	Portrait = "enemy/DiggerB",
	Tier = TIER_BOSS,
}

lmn_DiggerAtkB = DiggerAtk1:new{
	Name = "Digging Tusks",
	Description = "Create a defensive rock wall before forcefully attacking adjacent tiles.",
	Damage = 3,
	Class = "Enemy",
	Icon = "weapons/enemy_rocker1.png",
	SoundId = "digger_2",
	CustomTipImage = "lmn_DiggerAtkB_Tip",
	TipImage = {
		Unit = Point(2,3),
		Enemy = Point(2,2),
		Building1 = Point(1,3),
		Building2 = Point(2,0),
		Target = Point(2,3),
		CustomPawn = "DiggerBoss"
	}
}

local function IsDiggerBoss(pawn)
	return list_contains(_G[pawn:GetType()].SkillList, "lmn_DiggerAtkB")
end

-- returns true if list is empty.
local function list_isEmpty(list)
	for _,_ in pairs(list) do
		return false
	end
	return true
end

-- returns true if pawn will die on this tile
local function IsDeathTile(tile, pawn)
	if Board:IsPawnSpace(tile) and Board:GetPawn(tile):GetId() ~= pawn:GetId() then
		return false
	end
	
	local terrain = Board:GetTerrain(tile)
	local surviveHole = pawn:IsFlying() and not pawn:IsFrozen()
	local surviveWater = _G[pawn:GetType()]:GetMassive() or surviveHole
	
	return
		(terrain == TERRAIN_WATER and not surviveWater) or
		(terrain == TERRAIN_HOLE and not surviveHole)
end

-- adds a queued delay to a SkillEffect.
local function AddQueuedDelay(effect, p1, delay)
	local dummy = SpaceDamage(p1)
	dummy.bHide = true
	effect:AddQueuedProjectile(dummy, "", delay)
end

local isTargetScore = nil
function lmn_DiggerAtkB:GetTargetScore(p1, p2)
	isTargetScore = true
	local score = Skill.GetTargetScore(self, p1, p2)
	isTargetScore = nil
	return score
end

function lmn_DiggerAtkB:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	
	-- Queued attacks are weird. We need to make sure
	-- we have the correct pawn.
	local pawn = Board:GetPawn(p1)
	if not pawn or not IsDiggerBoss(pawn) then
		return ret
	end
	
	local mission = GetCurrentMission()
	if not mission then
		return ret
	end
	
	local id = pawn:GetId()
	mission[this.diggers] = mission[this.diggers] or {}
	mission[this.diggers][id] = mission[this.diggers][id] or {}
	mission[this.diggers][id].targetId = mission[this.diggers][id].targetId or {}
	
	local bossTbl = mission[this.diggers][id]
	
	-- simulate attack for target score.
	if isTargetScore then
		for dir = DIR_START, DIR_END do
			local step = DIR_VECTORS[dir]
			local curr = p1 + step
			if Board:IsValid(curr) then
				ret:AddQueuedDamage(SpaceDamage(curr, self.Damage))			-- damage adjacent tile
				
				if Board:IsValid(curr + step) then
					local pawn = Board:GetPawn(curr)
					
					if (pawn and not pawn:IsGuarding())
					or not Board:IsBlocked(curr, PATH_GROUND) then
						
						local target = GetProjectileEnd(curr, curr + step)
						ret:AddQueuedDamage(SpaceDamage(target, 1))			-- push damage at end of rock/pawn
					end
				end
			end
		end
	else
		-- actual attack.
		--	iterate tiles adjacent to digger.
		local targets = {}
		local range = 0
		
		for dir = DIR_START, DIR_END do
			local step = DIR_VECTORS[dir]
			local curr = p1 + step
			
			if Board:IsValid(curr) then
				--	create walls of rock around digger.
				if
					not Board:IsBlocked(curr, PATH_PROJECTILE)	and
					Board:GetTerrain(curr) ~= TERRAIN_WATER		and
					not Board:IsPod(curr)
				then
					local damage = SpaceDamage(curr)
					damage.sPawn = "Wall"
					damage.sSound = "/enemy/".. self.SoundId .."/attack_queued"
					ret:AddDamage(damage)
				end
				
				--	check if there is an adjacent pawn, and track it.
				--	we need to remember this pawn for when we send it charging.
				if not bossTbl.targetId[dir] and Board:IsPawnSpace(curr) then
					bossTbl.targetId[dir] = Board:GetPawn(curr):GetId()
				end
				
				--	now look to see if we are tracking any adjacent pawns,
				--	in order to ignore it in our Board:IsBlocked checks.
				local pawn
				if bossTbl.targetId[dir] then
					pawn = Board:GetPawn(bossTbl.targetId[dir])
				end
				
				if pawn then
					-- hide pawn so it does not trigger Board:IsBlocked
					--pawn:SetSpace(Point(-1,-1))
					local pathing = pawn:GetPathProf()
					local death
					
					local target = curr + step
					
					--	find the last available tile in a line before
					--	board is either blocked or not valid.
					while
						Board:IsValid(target)						and
						(
							not Board:IsBlocked(target, pathing)	or
							(
								target == pawn:GetSpace()			and
								not IsDeathTile(target, pawn)
							)
						)
					do
						target = target + step
					end
					
					if
						Board:IsValid(target)		and
						IsDeathTile(target, pawn)
					then
						death = DAMAGE_DEATH
					else
						target = target - step
					end
					
					-- move pawn back, and charge it.
					--pawn:SetSpace(curr)
					ret:AddQueuedCharge(Board:GetPath(curr, target, pathing), NO_DELAY)
					
					--	store end point of the charge and the damage to apply to it.
					--	we'll add it later after the correct delay.
					targets[dir] = {point = target, death = death}
					range = math.max(range, p1:Manhattan(target))
					
					local damage = SpaceDamage(curr)
					damage.sSound = "/enemy/".. self.SoundId .."/attack"
					damage.sAnimation = "explorocker_".. dir
					ret:AddQueuedDamage(damage)
				else
					bossTbl.targetId[dir] = nil
					
					local damage = SpaceDamage(curr, self.Damage, dir)
					damage.sSound = "/enemy/".. self.SoundId .."/attack"
					damage.sAnimation = "explorocker_".. dir
					ret:AddQueuedDamage(damage)
				end
			end
		end
		
		--	space out damage and effects based on time of impact.
		for k = 1, range do
			if k > 1 then
				AddQueuedDelay(ret, p1, 0.06)
			end
			for dir = DIR_START, DIR_END do
				local step = DIR_VECTORS[dir]
				
				--	the current tile we are iterating.
				local curr = p1 + step * k
				
				--	this returns true if we are sending
				--	a pawn charging in this direction.
				if targets[dir] then
					--	if charge destination has been reached.
					if targets[dir].point == curr then
						local damage = SpaceDamage(curr, targets[dir].death or self.Damage)
						
						--	don't push on the edge of the board, or if
						--	the pawn charges into water or a hole.
						if not targets[dir].death then
							damage.iPush = dir
							if
								Board:IsValid(curr + step)						and
								Board:IsBlocked(curr + step, PATH_PROJECTILE)
							then
								if
									this.highlighted == p1		and
									Board:GetBusyState() == 0
								then
									local elevation = ""
									if Board:GetTerrain(curr) == TERRAIN_ICE then
										elevation = "ice_"
									elseif Board:GetTerrain(curr) == TERRAIN_WATER then
										elevation = "water_"
									end
									damage.sImageMark = "combat/hit_".. elevation .. dir ..".png"
								end
							end
						end
						
						--	manually add the pushbox and
						--	damage star when appropriate.
						ret:AddQueuedDamage(damage)
						
					--	run the following code for every tile
					--	before charge destination has been reached.
					elseif this.modApiExt.vector:length(curr - p1) < this.modApiExt.vector:length(targets[dir].point - p1) then
						ret:AddQueuedScript("Board:AddBurst(Point(".. curr.x ..", ".. curr.y .."), 'Emitter_Burst_$tile' , ".. dir ..")")
						ret:AddQueuedScript("Board:Bounce(Point(".. curr.x ..", ".. curr.y .."), -3)")
					end
				end
			end
		end
	end
	return ret
end

-- hardcoding tipimage
lmn_DiggerAtkB_Tip = lmn_DiggerAtkB:new{}

function lmn_DiggerAtkB_Tip:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	-- create walls.
	for dir = 1, 2 do
		local damage = SpaceDamage(p1 + DIR_VECTORS[dir])
		damage.sPawn = "Wall"
		ret:AddDamage(damage)
	end
	
	-- charge and damage animation dir 0 through 2.
	local range = {[0] = 2, [1] = 2, [2] = 2}
	for dir = 0, 2 do
		ret:AddQueuedCharge(Board:GetPath(p1 + DIR_VECTORS[dir], p1 + DIR_VECTORS[dir] * range[dir], PATH_GROUND), NO_DELAY)
		local damage = SpaceDamage(p1 + DIR_VECTORS[dir])
		damage.sAnimation = "explorocker_".. dir
		ret:AddQueuedDamage(damage)
	end
	
	-- damage and animation dir 3
	local damage = SpaceDamage(p1 + DIR_VECTORS[3], self.Damage, 3)
	damage.sAnimation = "explorocker_3"
	ret:AddQueuedDamage(damage)
	
	-- emitters, bounces and end of charge damage dir 0 through 2
	for k = 1, 3 do
		if k > 1 then
			AddQueuedDelay(ret, p1, 0.06)
		end
		for dir = 0, 2 do
			local curr = p1 + DIR_VECTORS[dir] * k
			if k < range[dir] then
				ret:AddQueuedScript("Board:AddBurst(Point(".. curr.x ..", ".. curr.y .."), 'Emitter_Burst_$tile' , ".. dir ..")")
				ret:AddQueuedScript("Board:Bounce(Point(".. curr.x ..", ".. curr.y .."), -3)")
			elseif k == range[dir] then
				local damage = SpaceDamage(curr, self.Damage, dir)
				damage.sImageMark = "combat/hit_" .. dir ..".png"
				ret:AddQueuedDamage(damage)
			end
		end
	end
	
	return ret
end

Mission_DiggerBoss.StartBoss = function(self)
	Mission_Boss.StartBoss(self)
	local boss = Board:GetPawn(self.BossID)
	local bossTile = boss:GetSpace()
	
	local size = Board:GetSize()
	for x = size.x - 1, 0, -1 do
		local tiles = {}
		for y = 0, size.y - 1 do
			local point = Point(x,y)
			if	not Board:IsBlocked(point, PATH_GROUND)	and
				not Board:IsPod(point)					and
				not Board:IsTargeted(point)				and
				not Board:IsSmoke(point)				and
				not Board:IsAcid(point)					and
				not Board:IsFire(point)					and
				not Board:IsSpawning(point)				and
				not Board:IsDangerous(point)			and
				not Board:IsDangerousItem(point)		or
				point == bossTile						then
				
				table.insert(tiles, point)
			end
		end
		if #tiles > 0 then
			boss:SetSpace(random_element(tiles))
			break
		end
	end
end

function this:init(mod)
	self.diggers = mod.id .."_diggers"
	
	self.boss = require(mod.scriptPath .."boss")
	self.boss:Add(self)
	
	modApi:appendAsset("img/weapons/enemy_rockerB.png", mod.resourcePath .."img/weapons/enemy_rockerB.png")
	
	modApi:appendAsset("img/effects/shot_rocker_U.png", mod.resourcePath .."img/effects/shot_rocker_U.png")
	modApi:appendAsset("img/effects/shot_rocker_R.png", mod.resourcePath .."img/effects/shot_rocker_R.png")
	
	modApi:appendAsset("img/combat/hit_0.png", mod.resourcePath .."img/combat/hit_0.png")
	modApi:appendAsset("img/combat/hit_1.png", mod.resourcePath .."img/combat/hit_1.png")
	modApi:appendAsset("img/combat/hit_2.png", mod.resourcePath .."img/combat/hit_2.png")
	modApi:appendAsset("img/combat/hit_3.png", mod.resourcePath .."img/combat/hit_3.png")
	modApi:appendAsset("img/combat/hit_ice_0.png", mod.resourcePath .."img/combat/hit_0.png")
	modApi:appendAsset("img/combat/hit_ice_1.png", mod.resourcePath .."img/combat/hit_1.png")
	modApi:appendAsset("img/combat/hit_ice_2.png", mod.resourcePath .."img/combat/hit_2.png")
	modApi:appendAsset("img/combat/hit_ice_3.png", mod.resourcePath .."img/combat/hit_3.png")
	modApi:appendAsset("img/combat/hit_water_0.png", mod.resourcePath .."img/combat/hit_0.png")
	modApi:appendAsset("img/combat/hit_water_1.png", mod.resourcePath .."img/combat/hit_1.png")
	modApi:appendAsset("img/combat/hit_water_2.png", mod.resourcePath .."img/combat/hit_2.png")
	modApi:appendAsset("img/combat/hit_water_3.png", mod.resourcePath .."img/combat/hit_3.png")
	
	local offset = Point(-44,-11)
	Location["combat/hit_0.png"] = offset
	Location["combat/hit_1.png"] = offset
	Location["combat/hit_2.png"] = offset
	Location["combat/hit_3.png"] = offset
	
	offset = Point(-44,-7)
	Location["combat/hit_ice_0.png"] = offset
	Location["combat/hit_ice_1.png"] = offset
	Location["combat/hit_ice_2.png"] = offset
	Location["combat/hit_ice_3.png"] = offset
	
	offset = Point(-44,-4)
	Location["combat/hit_water_0.png"] = offset
	Location["combat/hit_water_1.png"] = offset
	Location["combat/hit_water_2.png"] = offset
	Location["combat/hit_water_3.png"] = offset
	
	sdlext.addGameExitedHook(function()
		self.highlighted = nil
	end)
end

function this:load(modApiExt)
	self.modApiExt = modApiExt
	
	modApiExt:addTileHighlightedHook(function(_, tile) self.highlighted = tile end)
	modApiExt:addTileUnhighlightedHook(function() self.highlighted = nil end)
	
	modApi:addMissionUpdateHook(function(mission)
		local rem = {}
		
		--	iterate all tracked digger bosses.
		if mission[self.diggers] then
			for bossId, bossTbl in pairs(mission[self.diggers]) do
				local boss = Board:GetPawn(bossId)
				if not boss then
					table.insert(rem, bossId)
				else
					--	if a pawn moves away from a digger's attack,
					--	or or visa versa; remove pawn from digger's targets.
					for dir, pawnId in pairs(bossTbl.targetId) do
					
						local curr = boss:GetSpace() + DIR_VECTORS[dir]
						local pawn = Board:GetPawn(pawnId)
						if
							not pawn				or
							pawn:GetSpace() ~= curr
						then
							bossTbl.targetId[dir] = nil
						end
					end
				end
			end
			
			for _, id in ipairs(rem) do
				table.remove(mission[self.diggers], id)
			end
			
			if list_isEmpty(mission[self.diggers]) then
				mission[self.diggers] = nil
			end
		end
	end)
	
	self.boss:ResetSpawnsWhenKilled(self)
	self.boss:SetSpawnsForDifficulty(
		self,
		{
			difficulty = DIFF_EASY,
			SpawnStartMod = -2,
			SpawnMod = -2
		}
	)
end

return this