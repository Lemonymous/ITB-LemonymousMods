
local this = {
	damage = {},
}

lmn_Gauss_Cannon = Skill:new{
	Self = "lmn_Gauss_Cannon",
	Name = "Gauss Cannon",
	Description = "Fires a piercing slug dealing a total of 6 damage.",
	Class = "",
	Icon = "weapons/lmn_gauss_cannon.png",
	PowerCost = 4,
	Damage = 6, -- total damage done, and tooltip
	Upgrades = 1,
	UpgradeCost = { 2 },
	UpgradeList = { "+2 Damage" },
	CustomTipImage = "lmn_Gauss_Cannon_Tip",
	TipImage = {
		Unit = Point(2,4),
		Enemy = Point(2,2),
		Enemy2 = Point(2,1),
		Enemy3 = Point(2,0),
		Target = Point(2,3),
		CustomEnemy = "Scorpion1",
	},
	lmn_CustomRarity = 4,
}

local function HasCorpse(pawn)
	return pawn:IsMech() or _G[pawn:GetType()]:GetCorpse()
end

local function GetProjectileEnd(p1, p2)
	assert(type(p1) == 'userdata')
	assert(type(p2) == 'userdata')
	assert(type(p1.x) == 'number')
	assert(type(p1.y) == 'number')
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
			if	not pawn						or
				pawn:GetHealth() > 0			or
				pawn:IsMech()					or
				_G[pawn:GetType()]:GetCorpse()
			then
				break
			end
		end
	end
	
	return target
end

function lmn_Gauss_Cannon:GetTargetArea(p)
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

function lmn_Gauss_Cannon:FireWeapon(p1, p2, isTipImage)
	local shooter = Board:GetPawn(p1)
	if not shooter then
		return
	end
	
	local effect = SkillEffect()
	effect.iOwner = shooter:GetId()
	effect.piOrigin = p1
	
	local id = shooter:GetId()
	local dir = GetDirection(p2 - p1)
	local target = GetProjectileEnd(p1, p2)
	
	local pawn = Board:GetPawn(target)
	local damageLeft = this.damage[id]
	local damage = 1
	
	----------------------
	-- damage calculation
	----------------------
	if pawn then
		local health = pawn:GetHealth()
		
		if health > 0 then
			if HasCorpse(pawn) then
				damage = damageLeft
			else
				damage = math.min(damageLeft, health)
			end
			
			if pawn:IsShield() then
				damage = 1
			elseif pawn:IsFrozen() then
				damage = 1
			elseif pawn:IsAcid() then
				damage = math.ceil(damage / 2)
			elseif pawn:IsArmor() then
				damage = math.min(damageLeft, damage + 1)
			end
		else
			damage = damageLeft
		end
	elseif Board:IsUniqueBuilding(target) then
		damage = damageLeft
	elseif not Board:IsBlocked(target, PATH_PROJECTILE) then
		damage = damageLeft
	end
	
	---------------
	-- smoke trail
	---------------
	local distance = p2:Manhattan(target)
	for k = 0, distance do
		local curr = p2 + DIR_VECTORS[dir] * k
		this.effectBurst.Add(effect, curr, "lmn_Emitter_Railgun_".. dir, dir, isTipImage)
	end
	
	---------------------
	-- damage resolution
	---------------------
	local rail = SpaceDamage(target, damage)
	rail.sSound = "/impact/generic/explosion"
	effect:AddDamage(rail)
	
	this.damage[id] = this.damage[id] - damage
	
	if this.damage[id] > 0 then
		-------------------
		-- continue attack
		-------------------
		effect:AddScript([[
			local p1 = ]].. p1:GetString() ..[[;
			local p2 = ]].. target:GetString() ..[[;
			_G[']].. self.Self ..[[']:FireWeapon(p1, p2, ]].. tostring(isTipImage) ..[[);
		]])
	else
		--------
		-- end
		--------
		this.damage[id] = nil
	end
	
	Board:AddEffect(effect)
end

