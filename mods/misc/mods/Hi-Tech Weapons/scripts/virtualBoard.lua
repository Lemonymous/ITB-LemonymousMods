
---------------------------------------------------------------------
-- Virtual Board v1.1 - code library
---------------------------------------------------------------------
-- provides functions allowing you to modify board state
-- in a virtual space. the virtual board is lazily initialized,
-- meaning it pulls states directly from Board when no virtual state
-- is found.
--
-- this library is a WIP. It tries to simulate everything correctly,
-- but some manual help may be needed when using it.
--
-- if there are additions you can think of, feel free to make
-- suggestions in #modding-discussion in the ITB discord.
--
-- requires libraries modApiExt, armorDetection and markDamage,
-- and icons found in /img/virtualBoard/
--
--        ------------------------------------------------
--
--
-- the system is intended to be used to play out the effects of
-- a weapon or effect in an instant, and then be able to
-- check what the board state would look like afterwards.
--
-- due to this, any usage of the virtual board requires the
-- actual board state to stay static.
--
--
---------------------------------------------------------------------


-------------------------------------------------------------------
-- initialization and loading:
--[[---------------------------------------------------------------

	-- in init.lua - function load:
	local virtualBoard = require(self.scriptPath ..'virtualBoard')
	virtualBoard.load(modApiExt, armorDetection, markDamage)
	
	
	-- after you have loaded it,
	-- you can request it again in your weapons with:
	local virtualBoard = require(mod.scriptPath ..'virtualBoard')

]]-----------------------------------------------------------------


------------------
-- function list:
------------------

----------------------------
-- virtualBoard.new()
----------------------------
-- requests a new vBoard
-- for current Board state.
----------------------------

------------------------------------------
-- vBoard:DamagePawn(pawnId, spaceDamage)
------------------------------------------
-- applies damage to a pawn's location.
------------------------------------------

-----------------------------------
-- vBoard:DamageSpace(spaceDamage)
-----------------------------------
-- applies damage to a tile
-----------------------------------

------------------------------------------------------------
-- vBoard:MarkDamage(effect, pawnId, weapon)
------------------------------------------------------------
-- marks the board (but not tipImage) with all the damage
-- you've applied to the vBoard.
--
-- arg    - type        - description
-- ------   -----------   ----------------------------------
-- effect - SkillEffect - effect object applying the marks.
-- pawnId - number      - id of the pawn using the weapon.
-- weapon - string      - type name of the weapon used.
------------------------------------------------------------

-------------------------------------
-- vBoard:GetPawnState(pawnId)
-------------------------------------
-- gets the virtual state of a pawn.
-- lazily initialized.
-------------------------------------

-------------------------------------
-- vBoard:GetTileState(tile)
-------------------------------------
-- gets the virtual state of a tile.
-- lazily initialized.
-------------------------------------

-------------------------------------
-- vBoard:GetPawn(input)
-------------------------------------
-- gets a pawn by either tile or id.
-------------------------------------

------------------------------------
-- vBoard:IsFrozen(pawnId)
------------------------------------
-- gets the frozen state of a pawn.
------------------------------------

------------------------------------
-- vBoard:IsShield(pawnId)
------------------------------------
-- gets the shield state of a pawn.
------------------------------------

----------------------------------
-- vBoard:IsAcid(pawnId)
----------------------------------
-- gets the acid state of a pawn.
----------------------------------

-----------------------------------
-- vBoard:IsArmor(pawnId)
-----------------------------------
-- gets the armor state of a pawn.
-----------------------------------

----------------------------------------
-- vBoard:SetFrozen(pawnId, flag)
----------------------------------------
-- sets the frozen state of a pawn.
----------------------------------------

----------------------------------------
-- vBoard:SetShield(pawnId, flag)
----------------------------------------
-- sets the shield state of a pawn.
----------------------------------------

--------------------------------------
-- vBoard:SetAcid(pawnId, flag)
--------------------------------------
-- sets the acid state of a pawn.
--------------------------------------

---------------------------------------
-- vBoard:SetArmor(pawnId, flag)
---------------------------------------
-- sets the armor state of a pawn.
---------------------------------------

