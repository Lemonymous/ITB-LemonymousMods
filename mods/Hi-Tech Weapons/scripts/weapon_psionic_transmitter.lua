
local mod = mod_loader.mods[modApi.currentMod]
local modApiExt = mod.libs.modApiExt
local effectBurst = mod.libs.effectBurst
local effectPreview = mod.libs.effectPreview
local previewer = mod.libs.weaponPreview

local weapons
local highlighted
local selected

lmn_Psionic_Transmitter = Skill:new{
	Name = "Psi-Transmitter",
	Description = "Compels a unit within sight to execute a move action.",
	Class = "Science",
	Icon = "weapons/lmn_psionic_transmitter.png",
	Range = INT_MAX,
	PowerCost = 3,
	Upgrades = 1,
	UpgradeCost = { 2 },
	UpgradeList = { "Piercing" },
	CustomTipImage = "lmn_Psionic_Transmitter_Tip",
	TipImage = {
		Unit = Point(2,2),
		Enemy = Point(2,1),
		Enemy2 = Point(3,2),
		Target = Point(3,1),
		CustomEnemy = "Leaper1"
	},
}

local function IsBurrower(pawn)
	return _G[pawn:GetType()].Burrows
end

function lmn_Psionic_Transmitter:GetTargetArea(p1)
	local list = {}
	local marker
	
	self.Targets = {}
	
	for dir = DIR_START, DIR_END do
		for k = 1, self.Range do
			local curr = p1 + DIR_VECTORS[dir] * k
			if not Board:IsValid(curr) then
				break
			end
			
			local pawn = Board:GetPawn(curr)
			if
				-- grab points of pawns that
				-- are allowed to move.
				pawn					and
				not pawn:IsDead()		and
				pawn:GetMoveSpeed() > 0
				-- pawn:IsPowered() TODO: not sure how to detect this.
			then
				table.insert(list, curr)
				
				table.insert(self.Targets, pawn)
				local loc = pawn:GetSpace()
				local spaceDamage = SpaceDamage(loc)
				spaceDamage.sImageMark = "combat/icons/lmn_psi_icon_move_glow.png"
				
				previewer:AddImage(loc, "combat/lmn_square.png", GL_Color(255,255,255))
				previewer:AddDamage(spaceDamage)
				
				local reachable = extract_table(Board:GetReachable(
					pawn:GetSpace(),
					pawn:GetMoveSpeed(),
					pawn:GetPathProf()
				))
				
				for _, p in ipairs(reachable) do
					if
						Board:GetTerrain(p) ~= TERRAIN_WATER or
						not IsBurrower(pawn)
					then
						if not list_contains(list, p) then
							table.insert(list, p)
						end
					end
				end
			end
			
			if not self.Pierce and Board:IsBlocked(curr, PATH_PROJECTILE) then
				break
			end
		end
	end
	
	local ret = PointList()
	for _, p in ipairs(list) do
		ret:push_back(p)
	end
	
	return ret
end

