
local mod = modApi:getCurrentMod()
local path = mod.scriptPath .."enemies/"

local enemies = {
	"sprout",
	"chomper",
	"sunflower",
	"springseed",
	"cactus",
	"bud",
	"copter",
	"puffer",
	"beanstalker",
	"infuser",
	"chili",
}

for i, name in ipairs(enemies) do
	enemies[i] = require(path..name)
end