--------------------------------------
-- vBoard:GetPawnHealth(pawnId)
--------------------------------------
-- gets the health of a pawn.
--------------------------------------

----------------------------------------------
-- vBoard:SetPawnHealth(pawnId, health)
----------------------------------------------
-- sets the health of a pawn.
----------------------------------------------

----------------------------------------------
-- vBoard:AddPawnHealth(pawnId, amount)
----------------------------------------------
-- adds health to a pawn.
----------------------------------------------

----------------------------------------------
-- vBoard:SubPawnHealth(pawnId, amount)
----------------------------------------------
-- subtracts health from a pawn.
----------------------------------------------

-------------------------------------------
-- vBoard:SetPawnSpace(pawnId, tile)
-------------------------------------------
-- sets the position of a pawn.
-------------------------------------------

------------------------------------------------
-- vBoard:SwapPawnSpace(pawnId1, pawnId2)
------------------------------------------------
-- swaps the position of two pawns.
------------------------------------------------

------------------------------------
-- vBoard:GetTileHealth(tile)
------------------------------------
-- gets the health of a tile.
-- Test Mech Scenario: initializes
-- as 1 for buildings and mountains
------------------------------------

--------------------------------------------
-- vBoard:SetTileHealth(tile, health)
--------------------------------------------
-- sets the health of a tile.
--------------------------------------------

--------------------------------------------
-- vBoard:AddTileHealth(tile, amount)
--------------------------------------------
-- adds to the health of a tile.
--------------------------------------------

--------------------------------------------
-- vBoard:SubTileHealth(tile, amount)
--------------------------------------------
-- subtracts from the health of a tile.
--------------------------------------------

---------------------------------
-- vBoard:GetTerrain(tile)
---------------------------------
-- gets the terrain of a tile.
---------------------------------

------------------------------------------
-- vBoard:SetTerrain(tile, terrain)
------------------------------------------
-- sets the terrain of a tile.
------------------------------------------

--------------------------------------
-- vBoard:BumpPawn(pawnId, damage)
--------------------------------------
-- deals unmodified damage to a pawn.
--------------------------------------

------------------------------------
-- vBoard:BumpTile(tile, damage)
------------------------------------
-- deals bump damage to a tile.
-- affects mountains and buildings.
------------------------------------

------------------------------------
-- vBoard:IsBlocked(tile)
------------------------------------
-- returns true if tile is blocked
-- by a pawn, building or mountain.
------------------------------------

----------------------------------------------------------------
----------------------------------------------------------------


local this = {
	pawns = {},	-- private table of pawnStates, indexed by pawnId
	tiles = {},	-- private table of tileStates, indexed by tileId
}

local function IsMassive(pawn)
	return _G[pawn:GetType()]:GetMassive()
end

local function HasCorpse(pawn)
	return pawn:IsMech() or _G[pawn:GetType()]:GetCorpse()
end

local function HasForceAmp()
	-- only applicable for TEAM_MECH
	pawns = extract_table(Board:GetPawns(TEAM_MECH))
	for _, id in ipairs(pawns) do
		if this.armorDetection.HasPoweredPassive(Board:GetPawn(id), "Passive_ForceAmp") then
			return true
		end
	end
	return false
end

-- gets the virtual state of a pawn.
-- lazily initialized.
function this:GetPawnState(pawnId)
	
	-- if tile is given as input, return the
	-- pawnState of the pawn on the tile.
	if type(pawnId) == 'userdata' then
		local tile = pawnId
		local tileState = self:GetTileState(tile)
		
		if tileState.pawn then
			return self:GetPawnState(tileState.pawn:GetId())
		end
		
		return nil
	end
	
	if self.pawns[pawnId] then
		return self.pawns[pawnId]
	end
	
	-- initialize pawnState.
	local pawnState = {}
	self.pawns[pawnId] = pawnState
	
	local pawn = Board:GetPawn(pawnId)
	
	pawnState.pawn = pawn
	pawnState.id = pawn:GetId()
	pawnState.loc = pawn:GetSpace()
	pawnState.health = pawn:GetHealth()
	pawnState.isFrozen = pawn:IsFrozen()
	pawnState.isShield = pawn:IsShield()
	pawnState.isAcid = pawn:IsAcid()
	pawnState.isArmor = this.armorDetection.IsArmor(pawn)
	pawnState.isKilled = false
	
	pawnState.damage = 0
	pawnState.blocked = 0
	
	return pawnState
