
local mod = modApi:getCurrentMod()
local path = mod.resourcePath

local bosses = {
	"chomper",
	"sunflower",
	"springseed",
	"chili",
	"sequoia",
}

for i = 0, 10 do
	modApi:addMap(path .."maps/lmn_jungle_leader".. i ..".map")
end

for i, name in ipairs(bosses) do
	bosses[i] = require(path .."scripts/enemies/bosses/" .. name)
end
