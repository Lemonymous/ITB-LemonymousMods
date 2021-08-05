
local mod = mod_loader.mods[modApi.currentMod]
local utils = require(mod.scriptPath .."libs/utils")
local effectBurst = LApi.library:fetch("effectBurst")

modApi:copyAsset("img/combat/icons/icon_sand_glow.png", "img/combat/icons/lmn_ds_icon_sand_glow.png")
modApi:copyAsset("img/combat/icons/icon_smoke_glow.png", "img/combat/icons/lmn_ds_icon_smoke_glow.png")
modApi:copyAsset("img/combat/icons/icon_smoke_immune_glow.png", "img/combat/icons/lmn_ds_icon_smoke_immune_glow.png")
modApi:appendAsset("img/effects/lmn_ds_shot_pistol_R.png", mod.resourcePath .."img/effects/shot_pistol_R.png")
modApi:appendAsset("img/effects/lmn_ds_shot_pistol_U.png", mod.resourcePath .."img/effects/shot_pistol_U.png")
modApi:appendAsset("img/weapons/lmn_ds_dual_pistols.png", mod.resourcePath .."img/weapons/dual_pistols.png")

local icon_loc = Point(-10,8)
Location["combat/icons/lmn_ds_icon_sand_glow.png"] = Point(-13,12)
Location["combat/icons/lmn_ds_icon_smoke_glow.png"] = icon_loc
Location["combat/icons/lmn_ds_icon_smoke_immune_glow.png"] = icon_loc

local function isRoadRunner(pawn)
	return pawn:GetPathProf() % 16 == PATH_ROADRUNNER
end

local function isEnemy(tile1, tile2)
	local pawn1 = Board:GetPawn(tile1)
	local pawn2 = Board:GetPawn(tile2)
	if not pawn1 or not pawn2 then return false end
	
	local team1 = Board:GetPawnTeam(tile1)
	local team2 = Board:GetPawnTeam(tile2)
	
	return team1 ~= team2
end

lmn_ds_DualPistols = Skill:new{
	Name = "Dual Pistols",
	Description = "Move in a line as allowed by your movement, attacking the last enemies you pass.",
	Icon = "weapons/lmn_ds_dual_pistols.png",
	Class = "Brute",
	PowerCost = 1,
	Damage = 1,
	Range = INT_MAX,
	Targets = 1,
	SpreadSmoke = false,
	AdvTargeting = true,
	MoveSpeedAsRange = true,
	MoveSpeedMinimum = nil,
	Upgrades = 2,
	UpgradeList = { "Kick Up Dust", "+1 Attack" },
	UpgradeCost = { 2, 3 },
	CustomTipImage = "lmn_ds_DualPistols_Tip",
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,0),
		Rock1 = Point(1,1),
		Enemy1 = Point(1,2),
		Enemy2 = Point(3,1),
		Friendly1 = Point(3,2)
	}
}

lmn_ds_DualPistols_A = lmn_ds_DualPistols:new{
	UpgradeDescription = "Create Smoke where you started. Passing through Smoke removes it, and spreads it to adjacent tiles.",
	SpreadSmoke = true,
	CustomTipImage = "lmn_ds_DualPistols_Tip_A",
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,0),
		Rock1 = Point(1,1),
		Enemy1 = Point(1,2),
		Enemy2 = Point(3,1),
		Friendly1 = Point(3,2),
		--Sand1 = Point(2,1),
		Smoke1 = Point(2,2)
	}
}

lmn_ds_DualPistols_B = lmn_ds_DualPistols:new{
	UpgradeDescription = "Increases number of attacks by 1.",
	CustomTipImage = "lmn_ds_DualPistols_Tip_B",
	Targets = 2
}

lmn_ds_DualPistols_AB = lmn_ds_DualPistols_A:new{
	CustomTipImage = "lmn_ds_DualPistols_Tip_AB",
	Targets = 2,
}