function lmn_Psionic_Transmitter:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local shooter = Board:GetPawn(p1)
	local shooterId = shooter:GetId()
	local isTipImage = Board:IsTipImage()
	
	-- swap target if there is a pawn at p2.
	self.Target = Board:GetPawn(p2) or self.Target
	
	local target = self.Target
	
	if isTipImage then
		-- hardcoded tipimage target.
		target = Board:GetPawn(self.TipImage.Enemy)
	else
		-- keep track of this weapon,
		-- so we can clear Target if
		-- another weapon is armed.
		weapons = weapons or {}
		weapons[shooterId] = {
			weapon = self,
			weaponId = shooter:GetArmedWeaponId()
		}
	end
	
	-- return if we have
	-- no pawn to move.
	if not target then
		return ret
	end
	
	local reachable = extract_table(Board:GetReachable(
		target:GetSpace(),
		target:GetMoveSpeed(),
		target:GetPathProf()
	))
	
	if IsBurrower(target) then
		for i = #reachable, 1, -1 do
			if Board:GetTerrain(reachable[i]) == TERRAIN_WATER then
				table.remove(reachable, i)
			end
		end
	end
	
	---------
	-- marks
	---------
	if not isTipImage then
		
		-- mark tiles our target can reach.
		for _, p in ipairs(reachable) do
			previewer:AddImage(p, "combat/lmn_square.png", GL_Color(50,160,90))
		end
		
		-- mark movable pawns.
		for _, target in ipairs(self.Targets) do
			previewer:AddImage(target:GetSpace(), "combat/lmn_square.png", GL_Color(255,255,255))
		end
		
		-- add an icon to movable pawns.
		for _, target in ipairs(self.Targets) do
			local spaceDamage = SpaceDamage(target:GetSpace())
			spaceDamage.sImageMark = "combat/icons/lmn_psi_icon_move_glow.png"
			previewer:AddDamage(spaceDamage)
		end
	end
	
	-- return if target cannot reach p2.
	if not list_contains(reachable, p2) then
		return ret
	end
	
	-----------
	-- effects
	-----------
	local t1 = target:GetSpace()
	local tData = _G[target:GetType()]
	local dir = GetDirection(t1 - p1)
	local distance = p1:Manhattan(t1)
	
	ret:AddSound("ui/battle/radio_window_in")
	
	local d = SpaceDamage(p1)
	d.sAnimation = "lmn_Psi_Radio"
	d.bHide = true
	d.sSound = "voice/ralph"
	ret:AddDamage(d)
	
	local d = SpaceDamage(t1)
	d.sSound = "impact/generic/tractor_beam"
	d.bHide = true
	ret:AddDamage(d)
	
	local d = SpaceDamage(t1)
	d.sSound = "ui/battle/psion_attack"
	d.bHide = true
	ret:AddDamage(d)
	
	for k = 0, distance - 1 do
		local curr = p1 + DIR_VECTORS[dir] * k
		effectBurst.Add(ret, curr, "lmn_Emitter_Psi_Stun_".. dir, dir, isTipImage)
		ret:AddDelay(0.05)
	end
	
	local d = SpaceDamage(t1)
	d.sAnimation = "lmn_Psi_Stun"
	d.bHide = true
	ret:AddDamage(d)
	
	effectPreview:addHiddenLeap(ret, t1, t1, NO_DELAY)
	ret:AddSound(tData.SoundLocation .."hurt")
	
	local delay = 0
	local inc = 0.1
	while delay < 0.7 do
		delay = delay + inc
		ret:AddDelay(inc)
		effectBurst.Add(ret, t1, "lmn_Emitter_Psi_Stun_Static_".. dir, DIR_NONE, isTipImage)
	end
	
	ret:AddSound("ui/battle/radio_window_out")
	
	---------------
	-- move target
	---------------
	if target:IsJumper() then
		local plist = PointList()
		plist:push_back(t1)
		plist:push_back(p2)
		ret:AddLeap(plist, FULL_DELAY)
	elseif IsBurrower(target) then
		-- create a dummy unit to carry out
		-- burrow and unburrow animations.
		local id = target:GetId()
		local base = tData.Image
		local anim_burrow_psi = "lmn_psi_".. base
		local anim_burrow_psi_rev = "lmn_psi_".. base .."_rev"
		
		-- make a new burrow and unburrow animation,
		-- for every pawn type we come across
		-- to circumvent caching.
		if not ANIMS[anim_burrow_psi] then
			ANIMS[anim_burrow_psi] = ANIMS[base]
			ANIMS[anim_burrow_psi .."a"] = ANIMS[base .."e"]:new{}
			ANIMS[anim_burrow_psi_rev] = ANIMS[base]
			ANIMS[anim_burrow_psi_rev .."a"] = ANIMS[base .."e"]:new{}
			local anim = ANIMS[anim_burrow_psi .."a"]
			local anim_rev = ANIMS[anim_burrow_psi_rev .."a"]
			
			-- add slightly more time to animation
			-- to avoid invisible end frame.
			anim.Time = anim.Time + anim.Time / anim.NumFrames
			
			-- reverse frames.
			anim_rev.Frames = {}
			if anim.Frames then
				for i = #anim.Frames, 1, -1 do
					table.insert(anim_rev.Frames, anim.Frames[i])
				end
			else
				for i = anim.NumFrames - 1, 0, -1 do
					table.insert(anim_rev.Frames, i)
				end
			end
		end
		
		lmn_Burrow_Dummy.Health = tData.Health
		lmn_Burrow_Dummy.ImageOffset = tData.ImageOffset
		local health = target:GetHealth()
		local anim = ANIMS[anim_burrow_psi .."a"]
		
		ret:AddScript([[
			local p1 = ]].. t1:GetString() ..[[;
			Board:GetPawn(]].. id ..[[):SetSpace(Point(-1, -1));
			lmn_Burrow_Dummy.Image = ']].. anim_burrow_psi_rev ..[[';
			Board:AddPawn('lmn_Burrow_Dummy', p1);
			local dummy = Board:GetPawn(p1);
			dummy:SetHealth(]].. health .. [[);
		]])
		-- TODO: add support for .Lengths
		ret:AddDelay(anim.Time * anim.NumFrames)
		ret:AddScript([[
			local p1 = ]].. t1:GetString() ..[[;
			local p2 = ]].. p2:GetString() ..[[;
			if Board:IsAcid(p2) then
				Board:GetPawn(]].. id ..[[):SetAcid(true);
			end
			Board:RemovePawn(Board:GetPawn(p1));
			lmn_Burrow_Dummy.Image = ']].. anim_burrow_psi ..[[';
			Board:AddPawn('lmn_Burrow_Dummy', p2);
		]])
		ret:AddDelay(anim.Time * anim.NumFrames)
		ret:AddScript([[
			local p2 = ]].. p2:GetString() ..[[;
			local dummy = Board:GetPawn(p2);
			Board:GetPawn(]].. id ..[[):SetSpace(p2);
			Board:RemovePawn(dummy);
		]])
		
		-- preview movement.
		effectPreview:addMove(ret, target, p2)
		
	elseif target:IsTeleporter() then
		ret:AddTeleport(p1, p2, FULL_DELAY)
	else
		ret:AddMove(Board:GetPath(t1, p2, target:GetPathProf()), FULL_DELAY)
	end
	
	return ret
