
local currentMod = mod_loader.mods[modApi.currentMod]
local modApiExtFinder = {}

function modApiExtFinder:get()
	if self.modApiExt_cached == nil then
		self:find(currentMod)
	end

	return self.modApiExt_cached
end

function modApiExtFinder:find(mod)
	if self.modApiExt_cached == nil then
		if mod.parent then
			local parentMod = mod_loader.mods[mod.parent]
			self:find(parentMod)
		end
	end

	if self.modApiExt_cached == nil then
		LOGDF("Mod '%s' searching for modApiExt in mod '%s'...", currentMod.id, mod.id)
		local modApiExtPath = mod.scriptPath.."ITB-ModUtils/modApiExt/modApiExt"
		if modApi:fileExists(modApiExtPath..".lua") then
			self.modApiExt_cached = require(modApiExtPath)
			self.owner = mod
			LOGDF("Mod '%s' successully found modApiExt in mod '%s'!", currentMod.id, mod.id)
		end
	end
end

function modApiExtFinder:verify(mod)
	if self.modApiExt_cached == nil then
		error(string.format("Mod %s with id '%s' could not find modApiExt\n\n"..
			"Clone repository 'https://github.com/kartoFlane/ITB-ModUtils'\n"..
			"to '%s'", mod.name, mod.id, mod.scriptPath))
	end
end

function modApiExtFinder:init(mod)
	self:find(mod)
	self:verify(mod)

	if self.owner == mod then
		self.modApiExt_cached:init()
	end
end

function modApiExtFinder:load(mod, options, version)
	self:find(mod)
	self:verify(mod)

	if self.owner == currentMod then
		self.modApiExt_cached:load(options, version)
	end
end

return modApiExtFinder