function lmn_Gauss_Cannon:GetSkillEffect(p1, p2, parentSkill, isTipImage)
	local ret = SkillEffect()
	local shooter = Board:GetPawn(p1)
	if not shooter then
		return ret
	end
	
	local id = shooter:GetId()
	local dir = GetDirection(p2 - p1)
	local target = p1
	this.damage[id] = self.Damage
	
	ret:AddSound("/weapons/modified_cannons")
	ret:AddSound("/weapons/burst_beam")
	
	----------------
	-- damage marks
	----------------
	if isTipImage then
		-- mark tipimage.
		this.worldConstants.SetSpeed(ret, 999)
		ret:AddProjectile(p1, SpaceDamage(self.TipProjectileEnd), "", NO_DELAY)
		this.worldConstants.ResetSpeed(ret)
		
		for i, v in ipairs(self.TipMarks) do
			local tile = v[1]
			local damage = v[2]
			local mark = SpaceDamage(tile, damage)
			
			if tile ~= self.TipProjectileEnd then
				mark.sImageMark = "combat/lmn_gauss_cannon_preview_".. damage ..".png"
			end
				
			this.effectPreview:addDamage(ret, mark)
		end
	else
		local vBoard = this.virtualBoard.new()
		local remaining = self.Damage
		while remaining > 0 do
			local damage = 1
			
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
			
			if vBoard:IsBlocked(target) then
				local pawnState = vBoard:GetPawnState(target)
				if pawnState then
					if
						pawnState.isShield or
						pawnState.isFrozen
					then
						damage = 1
					elseif pawnState.health > 0 then
						if pawnState.isAcid then
							damage = math.ceil(pawnState.health / 2)
						elseif pawnState.isArmor then
							damage = pawnState.health + 1
						elseif pawnState.health > 0 then
							damage = pawnState.health
						else
							damage = remaining
						end
					else
						damage = remaining
					end
				else
					damage = 1
				end
			end
			
			damage = math.min(remaining, damage)		-- clamp damage
			remaining = math.max(0, remaining - damage)	-- deduct damage
			
			-- apply damage to virtual board.
			vBoard:DamageSpace(SpaceDamage(target, damage))
		end
		
		-- preview projectile path.
		this.worldConstants.SetSpeed(ret, 999)
		ret:AddProjectile(p1, SpaceDamage(target), "", NO_DELAY)
		this.worldConstants.ResetSpeed(ret)
		
		-- mark tiles with vBoard state.
		vBoard:MarkDamage(ret, id, "lmn_Gauss_Cannon")
	end
	
	---------------------
	-- damage resolution
	---------------------
	ret:AddScript([[
		local p1 = ]].. p1:GetString() ..[[;
		local p2 = ]].. (p1 + DIR_VECTORS[dir]):GetString() ..[[;
		_G[']].. self.Self ..[[']:FireWeapon(p1, p2, ]].. tostring(isTipImage) ..[[);
	]])
	
	return ret
end

lmn_Gauss_Cannon_A = lmn_Gauss_Cannon:new{
	Self = "lmn_Gauss_Cannon_A",
	UpgradeDescription = "Increases damage by 2",
	Damage = 8,
	CustomTipImage = "lmn_Gauss_Cannon_Tip_A",
}

lmn_Gauss_Cannon_Tip = lmn_Gauss_Cannon:new{
	Self = "lmn_Gauss_Cannon_Tip",
	TipProjectileEnd = Point(2,1),
	TipMarks = {
		{Point(2,2), 3},
		{Point(2,1), 3},
	}
}

lmn_Gauss_Cannon_Tip_A = lmn_Gauss_Cannon_A:new{
	Self = "lmn_Gauss_Cannon_Tip_A",
	TipProjectileEnd = Point(2,0),
	TipMarks = {
		{Point(2,2), 3},
		{Point(2,1), 3},
		{Point(2,0), 2},
	}
}

function lmn_Gauss_Cannon_Tip:GetSkillEffect(p1, p2, parentSkill)
	return lmn_Gauss_Cannon.GetSkillEffect(self, p1, p2, parentSkill, true)
end

lmn_Gauss_Cannon_Tip_A.GetSkillEffect = lmn_Gauss_Cannon_Tip.GetSkillEffect

function this:init(mod)
	require(mod.scriptPath .."shop"):addWeapon({
		id = "lmn_Gauss_Cannon",
		name = lmn_Gauss_Cannon.Name,
		desc = lmn_Gauss_Cannon.Description,
	})
	
	self.worldConstants = require(mod.scriptPath .."worldConstants")
	self.virtualBoard = require(mod.scriptPath .."virtualBoard")
	self.effectBurst = require(mod.scriptPath .."effectBurst")
	self.effectPreview = LApi.library:fetch("effectPreview")
	
	modApi:appendAsset("img/weapons/lmn_gauss_cannon.png", mod.resourcePath .."img/weapons/gauss_cannon.png")
	
	for i = 1, 6 do
		modApi:appendAsset("img/combat/lmn_gauss_cannon_preview_".. i ..".png", mod.resourcePath .."img/combat/preview_arrow_".. i ..".png")
		Location["combat/lmn_gauss_cannon_preview_".. i ..".png"] = Point(-16, 0)
	end
	
	-- angles matching the board directions,
	-- with variance going an equal amount to either side.
	local angle_variance = 180
	local angle_0 = 323 + angle_variance / 2
	local angle_1 = 37 + angle_variance / 2
	local angle_2 = 142 + angle_variance / 2
	local angle_3 = 218 + angle_variance / 2
	
	lmn_Emitter_Railgun_0 = Emitter:new{
		image = "effects/smoke/art_smoke.png",
		max_alpha = 0.25,
		x = 0,
		y = 10,
		angle = angle_0,
		angle_variance = angle_variance,
		speed = 0.18,
		variance = 0,
		variance_x = 8,
		variance_y = 4,
		rot_speed = 10,
		burst_count = 20,
		lifespan = 1.8,
		gravity = false,
		layer = LAYER_FRONT,
	}
	
	lmn_Emitter_Railgun_1 = lmn_Emitter_Railgun_0:new{ angle = angle_1 }
	lmn_Emitter_Railgun_2 = lmn_Emitter_Railgun_0:new{ angle = angle_2 }
	lmn_Emitter_Railgun_3 = lmn_Emitter_Railgun_0:new{ angle = angle_3 }
end

function this:load(options, modApiExt)
	self.modApiExt = modApiExt
end

return this