end

lmn_Psionic_Transmitter_A = lmn_Psionic_Transmitter:new{
	UpgradeDescription = "Allows transmitting through obstacles.",
	Pierce = true,
	CustomTipImage = "lmn_Psionic_Transmitter_Tip_A",
	TipImage = {
		Unit = Point(2,2),
		Building = Point(2,1),
		Enemy = Point(2,0),
		Enemy2 = Point(3,2),
		Target = Point(3,1),
		CustomEnemy = "Leaper1"
	},
}

lmn_Psionic_Transmitter_Tip = lmn_Psionic_Transmitter:new{}
lmn_Psionic_Transmitter_Tip_A = lmn_Psionic_Transmitter_A:new{}

function lmn_Psionic_Transmitter_Tip:GetSkillEffect(p1, p2)
	local enemy = Board:GetPawn(self.TipImage.Enemy)
	local enemy2 = Board:GetPawn(self.TipImage.Enemy2)
	enemy:FireWeapon(Point(self.TipImage.Enemy.x, self.TipImage.Enemy.y + 1), 1)
	enemy2:FireWeapon(Point(self.TipImage.Enemy2.x - 1, self.TipImage.Enemy2.y), 1)
	
	local ret = lmn_Psionic_Transmitter.GetSkillEffect(self, p1, p2)
	ret:AddDelay(1)
	
	return ret
end