end

-- gets the virtual state of a tile.
-- lazily initialized.
function this:GetTileState(tile)
	assert(type(tile) == 'userdata')
	assert(type(tile.x) == 'number')
	assert(type(tile.y) == 'number')
	
	-- assert that tile is valid
	local size = Board:GetSize()
	assert(
		tile.x >= 0     and
		tile.y >= 0     and
		tile.x < size.x and
	    tile.y < size.y
	)
	
	local tileId = p2idx(tile)
	if self.tiles[tileId] then
		return self.tiles[tileId]
	end
	
	-- initialize tileState.
	local tileState = {}
	self.tiles[tileId] = tileState
	
	tileState.loc = tile
	tileState.pawn = Board:GetPawn(tile)
	tileState.terrain = Board:GetTerrain(tile)
	tileState.isFrozen = Board:IsFrozen(tile)
	tileState.isShield = false -- TODO?
	tileState.isAcid = Board:IsAcid(tile)
	
	tileState.damage = 0
	tileState.damagePawn = 0
	tileState.blocked = 0
	tileState.pushList = {
		{dir = DIR_UP,    count = 0},
		{dir = DIR_RIGHT, count = 0},
		{dir = DIR_DOWN,  count = 0},
		{dir = DIR_LEFT,  count = 0}
	}
	tileState.corpses = {}
	
	function tileState:GetPushDir()
		local list = shallow_copy(self.pushList)
		table.sort(list, function(a,b) return a.count > b.count end)
		return list[1].count > 0 and list[1].dir or DIR_NONE
	end
	
	if not IsTestMechScenario() and this.modApiExt then
		local tileHealth = this.modApiExt.board:getTileHealth(tile)
		assert(type(tileHealth) == 'number')
		
		tileState.health = tileHealth
	elseif
		tileState.terrain == TERRAIN_BUILDING or
		tileState.terrain == TERRAIN_MOUNTAIN or
		tileState.terrain == TERRAIN_ICE
	then
		tileState.health = 2 -- no way to know unless we tracked it somehow.
	else
		tileState.health = 0
	end
	
	if tileState.pawn then
		self:GetPawnState(tileState.pawn:GetId())
	end
	
	return tileState
end

-- gets a pawn by either tile or id.
function this:GetPawn(input)
	if type(input) == 'number' then
		local pawnId = input
		local pawnState = self:GetPawnState(pawnId)
		
		return pawnState.pawn
	end
	
	local tile = input
	local tileId = p2idx(tile)
	local tileState = self:GetTileState(tile)
	
	return tileState.pawn
end

-- gets the frozen state of a pawn.
function this:IsFrozen(pawnId)
	assert(type(pawnId) == 'number')
	
	return self:GetPawnState(pawnId).isFrozen
end

-- gets the shield state of a pawn.
function this:IsShield(pawnId)
	assert(type(pawnId) == 'number')
	
	return self:GetPawnState(pawnId).isShield
end

-- gets the acid state of a pawn.
function this:IsAcid(pawnId)
	assert(type(pawnId) == 'number')
	
	return self:GetPawnState(pawnId).isAcid
end

-- gets the armor state of a pawn.
function this:IsArmor(pawnId)
	assert(type(pawnId) == 'number')
	
	return self:GetPawnState(pawnId).isArmor
end

-- sets the frozen state of a pawn.
function this:SetFrozen(pawnId, flag)
	assert(type(pawnId) == 'number')
	assert(type(flag) == 'boolean')
	
	self:GetPawnState(pawnId).isFrozen = flag
end

