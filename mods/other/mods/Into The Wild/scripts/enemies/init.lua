
local this = {}
local path = mod_loader.mods[modApi.currentMod].scriptPath .."enemies/"

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
	--"iceflower",
	--"deadWood",
	--"shambler",
}

function this:init(mod)
	for _, name in ipairs(enemies) do
		self[name] = require(path .. name)
		self[name]:init(mod)
	end
end

function this:load(mod, options, version)
	for _, name in ipairs(enemies) do
		self[name]:load(mod, options, version)
	end
end

return this