
local mod = modApi:getCurrentMod()
local resourcePath = mod.resourcePath

local path_from = resourcePath.."img/missions/"
for _, file in ipairs(mod_loader:enumerateFilesIn(path_from)) do
	modApi:appendAsset("img/strategy/mission/"..file, path_from..file)
end

local path_from = resourcePath.."img/missions/small/"
for _, file in ipairs(mod_loader:enumerateFilesIn(path_from)) do
	modApi:appendAsset("img/strategy/mission/small/"..file, path_from..file)
end