-- sets the shield state of a pawn.
function this:SetShield(pawnId, flag)
	assert(type(pawnId) == 'number')
	assert(type(flag) == 'boolean')
	
	self:GetPawnState(pawnId).isShield = flag
end

-- sets the acid state of a pawn.
function this:SetAcid(pawnId, flag)
	assert(type(pawnId) == 'number')
	assert(type(flag) == 'boolean')
	
	self:GetPawnState(pawnId).isAcid = flag
end

-- sets the armor state of a pawn.
function this:SetArmor(pawnId, flag)
	assert(type(pawnId) == 'number')
	assert(type(flag) == 'boolean')
	
	self:GetPawnState(pawnId).isArmor = flag
end

-- gets the health of a pawn.
function this:GetPawnHealth(pawnId)
	assert(type(pawnId) == 'number')
	
	return self:GetPawnState(pawnId).health
end

-- sets the health of a pawn.
function this:SetPawnHealth(pawnId, health)
	assert(type(pawnId) == 'number')
	assert(type(health) == 'number')
	
	local pawnState = self:GetPawnState(pawnId)
	pawnState.health = math.max(0, health)
	
	if pawnState.health <= 0 and not pawnState.isKilled then
		pawnState.isKilled = true
		local tileState = self:GetTileState(pawnState.loc)
		
		-- remove dead corpseless pawns from tile.
		if not HasCorpse(pawnState.pawn) then
			if pawnState.isAcid then
				tileState.isAcid = true
			end
			
			if
				tileState.terrain ~= TERRAIN_WATER and
				tileState.terrain ~= TERRAIN_HOLE
			then
				table.insert(tileState.corpses, pawnState.id)
			end
			
			tileState.pawn = nil
		end
		
	elseif pawnState.health > 0 and pawnState.isKilled then
		pawnState.isKilled = false
	end
end

-- adds health to a pawn.
function this:AddPawnHealth(pawnId, amount)
	assert(type(pawnId) == 'number')
	assert(type(amount) == 'number')
	
	self:SetPawnHealth(pawnId, self:GetPawnHealth(pawnId) + amount)
end

-- subtracts health from a pawn.
function this:SubPawnHealth(pawnId, amount)
	assert(type(pawnId) == 'number')
	assert(type(amount) == 'number')
	
	self:AddPawnHealth(pawnId, -amount)
end

-- sets the position of a pawn.
function this:SetPawnSpace(pawnId, tile)
	assert(type(pawnId) == 'number')
	assert(type(tile) == 'userdata')
	assert(type(tile.x) == 'number')
	assert(type(tile.y) == 'number')
	
	local pawnState = self:GetPawnState(pawnId)
	local tileState = self:GetTileState(tile)
	
	-- ignore dead corpseless pawns.
	local pawn = Board:GetPawn(pawnId)
	if pawnState.health <= 0 and not HasCorpse(pawn) then
		return
	end
	
	-- assert that destination tile is clear.
	assert(tileState.pawn == nil)
	assert(tileState.terrain ~= TERRAIN_BUILDING)
	assert(tileState.terrain ~= TERRAIN_MOUNTAIN)
	
	self:GetTileState(pawnState.loc).pawn = nil	-- clear old tile
	pawnState.loc = tile						-- set pawn loc
	tileState.pawn = pawnState.pawn				-- set tile pawn
	
	if tileState.terrain == TERRAIN_WATER then
		-- test if pawn will drown at destination.
		self:SetTerrain(tile, TERRAIN_WATER)
	end
	
	-- apply acid if at destination.
	if tileState.isAcid then
		pawnState.isAcid = true
		-- acid water stays acid.
		if tileState.terrain ~= TERRAIN_WATER then
			tileState.isAcid = false
		end
	end
end

