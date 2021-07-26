
local mod = mod_loader.mods[modApi.currentMod]

return function()
	local m = modApiExt_internal
	assert(m, mod.id .." - Replace Repair found no modApiExt.")
	
	for _, modUtils in ipairs(m.extObjects) do
		if modUtils.owner and modUtils.owner.id == mod.id then
			return modUtils
		end
	end
	
	assert(false, mod.id .." - Replace Repair: found no modApiExt or modApiExt is out of date.")
end