lmn_Psionic_Transmitter_Tip_A.GetSkillEffect = lmn_Psionic_Transmitter_Tip.GetSkillEffect

modApi:addWeaponDrop("lmn_Psionic_Transmitter")

modApi:appendAsset("img/weapons/lmn_psionic_transmitter.png", mod.resourcePath.. "img/weapons/psionic_transmitter.png")

modApi:copyAsset("img/combat/square.png", "img/combat/lmn_square.png")
Location["combat/lmn_square.png"] = Point(-27, 2)

modApi:appendAsset("img/combat/icons/lmn_psi_icon_move_glow.png", mod.resourcePath .."img/combat/icons/icon_move_glow.png")
Location["combat/icons/lmn_psi_icon_move_glow.png"] = Point(-13, 13)

modApi:appendAsset("img/combat/lmn_psi_arrow_y_0.png", mod.resourcePath .."img/combat/projectile_arrow_02.png")
modApi:appendAsset("img/combat/lmn_psi_arrow_y_1.png", mod.resourcePath .."img/combat/projectile_arrow_13.png")
modApi:appendAsset("img/combat/lmn_psi_arrow_y_2.png", mod.resourcePath .."img/combat/projectile_arrow_02.png")
modApi:appendAsset("img/combat/lmn_psi_arrow_y_3.png", mod.resourcePath .."img/combat/projectile_arrow_13.png")
modApi:appendAsset("img/combat/lmn_psi_close_y_0.png", mod.resourcePath .."img/combat/projectile_close_02.png")
modApi:appendAsset("img/combat/lmn_psi_close_y_1.png", mod.resourcePath .."img/combat/projectile_close_13.png")
modApi:appendAsset("img/combat/lmn_psi_close_y_2.png", mod.resourcePath .."img/combat/projectile_close_02.png")
modApi:appendAsset("img/combat/lmn_psi_close_y_3.png", mod.resourcePath .."img/combat/projectile_close_13.png")

Location["combat/lmn_psi_arrow_y_0.png"] = Point(-16, 0)
Location["combat/lmn_psi_arrow_y_1.png"] = Point(-16, 0)
Location["combat/lmn_psi_arrow_y_2.png"] = Point(-16, 0)
Location["combat/lmn_psi_arrow_y_3.png"] = Point(-16, 0)
Location["combat/lmn_psi_close_y_0.png"] = Point(-27, 15)
Location["combat/lmn_psi_close_y_1.png"] = Point(-28, -6)
Location["combat/lmn_psi_close_y_2.png"] = Point(1, -6)
Location["combat/lmn_psi_close_y_3.png"] = Point(0, 15)

modApi:appendAsset("img/effects/smoke/lmn_psi_smoke.png", mod.resourcePath .."img/effects/smoke/psi_smoke.png")

-- angles matching the board directions,
-- with variance going an equal amount to either side.
local angle_variance = 10
local angle_0 = 323 + angle_variance / 2
local angle_1 = 37 + angle_variance / 2
local angle_2 = 142 + angle_variance / 2
local angle_3 = 218 + angle_variance / 2

lmn_Emitter_Psi_Stun_0 = Emitter:new{
	image = "effects/smoke/lmn_psi_smoke.png",
	max_alpha = 0.4,
	x = 0,
	y = 10,
	variance = 0,
	variance_x = 20,
	variance_y = 5,
	lifespan = 0.55,
	speed = 1.5,
	burst_count = 20,
	rot_speed = 360,
	gravity = false,
	layer = LAYER_FRONT,
	angle = angle_0,
	angle_variance = angle_variance,
}

lmn_Emitter_Psi_Stun_1 = lmn_Emitter_Psi_Stun_0:new{
	angle = angle_1,
	angle_variance = angle_variance,
}

lmn_Emitter_Psi_Stun_2 = lmn_Emitter_Psi_Stun_0:new{
	angle = angle_2,
	angle_variance = angle_variance,
}