-- swaps the position of two pawns.
function this:SwapPawnSpace(pawnId1, pawnId2)
	assert(type(pawnId1) == 'number')
	assert(type(pawnId2) == 'number')
	
	local pawnState1 = self:GetPawnState(pawnId1)
	local pawnState2 = self:GetPawnState(pawnId2)
	
	-- assert pawns are alive or corpse.
	assert(pawnState1.health > 0 or HasCorpse(pawnState1.pawn))
	assert(pawnState2.health > 0 or HasCorpse(pawnState2.pawn))
	
	local tileState1 = self:GetTileState(pawnState1.loc)
	local tileState2 = self:GetTileState(pawnState2.loc)
	tileState1.pawn = pawnState2.pawn
	tileState2.pawn = pawnState1.pawn
	
	local swap = pawnState1.loc
	pawnState1.loc = pawnState2.loc
	pawnState2.loc = swap
	
	-- test if pawns will drown at swapped positions.
	if tileState1.terrain == TERRAIN_WATER then
		self:SetTerrain(pawnState2.loc, TERRAIN_WATER)
	end
	
	if tileState2.terrain == TERRAIN_WATER then
		self:SetTerrain(pawnState1.loc, TERRAIN_WATER)
	end
end

-- gets the health of a tile.
function this:GetTileHealth(tile)
	assert(type(tile) == 'userdata')
	assert(type(tile.x) == 'number')
	assert(type(tile.y) == 'number')
	
	return self:GetTileState(tile).health
end

-- sets the health of a tile.
function this:SetTileHealth(tile, health)
	assert(type(tile) == 'userdata')
	assert(type(tile.x) == 'number')
	assert(type(tile.y) == 'number')
	assert(type(health) == 'number')
	
	local tileState = self:GetTileState(tile)
	tileState.health = math.max(0, health)
	
	if tileState.health <= 0 then
		if
			not Board:IsUniqueBuilding(tile)		and
			(tileState.terrain == TERRAIN_BUILDING	or
			tileState.terrain == TERRAIN_MOUNTAIN)
		then
			tileState.terrain = TERRAIN_RUBBLE
			
		elseif tileState.terrain == TERRAIN_ICE then
			self:SetTerrain(tile, TERRAIN_WATER)
		end
	end
end

-- adds to the health of a tile.
function this:AddTileHealth(tile, amount)
	assert(type(tile) == 'userdata')
	assert(type(tile.x) == 'number')
	assert(type(tile.y) == 'number')
	assert(type(amount) == 'number')
	
	self:SetTileHealth(tile, self:GetTileHealth(tile) + amount)
end

-- subtracts from the health of a tile.
function this:SubTileHealth(tile, amount)
	assert(type(tile) == 'userdata')
	assert(type(tile.x) == 'number')
	assert(type(tile.y) == 'number')
	assert(type(amount) == 'number')
	
	self:AddTileHealth(tile, -amount)
end

-- gets the terrain of a tile.
function this:GetTerrain(tile)
	assert(type(tile) == 'userdata')
	assert(type(tile.x) == 'number')
	assert(type(tile.y) == 'number')
	
	return self:GetTileState(tile).terrain
end

-- sets the terrain of a tile.
function this:SetTerrain(tile, terrain)
	assert(type(tile) == 'userdata')
	assert(type(tile.x) == 'number')
	assert(type(tile.y) == 'number')
	assert(type(terrain) == 'number')
	
	local tileState = self:GetTileState(tile)
	tileState.terrain = terrain
	
	-- check if pawn will drown, or fall.
	local pawn = tileState.pawn
	if pawn then
		local pawnState = self:GetPawnState(pawn:GetId())
		local survivesPits = pawn:IsFlying() and not pawnState.isFrozen
		local survivesWater = IsMassive(pawn) or survivesPits
		
		if
			tileState.terrain == TERRAIN_WATER and not survivesWater or
			tileState.terrain == TERRAIN_HOLE and not survivesPits
		then
			self:SetPawnHealth(pawnState.id, 0)
			tileState.corpses = {}
		end
	end
end

-- applies a spaceDamage object to a pawn.
function this:DamagePawn(pawnId, spaceDamage)
	assert(type(pawnId) == 'number')
	assert(type(spaceDamage) == 'userdata')
	assert(type(spaceDamage.loc.x) == 'number')
	assert(type(spaceDamage.loc.y) == 'number')
	
	local pawnState = self:GetPawnState(pawnId)
	
	spaceDamage.loc = pawnState.loc
	self:DamageSpace(spaceDamage)
