
local mod = {
	id = "lmn_boss_rush",
	name = "Boss Rush",
	description = "Adds bosses to the final mission based on islands completed \n[Easy] 0\n[Normal] 0-1\n[Hard] 1-3\n[Very Hard] 3-5\n[Impossible] 4-8",
	version = "1.2.0",
	icon = "img/icon.png",
	modApiVersion = "2.8.0",
	gameVersion = "1.2.83",
	enabled = false,
	libs = {},
}

function mod:init()
	for libId, lib in pairs(mod_loader.mods.lmn_mods.libs) do
		self.libs[libId] = lib
	end

	require(self.scriptPath.."spawner")
end

function mod:load(options, version) end

return mod
