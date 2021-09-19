
local mod = {
	id = "lmn_boss_rush",
	name = "Boss Rush",
	description = "Adds bosses to the final mission based on islands completed \n[Easy] 0\n[Normal] 0-1\n[Hard] 1-3\n[Very Hard] 3-5\n[Impossible] 4-8",
	version = "1.1.0",
	enabled = false,
	modApiVersion = "2.6.0",
	icon = "img/icon.png",
	requirements = { "lmn_more_bosses" },
}

function mod:init()
	require(self.scriptPath.."spawner")
end

function mod:load(options, version) end

return mod