end

function this:BumpPawn(pawnId, damage)
	assert(type(pawnId) == 'number')
	assert(type(damage) == 'number')
	
	local pawnState = self:GetPawnState(pawnId)
	
	if pawnState.isShield then
		pawnState.isShield = false
	elseif pawnState.isFrozen then
		pawnState.isFrozen = false
	else
		self:SubPawnHealth(pawnId, damage)
	end
end

function this:BumpTile(tile, damage)
	assert(type(tile) == 'userdata')
	assert(type(tile.x) == 'number')
	assert(type(tile.y) == 'number')
	assert(type(damage) == 'number')
	
	local tileState = self:GetTileState(tile)
	
	if tileState.isShield then
		tileState.isShield = false
	elseif tileState.isFrozen then
		tileState.isFrozen = false
	elseif
		tileState.terrain == TERRAIN_MOUNTAIN or
		tileState.terrain == TERRAIN_BUILDING
	then
		self:SubTileHealth(tile, damage)
	end
end

-- applies a spaceDamage object on a tile.
function this:DamageSpace(spaceDamage)
	assert(type(spaceDamage) == 'userdata')
	assert(type(spaceDamage.loc.x) == 'number')
	assert(type(spaceDamage.loc.y) == 'number')
	
	local tile = spaceDamage.loc
	local tileState = self:GetTileState(spaceDamage.loc)
	local damage = spaceDamage.iDamage
	local bumpDamage = HasForceAmp() and 2 or 1
	
	------------------
	-- direct damage.
	------------------
	if
		tileState.terrain == TERRAIN_MOUNTAIN or
		tileState.terrain == TERRAIN_BUILDING
	then
		-----------------------------
		-- direct damage to terrain.
		-----------------------------
		
		-- shield is applied first, but only to buildings.
		if tileState.terrain == TERRAIN_BUILDING then
			if spaceDamage.iShield > 0 then
				tileState.isShield = true
			elseif spaceDamage.iShield == -1 then
				tileState.isShield = false
			end
		end
		
		-- damage second.
		if spaceDamage.iDamage > 0 then
			if tileState.isShield then
				tileState.isShield = false
				tileState.blocked = tileState.blocked + damage
				damage = 0
				
			elseif tileState.isFrozen then
				tileState.isFrozen = false
				tileState.blocked = tileState.blocked + damage
				damage = 0
				
			elseif tileState.terrain == TERRAIN_BUILDING then
				self:SubTileHealth(tile, spaceDamage.iDamage)
			else
				self:SubTileHealth(tile, math.min(1, spaceDamage.iDamage))
			end
		end
		
		-- other effects third.
		if spaceDamage.iFrozen == EFFECT_CREATE then
			tileState.isFrozen = true
		elseif spaceDamage.iFrozen == EFFECT_REMOVE then
			tileState.isFrozen = false
		end
	end
	
	if tileState.pawn or #tileState.corpses > 0 then
		tileState.damagePawn = tileState.damagePawn + spaceDamage.iDamage
	end
	
	-- keep track of stacking damage on corpses.
	for _, pawnId in ipairs(tileState.corpses) do
		local pawnState = self:GetPawnState(pawnId)
		local damage = damage
		
		if pawnState.isAcid then
			damage = damage * 2
		elseif pawnState.isArmor then
			damage = damage - 1
			pawnState.blocked = pawnState.blocked + 1
		end
		
		pawnState.damage = pawnState.damage + spaceDamage.iDamage
	end
	
	if tileState.pawn then
		--------------------------
		-- direct damage to pawn.
		--------------------------
		local pawnState = self:GetPawnState(tileState.pawn:GetId())
		
		-- shield is applied first.
		if spaceDamage.iShield > 0 then
			pawnState.isShield = true
		elseif spaceDamage.iShield == -1 then
			pawnState.isShield = false
		end
		
		-- damage second.
		if damage > 0 then
			
			if pawnState.isShield then
				pawnState.isShield = false
				pawnState.blocked = pawnState.blocked + damage
				tileState.blocked = tileState.blocked + damage
				damage = 0
				
			elseif pawnState.isFrozen then
				pawnState.isFrozen = false
				pawnState.blocked = pawnState.blocked + damage
				tileState.blocked = tileState.blocked + damage
				damage = 0
				
			else
				if pawnState.isAcid then
					damage = damage * 2
				elseif pawnState.isArmor then
					damage = damage - 1
					pawnState.blocked = pawnState.blocked + 1
					tileState.blocked = tileState.blocked + 1
				end
				
				self:SubPawnHealth(pawnState.id, damage)
			end
			
			pawnState.damage = pawnState.damage + spaceDamage.iDamage
		end
		
		-- other effects third.
		if spaceDamage.iAcid == EFFECT_CREATE then
			pawnState.isAcid = true
		elseif spaceDamage.iAcid == EFFECT_REMOVE then
			pawnState.isAcid = false
		end
		
		if spaceDamage.iFrozen == EFFECT_CREATE then
			pawnState.isFrozen = true
		elseif spaceDamage.iFrozen == EFFECT_REMOVE then
			pawnState.isFrozen = false
		end
		
		local dir = spaceDamage.iPush
		if
			not pawnState.pawn:IsGuarding() and
			dir >= 0						and
			dir <= 3
		then
			--------------------
			-- push resolution.
			--------------------
			local target = tile + DIR_VECTORS[dir]
			if Board:IsValid(target) then
				
				local tileState2 = self:GetTileState(target)
				
				if tileState2.pawn then
					---------------------------
					-- pawn on pawn collision.
					---------------------------
					local pawnState2 = self:GetPawnState(tileState2.pawn:GetId())
					
					self:BumpPawn(pawnState.id, bumpDamage)
					self:BumpPawn(pawnState2.id, bumpDamage)
					
				elseif
					tileState2.terrain == TERRAIN_BUILDING or
					tileState2.terrain == TERRAIN_MOUNTAIN
				then
					------------------------------
					-- pawn on terrain collision.
					------------------------------
					self:BumpPawn(pawnState.id, bumpDamage)
					self:BumpTile(target, 1)
					
				else
					-----------------------------
					-- no collision - move pawn.
					-----------------------------
					
					-- clean up potential acid from a pushed dead pawn.
					tileState.isAcid = false
					
					self:SetPawnSpace(pawnState.id, target)
					
					-- transfer acid from dead corpseless pawn to new tile.
					if
						pawnState.health <= 0			and
						not HasCorpse(pawnState.pawn)	and
						pawnState.isAcid
					then
						tileState2.isAcid = true
					end
				end
			end
		end
	else
		-- only apply acid on tiles without pawns.
		if spaceDamage.iAcid > 0 then
			tileState.isAcid = true
		end
	end
	
	tileState.damage = tileState.damage + spaceDamage.iDamage
	
	if tileState.terrain == TERRAIN_ICE then
		if spaceDamage.iDamage > 0 then
			self:SubTileHealth(tile, 1)
		end
	end
	
	if
		spaceDamage.iPush >= 0 or
		spaceDamage.iPush <= 3
	then
		for _, v in ipairs(tileState.pushList) do
			if v.dir == spaceDamage.iPush then
				v.count = v.count + 1
				break
			end
		end
	end
