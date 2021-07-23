
---------------------------------------------------------------------
-- Multishot v1.0 - code library
--[[-----------------------------------------------------------------
	provides function to aquire maximum number of repeated attacks
	against the same tile without changing the board state.
	
	example use:
	
	local path = mod_loader.mods[modApi.currentMod].scriptPath
	local multishot = require(path .."multishot")
	
	local maxAttacks = 3
	local attacks = math.min(maxAttacks, multishot:GetMaxAttacks(Point(0,0), 1, false)
]]

local path = mod_loader.mods[modApi.currentMod].scriptPath
local armorDetection = require(path .."armorDetection")
local this = {}

function this:GetMaxAttacks(loc, damage, isPush, isTipImage)
	if isPush then
		local pawn = Board:GetPawn(loc)
		if
			(pawn and pawn:IsGuarding())				or
			not Board:IsBlocked(loc, PATH_PROJECTILE)	or
			Board:IsUniqueBuilding(loc)
		then
			return INT_MAX
		end
		
		return 1
	else
		local pawn = Board:GetPawn(loc)
		
		if pawn then
			local health = pawn:GetHealth()
			if health > 0 then
				-- caluclate pawn effective health.
				-- TODO: account for multishot weapons using acid on first shot?
				if pawn:IsAcid() then
					health = math.ceil(health / 2)
				elseif armorDetection.IsArmor(pawn) then
					damage = damage - 1
				end
				
				if pawn:IsShield() then health = health + 1 end
				if pawn:IsFrozen() then health = health + 1 end
				
				if Board:GetTerrain(loc) == TERRAIN_ICE then
					-- only shoot until ice breaks.
					-- TODO: account for flying pawns?
					local tileHealth = tileHealth:Get(loc, isTipImage)
					return math.max(1, tileHealth)
				else
					-- caluculate damage until pawn is dead.
					if damage > 0 then
						return health / damage
					else
						return INT_MAX
					end
				end
			end
			
			-- unload shots into dead pawns.
			return INT_MAX
			
		elseif not Board:IsBlocked(loc, PATH_PROJECTILE) then
			-- unload shots on empty tiles.
			return INT_MAX
			
		elseif Board:IsUniqueBuilding(loc) then
			-- unload shots on buildings that cannot be removed.
			return INT_MAX
			
		else
			-- shot is blocked by something. Calculate max damage.
			local terrain = Board:GetTerrain(loc)
			local health = tileHealth:Get(loc, isTipImage)
			
			if Board:IsFrozen(loc) then
				if terrain == TERRAIN_MOUNTAIN then
					return health + 1
				elseif terrain == TERRAIN_BUILDING then
					-- frozen + 1 safe shot against buildings.
					return 2
				end
			end
			
			return health
		end
	
	end
end

-- custom GetProjectileEnd, for multishot purposes.
function this:GetProjectileEnd(p1, p2)
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

return this