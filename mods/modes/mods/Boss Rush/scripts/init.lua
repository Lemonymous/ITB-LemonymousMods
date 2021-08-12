

local oldOrderMods = mod_loader.orderMods
function mod_loader.orderMods(self, options, savedOrder)
	local ret = oldOrderMods(self, options, savedOrder)
	
	local mod = mod_loader.mods["lmn_boss_rush"]
	mod.icon = mod.resourcePath .."img/mod_icon.png"
	
	return ret
end

local function init(self)
	spawner = require(self.scriptPath.."spawner")
end

local function load(self, options, version)
end

return {
	id = "lmn_boss_rush",
	name = "Boss Rush",
	description = "Adds bosses to the final mission based on islands completed \n[Easy] 0\n[Normal] 0-1\n[Hard] 1-3\n[Very Hard] 3-5\n[Impossible] 4-8",
	version = "1.0.2",
	requirements = {"kf_ModUtils", "lmn_more_bosses"},
	init = init,
	load = load,
}