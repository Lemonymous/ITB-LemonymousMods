
local mod = mod_loader.mods[modApi.currentMod]

return function()
	return mod_loader.currentModContent[mod.id].options
end