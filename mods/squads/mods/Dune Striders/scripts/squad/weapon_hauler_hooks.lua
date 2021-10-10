
local mod = mod_loader.mods[modApi.currentMod]
local utils = require(mod.scriptPath .."libs/utils")
local effectPreview = LApi.library:fetch("effectPreview")
local effectBurst = LApi.library:fetch("effectBurst")
local worldConstants = LApi.library:fetch("worldConstants")

modApi:copyAsset("img/combat/icons/icon_postmove_glow.png", "img/combat/icons/lmn_ds_icon_bonus_move_glow.png")
modApi:appendAsset("img/effects/lmn_ds_bonus_move.png", mod.resourcePath .."img/effects/bonus_move.png")

Location["combat/icons/lmn_ds_icon_bonus_move_glow.png"] = Point(-13,-2)

local t = .10
local q = t/4
ANIMS.lmn_ds_bonus_move = ANIMS.Animation:new{
	Image = "effects/lmn_ds_bonus_move.png",
	PosX = -9,
	PosY = -15,
	NumFrames = 13,
	Lengths = {
		t,t,t,t,t,
		q,q,q,q,
		q,q,q,q
	},
	Sound = "enemy/shared/robot_power_on"
}

lmn_ds_HaulerHooks = Skill:new{
	Name = "Hauler Hooks",
	Description = "Move in a line, and haul any units behind you along.",
	Icon = "weapons/lmn_ds_hauler_hooks.png",
	Class = "Science",
	PowerCost = 2,
	Range = INT_MAX,
	Crash = false,
	MoveSpeedAsRange = false,
	MoveSpeedMinimum = nil,
	RefreshMovement = false,
	Upgrades = 1,
	UpgradeList = { "Refresh Movement" },
	UpgradeCost = { 2 },
	TipImage = {
		Unit = Point(3,2),
		Target = Point(3,1),
		Second_Origin = Point(3,1),
		Second_Target = Point(0,1),
		Friendly1 = Point(3,3),
		Enemy1 = Point(2,1),
	}
}

lmn_ds_HaulerHooks_A = lmn_ds_HaulerHooks:new{
	UpgradeDescription = "Refresh movement on hauled units, if they have not attacked yet.",
	RefreshMovement = true
}

local function canRefreshMovement(pawn)
	if utils.IsTipImage() then
		return true
	end
	
	return pawn:IsActive() and not pawn:IsMovementAvailable()
end

function lmn_ds_HaulerHooks:GetTargetArea(point)
	local ret = PointList()
	local pathing = Pawn:GetPathProf()
	local range = self.MoveSpeedAsRange and Pawn:GetMoveSpeed() or self.Range
	
	if self.MoveSpeedMinimum and range == 0 then
		range = self.MoveSpeedMinimum
	end
	
	for dir = DIR_START, DIR_END do
		for k = 1, range do
			local curr = point + DIR_VECTORS[dir] * k
			
			if not Board:IsValid(curr) then
				break
			end
			
			if not Board:IsBlocked(curr, pathing) then
				ret:push_back(curr)
				
			elseif not utils.IsTilePassable(curr, pathing) then
				break
			end
		end
	end
	
	return ret
end

function lmn_ds_HaulerHooks:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local distance = p1:Manhattan(p2)
	local dir = GetDirection(p2 - p1)
	local pawns = {}
	local dests = {}
	local currentPawn
	
	-- create a list of pawns to haul: {pawn, from, to}
	for k = -1, distance - 1 do
		local curr = p1 + DIR_VECTORS[dir] * k
		
		if Board:IsValid(curr) then
			local pawn = Board:GetPawn(curr)
			
			if curr ~= p1 and pawn then
				if not pawn:IsGuarding() then
					local team = pawn:GetTeam()
					currentPawn = { pawn = pawn, team = team, from = curr }
					pawns[k] = currentPawn
				else
					currentPawn = nil
				end
				
			elseif currentPawn then
				local terrain = Board:GetTerrain(curr)
				
				if utils.IsTerrainPathable(terrain, PATH_FLYER) then
					currentPawn.to = curr
					currentPawn.distance = k
				end
				
				if not utils.IsTerrainPathable(terrain, currentPawn.pawn:GetPathProf()) then
					currentPawn = nil
				end
			end
		end
	end
	
	
	local velocity = 0.4
	
	-- move pawns according to the list we made previously
	for k = -2, distance - 1 do
		local curr = p1 + DIR_VECTORS[dir] * k
		
		local draggedPawn = pawns[k]
		local passedPawn = pawns[k+1]
		
		if passedPawn and passedPawn.to then
			ret:AddSound("weapons/grapple")
			ret:AddSound("impact/generic/grapple")
		end
		
		if draggedPawn and draggedPawn.to then
			
			if self.RefreshMovement and canRefreshMovement(draggedPawn.pawn) then
				if draggedPawn.team == TEAM_PLAYER then
					local bonusMove = SpaceDamage(draggedPawn.to)
					bonusMove.sImageMark = "combat/icons/lmn_ds_icon_bonus_move_glow.png"
					ret:AddDamage(bonusMove)
				end
			end
			
			worldConstants:setSpeed(ret, velocity)
			ret:AddCharge(Board:GetPath(draggedPawn.from, draggedPawn.to, PATH_FLYER), NO_DELAY)
			worldConstants:resetSpeed(ret)
			
			dests[draggedPawn.distance] = draggedPawn
		end
		
		local arrivingPawn = dests[k]
		
		if arrivingPawn then
			if self.Crash then
				if k < distance - 1 and arrivingPawn.to then
					ret:AddDamage(SpaceDamage(arrivingPawn.to, 0, dir))
				end
			end
			
			if self.RefreshMovement and canRefreshMovement(arrivingPawn.pawn) then
				if arrivingPawn.team == TEAM_PLAYER then
					ret:AddScript(string.format([[
						local pawn = Board:GetPawn(%s);
						local p = pawn:GetSpace();
						pawn:SetMovementAvailable(true);
						Board:Ping(p, GL_Color(100,255,100));
						Board:AddAnimation(p, "lmn_ds_bonus_move", ANIM_DELAY);
					]], arrivingPawn.pawn:GetId()))
				end
			end
		end
		
		ret:AddDelay(0.08 * worldConstants:getDefaultSpeed() / velocity)
		
		if k == -2 then
			worldConstants:setSpeed(ret, velocity)
			ret:AddSound("/enemy/shared/moved")
			ret:AddCharge(Board:GetPath(p1, p2, Pawn:GetPathProf()), NO_DELAY)
			worldConstants:resetSpeed(ret)
		else
			effectBurst.Add(ret, curr + DIR_VECTORS[dir], "lmn_ds_Emitter_Wind_".. dir, DIR_NONE)
		end
	end
	
	-- weapon preview looks better if we end with the main charge
	effectPreview:addCharge(ret, p1, p2, Pawn:GetPathProf())
	
	return ret
end