lmn_Emitter_Psi_Stun_3 = lmn_Emitter_Psi_Stun_0:new{
	angle = angle_3,
	angle_variance = angle_variance,
}

lmn_Emitter_Psi_Stun_Static_0 = lmn_Emitter_Psi_Stun_0:new{
	y = 15,
	angle = 270 - angle_variance / 2,
	burst_count = 3,
}

lmn_Emitter_Psi_Stun_Static_1 = lmn_Emitter_Psi_Stun_Static_0:new{}
lmn_Emitter_Psi_Stun_Static_2 = lmn_Emitter_Psi_Stun_Static_0:new{}
lmn_Emitter_Psi_Stun_Static_3 = lmn_Emitter_Psi_Stun_Static_0:new{}

ANIMS.lmn_Psi_Stun = ANIMS.Animation:new{ 	
	Image = "combat/icons/stun_strip5.png",
	PosX = -8, PosY = -3,
	NumFrames = 5,
	Time = 0.1,
	Frames = {0,1,2,3,4,0,1},
}

ANIMS.lmn_Psi_Radio = ANIMS.Animation:new{
	Image = "combat/icons/radio_animate.png",
	PosX = -16, PosY = -8,
	NumFrames = 3,
	Time = 0.2,
	Frames = {0,1,2,0,1,2},
}

modApi.events.onMissionUpdate:subscribe(function()
	local rem = {}
	
	weapons = weapons or {}
	for id, v in pairs(weapons) do
		if not selected or v.weaponId ~= selected:GetArmedWeaponId() then
			v.weapon.Target = nil
			table.insert(rem, id)
		end
		
		if v.weapon.Target then
			local p1 = Board:GetPawn(id):GetSpace()
			local p2 = v.weapon.Target:GetSpace()
			local dir = GetDirection(p2 - p1)
			local distance = p1:Manhattan(p2)
			
			if distance == 1 then
				local d = SpaceDamage(p2)
				d.sImageMark = "combat/lmn_psi_close_y_".. dir ..".png"
				Board:MarkSpaceDamage(d)
			else
				for k = 1, distance - 1 do
					local curr = p1 + DIR_VECTORS[dir] * k
					local d = SpaceDamage(curr)
					d.sImageMark = "combat/lmn_psi_arrow_y_".. dir ..".png"
					Board:MarkSpaceDamage(d)
				end
			end
		end
	end
	
	for _, id in ipairs(rem) do
		weapons[id] = nil
	end
end)
	
modApi.events.onTestMechEntered:subscribe(function()
	modApi:runLater(function()
		for id = 0, 2 do
			selected = Board:GetPawn(id)
			if selected then
				break
			end
		end
	end)
end)

modApi.events.onGameExited:subscribe(function()
	weapons = {}
	highlighted = nil
	selected = nil
end)

modApi.events.onTestMechExited:subscribe(function()
	weapons = {}
	highlighted = nil
	selected = nil
end)

modApi.events.onMissionEnd:subscribe(function()
	weapons = {}
	highlighted = nil
	selected = nil
end)

local function onModsLoaded()
	modApiExt:addPawnSelectedHook(function(_, pawn)
		selected = pawn
	end)
	
	modApiExt:addPawnDeselectedHook(function()
		if selected then
			weapons = weapons or {}
			weapons[selected:GetId()] = nil
		end
		
		selected = nil
	end)
	
	modApiExt:addTileHighlightedHook(function(_, tile)
		highlighted = tile
	end)
	
	modApiExt:addTileUnhighlightedHook(function()
		highlighted = nil
	end)
end

modApi.events.onModsLoaded:subscribe(onModsLoaded)

lmn_Burrow_Dummy = Pawn:new{
	Name = "",
	Health = 1,
	Neutral = true,
	Flying = true,
	MoveSpeed = 0,
	IsPortrait = false,
	Image = "burrowere",
	ImageOffset = 2,
	SoundLocation = "",
	DefaultTeam = TEAM_NONE,
}