function lmn_ds_DualPistols:GetTargetArea(point)
	local ret = PointList()
	local range = self.MoveSpeedAsRange and Pawn:GetMoveSpeed() or self.Range
	
	if self.MoveSpeedMinimum and range == 0 then
		range = self.MoveSpeedMinimum
	end
	
	for dir = DIR_START, DIR_END do
		for k = 1, range do
			local curr = point + DIR_VECTORS[dir] * k
			
			if not Board:IsValid(curr)then
				break
			end
			
			if not Board:IsBlocked(curr, Pawn:GetPathProf()) then
				if not Board:IsItem(curr) then
					ret:push_back(curr)
				end
			end
			
			if not utils.IsTilePassable(curr, Pawn:GetPathProf()) then
				break
			end
		end
	end
	
	return ret
end

function lmn_ds_DualPistols:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local distance = p1:Manhattan(p2)
	local dir_forward = GetDirection(p2 - p1)
	local dir_back = (dir_forward+2)%4
	local dir_right = (dir_forward+1)%4
	local dir_left = (dir_forward-1)%4
	local vec_forward = DIR_VECTORS[dir_forward]
	local vec_right = DIR_VECTORS[dir_right]
	local vec_left = DIR_VECTORS[dir_left]
	local targets = 0
	local events = {}
	
	local sand = SpaceDamage()
	local smoke_create = SpaceDamage()
	local smoke_remove = SpaceDamage()
	
	sand.sImageMark = "combat/icons/lmn_ds_icon_sand_glow.png"
	smoke_create.sImageMark = "combat/icons/lmn_ds_icon_smoke_glow.png"
	smoke_remove.sImageMark = "combat/icons/lmn_ds_icon_smoke_immune_glow.png"
	
	local projectile = SpaceDamage(self.Damage)
	projectile.sSound = "/props/electric_smoke_damage"
	
	local first, last, increment = 0, distance, 1
	
	if self.AdvTargeting then
		first, last, increment = distance, 0, -1
	end
	
	-- find targets
	for k = first, last, increment do
		local curr = p1 + vec_forward * k
		local right = utils.GetProjectileEnd(curr, curr + vec_right)
		local left = utils.GetProjectileEnd(curr, curr + vec_left)
		local rightIsEnemy = right ~= curr and isEnemy(p1, right)
		local leftIsEnemy = left ~= curr and isEnemy(p1, left)
		
		if rightIsEnemy or leftIsEnemy then
			targets = targets + 1
			events[k] = {
				right = rightIsEnemy and right or nil,
				left = leftIsEnemy and left or nil,
			}
			
			if targets >= self.Targets then
				break
			end
		end
	end
	
	ret:AddSound("/mech/prime/punch_mech/move")
	ret:AddDelay(0.2)
	ret:AddSound("/enemy/shared/moved")
	ret:AddCharge(Board:GetPath(p1, p2, Pawn:GetPathProf()), NO_DELAY)
	
	for k = 0, distance do
		local curr = p1 + vec_forward * k
		local target = events[k]
		
		effectBurst.Add(ret, curr, "Emitter_Burst", dir_forward)
		effectBurst.Add(ret, curr, "Emitter_Burst", dir_forward)
		
		-- SpreadSmoke upgrade
		if self.SpreadSmoke then
			
				-- Mark smoke/unsmoke on traveled and adjacent tiles
				if --[[Board:IsTerrain(curr, TERRAIN_SAND) or]] Board:IsSmoke(curr) then
					--[[if Board:IsTerrain(curr, TERRAIN_SAND) then
						sand.loc = curr
						ret:AddDamage(sand)
					end]]
					
					if Board:IsSmoke(curr) then
						smoke_remove.loc = curr
						ret:AddDamage(smoke_remove)
					end
					
					smoke_create.loc = curr + vec_right
					smoke_create.sAnimation = "exploout0_" .. dir_right
					ret:AddDamage(smoke_create)
					
					smoke_create.loc = curr + vec_left
					smoke_create.sAnimation = "exploout0_" .. dir_left
					ret:AddDamage(smoke_create)
				end
				
				-- Smoke/Unsmoke traveled and adjacent tiles
				ret:AddScript(string.format([[
					local p, right, left = %s, %s, %s;
					
					--[=[if Board:IsTerrain(p, TERRAIN_SAND) then
						Board:SetTerrain(p, TERRAIN_ROAD);
						Board:SetSmoke(p, true, true)
					end;]=]
					
					if Board:IsSmoke(p) then
						Board:SetSmoke(p, false, false);
						Board:SetSmoke(p + right, true, false);
						Board:SetSmoke(p + left, true, false);
					end;
					
				]], curr:GetString(), vec_right:GetString(), vec_left:GetString()))
		
			if k == 0 then
				-- Mark smoke on starting tile
				smoke_create.loc = curr
				smoke_create.sAnimation = "exploout0_" .. dir_back
				ret:AddDamage(smoke_create)
				
				-- Smoke starting tile
				ret:AddScript(string.format([[
					local p = %s;
					
					--[=[if Board:IsTerrain(p, TERRAIN_SAND) then
						Board:SetTerrain(p, TERRAIN_ROAD);
					end;]=]
					
					if not Board:IsSmoke(p) then
						Board:SetSmoke(p, true, false);
					end;
					
				]], curr:GetString()))
			else
			end
		end
		
		-- damage
		if target then
			
			if target.right and target.left then
				ret:AddSound("/weapons/fire_beam")
				ret:AddSound("/weapons/mirror_shot")
			else
				ret:AddSound("/weapons/fire_beam")
				ret:AddSound("/weapons/modified_cannons")
			end
			
			local function FireProjectile(loc)
				if loc == nil then return end
				
				local dir = GetDirection(loc - curr)
				local sImageMark = ""
				local sScript = utils.GetGenericImpactSoundScript(loc, "impact/generic/general")
				sScript = string.format("%s; Board:AddAnimation(%s, 'lmn_ds_explo_plasma', NO_DELAY);", sScript, loc:GetString())
				
				if self.SpreadSmoke then
					if k > 0 then
						if loc == curr + DIR_VECTORS[dir] then
							if --[[Board:IsTerrain(curr, TERRAIN_SAND) or]] Board:IsSmoke(curr) then
								sImageMark = smoke_create.sImageMark
							end
						end
					end
				end
				
				projectile.loc = loc
				projectile.iPush = dir
				projectile.sScript = sScript
				projectile.sImageMark = sImageMark
				
				ret:AddProjectile(curr, projectile, "effects/lmn_ds_shot_pistol", NO_DELAY)
			end
			
			FireProjectile(target.right)
			FireProjectile(target.left)
		end
		
		ret:AddDelay(0.08)
	end
	
	return ret
end

lmn_ds_DualPistols_Tip = lmn_ds_DualPistols:new{}
lmn_ds_DualPistols_Tip_A = lmn_ds_DualPistols_A:new{}
lmn_ds_DualPistols_Tip_B = lmn_ds_DualPistols_B:new{}
lmn_ds_DualPistols_Tip_AB = lmn_ds_DualPistols_AB:new{}

function lmn_ds_DualPistols_Tip:GetSkillEffect(...)
	for s,p in pairs(self.TipImage) do
		if s:find("^Sand") then
			Board:SetTerrain(p, TERRAIN_SAND)
		end
		
		if s:find("^Rock") then
			Board:AddPawn("Wall", p)
		end
	end
	
	return lmn_ds_DualPistols.GetSkillEffect(self, ...)
end

lmn_ds_DualPistols_Tip_A.GetSkillEffect = lmn_ds_DualPistols_Tip.GetSkillEffect
lmn_ds_DualPistols_Tip_B.GetSkillEffect = lmn_ds_DualPistols_Tip.GetSkillEffect
lmn_ds_DualPistols_Tip_AB.GetSkillEffect = lmn_ds_DualPistols_Tip.GetSkillEffect
