
local this = {
	attacks = {},
}

lmn_Autocannon = Skill:new{
	Self = "lmn_Autocannon",
	Name = "Autocannon",
	Description = "Fires 2 powerful projectiles that damages and pushes at impact.",
	Class = "",
	Icon = "weapons/lmn_autocannon.png",
	PowerCost = 4,
	Damage = 2,
	Push = true,
	Attacks = 2,
	Upgrades = 2,
	UpgradeCost = { 2, 2 },
	UpgradeList = { "+1 Damage", "+1 Attack" },
	CustomTipImage = "lmn_Autocannon_Tip",
	TipImage = {
		Unit = Point(2,4),
		Enemy = Point(2,2),
		Enemy2 = Point(2,1),
		Enemy3 = Point(2,0),
		Target = Point(2,3),
		CustomEnemy = "Scarab2",
	},
	lmn_CustomRarity = 4,
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

function lmn_Autocannon:GetTargetArea(p)
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
function lmn_Autocannon:FireWeapon(p1, p2, isTipImage)
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
	local attacksLeft = this.attacks[id]
	local attacks = 1
	
	----------------------
	-- attack calculation
	----------------------
	if not Board:IsBlocked(target, PATH_PROJECTILE) then
		-- unload shots on empty tiles.
		attacks = attacksLeft
	end
	
	attacks = math.min(attacksLeft, attacks)
	this.attacks[id] = this.attacks[id] - attacks
	
	---------------------
	-- damage resolution
	---------------------
	for i = 1, attacks do
		effect:AddSound("/weapons/unstable_cannon")
		
		local weapon = SpaceDamage(target, self.Damage)
		weapon.iPush = self.Push and dir or DIR_NONE
		weapon.sSound = "/impact/generic/explosion"
		weapon.sScript = "Board:AddAnimation(".. target:GetString() ..", 'explopush1_".. dir .."', NO_DELAY)"
		
		this.worldConstants.SetSpeed(effect, 1)
		effect:AddProjectile(p1, weapon, "effects/shot_mechtank", NO_DELAY)
		this.worldConstants.ResetSpeed(effect)
		
		-- minimum delay between shots.
		-- can take longer due to board being resolved.
		effect:AddDelay(0.3)
	end
	
	-------------------
	-- continue attack
	-------------------
	if this.attacks[id] > 0 then
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
		
		this.attacks[id] = nil
	end
	
	Board:AddEffect(effect)
end

function lmn_Autocannon:GetSkillEffect(p1, p2, parentSkill, isTipImage)
	local ret = SkillEffect()
	local shooter = Board:GetPawn(p1)
	if not shooter then
		return ret
	end
	
	local id = shooter:GetId()
	local distance = p1:Manhattan(p2)
	local dir = GetDirection(p2 - p1)
	this.attacks[id] = self.Attacks
	
	----------------
	-- damage marks
	----------------
	if isTipImage then
		-- hardcoded tipimage marks.
		this.worldConstants.SetSpeed(ret, 999)
		ret:AddProjectile(p1, SpaceDamage(self.TipProjectileEnd), "", NO_DELAY)
		this.worldConstants.ResetSpeed(ret)
		
		for i, v in ipairs(self.TipMarks) do
			local tile = v[1]
			local damage = v[2]
			local mark = SpaceDamage(tile, damage)
			mark.sImageMark = "combat/lmn_autocannon_preview_"
			
			if tile ~= self.TipProjectileEnd then
				mark.sImageMark = mark.sImageMark .."arrow_"
			end
			
			if self.Push then
				mark.iPush = 5 -- hack to preview push_box without arrow.
				
				if Board:IsValid(tile + VEC_UP) then
					mark.sImageMark = mark.sImageMark .."push_" .. damage ..".png"
				else
					mark.sImageMark = "combat/arrow_off_up.png"
				end
			else
				mark.sImageMark = mark.sImageMark .. damage ..".png"
			end
			
			this.effectPreview:AddDamage(ret, mark)
		end
	else
		local vBoard = this.virtualBoard.new()
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
			vBoard:DamageSpace(SpaceDamage(target, self.Damage, self.Push and dir or DIR_NONE))
		end
		
		-- preview projectile path.
		this.worldConstants.SetSpeed(ret, 999)
		ret:AddProjectile(p1, SpaceDamage(target), "", NO_DELAY)
		this.worldConstants.ResetSpeed(ret)
		
		-- mark tiles with vBoard state.
		vBoard:MarkDamage(ret, id, "lmn_Autocannon")
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

lmn_Autocannon_A = lmn_Autocannon:new{
	Self = "lmn_Autocannon_A",
	UpgradeDescription = "Increases damage by 1.",
	Damage = 3,
	CustomTipImage = "lmn_Autocannon_Tip_A",
}

lmn_Autocannon_B = lmn_Autocannon:new{
	Self = "lmn_Autocannon_B",
	UpgradeDescription = "Increases shots fired by 1.",
	Attacks = 3,
	CustomTipImage = "lmn_Autocannon_Tip_B",
}

lmn_Autocannon_AB = lmn_Autocannon:new{
	Self = "lmn_Autocannon_AB",
	Damage = 3,
	Attacks = 3,
	CustomTipImage = "lmn_Autocannon_Tip_AB",
}

lmn_Autocannon_Tip = lmn_Autocannon:new{
	Self = "lmn_Autocannon_Tip",
	TipProjectileEnd = Point(2,2),
	TipMarks = {
		{Point(2,2), 4},
	}
}

function lmn_Autocannon_Tip:GetSkillEffect(p1, p2, parentSkill)
	return lmn_Autocannon.GetSkillEffect(self, p1, p2, parentSkill, true)
end

lmn_Autocannon_Tip_A = lmn_Autocannon_A:new{
	Self = "lmn_Autocannon_Tip_A",
	TipProjectileEnd = Point(2,1),
	TipMarks = {
		{Point(2,2), 3},
		{Point(2,1), 3},
	}
}

lmn_Autocannon_Tip_B = lmn_Autocannon_B:new{
	Self = "lmn_Autocannon_Tip_B",
	TipProjectileEnd = Point(2,1),
	TipMarks = {
		{Point(2,2), 4},
		{Point(2,1), 2},
	}
}

lmn_Autocannon_Tip_AB = lmn_Autocannon_AB:new{
	Self = "lmn_Autocannon_Tip_AB",
	TipProjectileEnd = Point(2,0),
	TipMarks = {
		{Point(2,2), 3},
		{Point(2,1), 3},
		{Point(2,0), 3},
	}
}

lmn_Autocannon_Tip_A.GetSkillEffect = lmn_Autocannon_Tip.GetSkillEffect
lmn_Autocannon_Tip_B.GetSkillEffect = lmn_Autocannon_Tip.GetSkillEffect
lmn_Autocannon_Tip_AB.GetSkillEffect = lmn_Autocannon_Tip.GetSkillEffect

function this:init(mod)
	require(mod.scriptPath .."shop"):addWeapon({
		id = "lmn_Autocannon",
		name = lmn_Autocannon.Name,
		desc = lmn_Autocannon.Description,
	})
	
	self.armorDetection = require(mod.scriptPath .."armorDetection")
	self.worldConstants = require(mod.scriptPath .."worldConstants")
	self.virtualBoard = require(mod.scriptPath .."virtualBoard")
	self.effectPreview = require(mod.scriptPath .."effectPreview")
	self.weaponMarks = require(mod.scriptPath .."weaponMarks")
	
	modApi:appendAsset("img/weapons/lmn_autocannon.png", mod.resourcePath .."img/weapons/autocannon.png")
	
	for i = 2, 4 do
		modApi:appendAsset("img/combat/lmn_autocannon_preview_arrow_".. i ..".png", mod.resourcePath .."img/combat/preview_arrow_".. i ..".png")
		modApi:appendAsset("img/combat/lmn_autocannon_preview_arrow_push_".. i ..".png", mod.resourcePath .."img/combat/preview_arrow_push_".. i ..".png")
		modApi:appendAsset("img/combat/lmn_autocannon_preview_push_".. i ..".png", mod.resourcePath .."img/combat/preview_push_".. i ..".png")
		Location["combat/lmn_autocannon_preview_arrow_".. i ..".png"] = Point(-16, 0)
		Location["combat/lmn_autocannon_preview_arrow_push_".. i ..".png"] = Point(-16, -5)
		Location["combat/lmn_autocannon_preview_push_".. i ..".png"] = Point(-16, -5)
	end
end

function this:load(options, modApiExt)
	self.modApiExt = modApiExt
end

return this