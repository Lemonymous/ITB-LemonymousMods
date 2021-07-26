
local mod = mod_loader.mods[modApi.currentMod]

return function()
	local m = modApiExt_internal
	assert(m, "Your mod requires modApiExt to function")
	
	for _, modUtils in ipairs(m.extObjects) do
		if modUtils.owner and modUtils.owner.id == mod.id then
			return modUtils
		end
	end
	
	assert(false, "Your mod requires modApiExt to function")
end