
local path = mod_loader.mods[modApi.currentMod].scriptPath
local spaceDamageObjects = require(path .."spaceDamageObjects")
local this = {}
local modApiExt = LApi.library:fetch("modApiExt/modApiExt", nil, "ITB-ModUtils")


function this:load()
	modApiExt:addPawnKilledHook(function(_, pawn)
		local petals = _G[pawn:GetType()].lmn_PetalsOnDeath
		if petals then
			local loc = pawn:GetSpace()
			Board:DamageSpace(spaceDamageObjects.Emitter(loc, petals))
		end
	end)
end

return this