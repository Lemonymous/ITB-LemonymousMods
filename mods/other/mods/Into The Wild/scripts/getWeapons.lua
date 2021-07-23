
local this = {}

local function getWeapons(pawnId)
	pawnId = (type(pawnId) == 'userdata') and pawnId:GetId() or pawnId
	assert(type(pawnId) == 'number')
	
	local modUtils = modApiExt_internal.getMostRecent()
	local ptable = modUtils.pawn:getSavedataTable(pawnId)
	if not ptable then return {{},{}} end
	
	local weapons = {}
	weapons[1] = modUtils.pawn:getWeaponData(ptable, "primary") or {}
	weapons[2] = modUtils.pawn:getWeaponData(ptable, "secondary") or {}
	
	return weapons
end

-- returns a size 2 table with a pawn's base and upgraded weapons.
-- table will be empty outside of missions with available save data.
function this:GetPowered(pawnId)
	local ret = {{},{}}
	local weapons = getWeapons(pawnId)
	
	for i = 1, 2 do
		local w = ret[i]
		
		-- if 'powered' array's first core is powered.
		local power = weapons[i].power or {}
		if #power == 0 or power[1] > 0 then
		--if (weapons[i].power or {0})[1] > 0 then
			w.base = weapons[i].id
			w.weapon = weapons[i].id
			local upg = "_"
			
			-- if 'upgrade1' array's first core is powered.
			local upgrade = weapons[i].upgrade1 or {}
			if #upgrade == 0 or upgrade[1] > 0 then
			--if (weapons[i].upgrade1 or {0})[1] > 0 then
				upg = upg .."A"
			end
			
			-- if 'upgrade2' array's first core is powered.
			local upgrade = weapons[i].upgrade2 or {}
			if #upgrade == 0 or upgrade[1] > 0 then
			--if (weapons[i].upgrade2 or {0})[1] > 0 then
				upg = upg .."B"
			end
			
			w.weapon = upg:len() > 1 and w.weapon .. upg or w.weapon
		end
	end
	
	return ret
end

-- returns a szie 2 table with a pawn's base weapons.
-- table will be empty outside of missions with available save data.
function this:GetPoweredBase(pawnId)
	local ret = {{},{}}
	local weapons = getWeapons(pawnId)
	
	for i = 1, 2 do
		-- if 'powered' array's first core is powered.
		local power = weapons[i].power or {}
		if #power == 0 or power[1] > 0 then
		--if (weapons[i].power or {0})[1] > 0 then
			ret[i] = weapons[i].id
		end
	end
	
	return ret
end

-- returns a size 2 table with a pawn's upgraded weapons.
-- table will be empty outside of missions with available save data.
function this:GetPoweredUpgrades(pawnId)
	local ret = {{},{}}
	local weapons = getWeapons(pawnId)
	
	for i = 1, 2 do
		-- if 'powered' array's first core is powered.
		local power = weapons[i].power or {}
		if #power == 0 or power[1] > 0 then
		--if (weapons[i].power or {0})[1] > 0 then
			ret[i] = weapons[i].id
			local upg = "_"
			
			-- if 'upgrade1' array's first core is powered.
			local upgrade = weapons[i].upgrade1 or {}
			if #upgrade == 0 or upgrade[1] > 0 then
			--if (weapons[i].upgrade1 or {0})[1] > 0 then
				upg = upg .."A"
			end
			
			-- if 'upgrade2' array's first core is powered.
			local upgrade = weapons[i].upgrade2 or {}
			if #upgrade == 0 or upgrade[1] > 0 then
			--if (weapons[i].upgrade2 or {0})[1] > 0 then
				upg = upg .."B"
			end
			
			ret[i] = upg:len() > 1 and ret[i] .. upg or ret[i]
		end
	end
	
	return ret
end

return this