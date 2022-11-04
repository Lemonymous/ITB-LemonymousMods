
local mod = modApi:getCurrentMod()
local path = mod.scriptPath
local spaceDamageObjects = require(path .."libs/spaceDamageObjects")
local modApiExt = mod.libs.modApiExt

local function onModsLoaded()
	modApiExt:addPawnKilledHook(function(_, pawn)
		local petals = _G[pawn:GetType()].lmn_PetalsOnDeath
		if petals then
			local loc = pawn:GetSpace()
			Board:DamageSpace(spaceDamageObjects.Emitter(loc, petals))
		end
	end)
end

modApi.events.onModsLoaded:subscribe(onModsLoaded)
