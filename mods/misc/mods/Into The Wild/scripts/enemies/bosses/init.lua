
local this = {}
local path = mod_loader.mods[modApi.currentMod].resourcePath

local bosses = {
	"chomper",
	"sunflower",
	"springseed",
	"chili",
	"sequoia",
	--"shambler",
}

for i = 0, 10 do
	modApi:addMap(path .."maps/lmn_jungle_leader".. i ..".map")
end

function this:init(mod)
	for _, name in ipairs(bosses) do
		mod[name] = require(path .."scripts/enemies/bosses/" .. name)
		mod[name]:init(mod)
	end
end

function this:load(mod, options, version)
	for i, name in ipairs(bosses) do
		mod[name]:load(mod, options, mod.modApiExt)
	end
end

return this