end

-- returns true if tile is blocked by
-- building, mountain or pawn.
function this:IsBlocked(tile)
	assert(type(tile) == 'userdata')
	assert(type(tile.x) == 'number')
	assert(type(tile.y) == 'number')
	
	local tileState = self:GetTileState(tile)
	
	return
		tileState.terrain == TERRAIN_MOUNTAIN or
		tileState.terrain == TERRAIN_BUILDING or
		tileState.pawn
end

-- mark tiles with vBoard state.
function this:MarkDamage(effect, pawnId, weapon)
	assert(type(effect) == 'userdata')
	assert(type(pawnId) == 'number')
	assert(type(weapon) == 'string')
	
	local marker = self.weaponMarks:new(pawnId, weapon)
	for tileId, tileState in pairs(self.tiles) do
		local damage = tileState.damage - tileState.damagePawn
		local loc = idx2p(tileId)
		local sImageMark = ""
		
		local pushList = shallow_copy(tileState.pushList)
		table.sort(pushList, function(a,b) return a.count > b.count end)
		local dir = pushList[1].count > 0 and pushList[1].dir or DIR_NONE
		
		local pawn = Board:GetPawn(loc)
		if pawn then
			local pawnState = self:GetPawnState(pawn:GetId())
			
			if (pawn:IsShield() or pawn:IsFrozen()) and tileState.damage > 0 then
				local color = pawn:IsAcid() and "acid_" or "yellow_"
				sImageMark = "combat/icons/".. self.id .."_damage_".. color .. (pawnState.damage - pawnState.blocked) ..".png"
				damage = 1
				
			elseif pawn:IsAcid() then
				damage = pawnState.damage - pawnState.blocked
				
			elseif pawnState.blocked > 0 then
				damage = pawnState.damage - pawnState.blocked + 1
				
			else
				damage = pawnState.damage - pawnState.blocked
			end
			
		else
			local terrain = Board:GetTerrain(loc)
			
			if terrain == TERRAIN_BUILDING or terrain == TERRAIN_MOUNTAIN then
				if
					damage > 0 and Board:IsFrozen(loc) -- or Board:IsShield(loc))
				then
					sImageMark = "combat/icons/".. self.id .."_damage_yellow_".. (damage - tileState.blocked) ..".png"
					damage = 1
				end
			end
		end
		
		if tileState.damage > 0 then
			pushList[1].count = pushList[1].count - 1
		end
		
		-- mark extra pushes on the same tile.
		for i = 1, pushList[1].count do
			marker:MarkSpaceDamage{
				loc = loc,
				iPush = dir
			}
		end
		
		-- mark damage.
		if tileState.damage > 0 then
			if damage > 0 then
				marker:MarkSpaceDamage{
					iDamage = damage,
					loc = loc,
					iPush = dir,
					sImageMark = sImageMark
				}
			else
				-- faded damage already done to a pawn on a different tile.
				local d = SpaceDamage(loc)
				d.iPush = dir == DIR_NONE and 5 or dir
				d.sImageMark = "combat/icons/".. self.id .."_damage_faded_".. tileState.damage ..".png"
				effect:AddDamage(d)
			end
		end
	end
end

local function new()
	assert(this.id, "virtualBoard has not been initialized")
	
	local vBoard = shallow_copy(this)
	this.pawns = {}
	this.tiles = {}
	
	return vBoard
end

local function init(mod)
	assert(type(mod) == 'table')
	assert(type(mod.id) == 'string')
	
	this.id = mod.id .."_virtualBoard"
	
	for i = 0, 18 do
		modApi:appendAsset("img/combat/icons/".. this.id .."_damage_yellow_".. i ..".png", mod.resourcePath .."img/virtualBoard/damage_".. i ..".png")
		modApi:appendAsset("img/combat/icons/".. this.id .."_damage_acid_".. i ..".png", mod.resourcePath .."img/virtualBoard/acid_".. i ..".png")
		modApi:appendAsset("img/combat/icons/".. this.id .."_damage_faded_".. i ..".png", mod.resourcePath .."img/virtualBoard/faded_".. i ..".png")
		Location["combat/icons/".. this.id .."_damage_yellow_".. i ..".png"] = Point(-9,10)
		Location["combat/icons/".. this.id .."_damage_acid_".. i ..".png"] = Point(-9,10)
		Location["combat/icons/".. this.id .."_damage_faded_".. i ..".png"] = Point(-9,10)
	end
end

local function load(modApiExt, armorDetection, weaponMarks)
	assert(type(modApiExt) == 'table')
	assert(type(armorDetection) == 'table')
	assert(type(weaponMarks) == 'table')
	
	this.modApiExt = modApiExt
	this.weaponMarks = weaponMarks
	this.armorDetection = armorDetection
end

return {
	init = init,
	load = load,
	new = new
}