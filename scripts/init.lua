
local mod =  {
	id = "lmn_mods",
	name = "Lemonymous' Mods",
	version = "0.2.0",
	modApiVersion = "2.6.0",
	icon = "scripts/icon.png",
	description = "A Collection of mods made by Lemonymous",
	requirements = {},
	submodFolders = {"mods/"}
}

local components = {
	"scripts/LApi/LApi",
}

function mod:init()

	-- initialize components
	for _, subpath in ipairs(components) do
		local name = self.resourcePath .. subpath
		local comp = require(name)
		
		if type(comp) == 'table' and comp.init then
			comp:init()
		end
	end
end

function mod:load(options, version)

	-- load components
	for _, subpath in ipairs(components) do
		local name = self.resourcePath .. subpath
		local comp = require(name)
		
		if type(comp) == 'table' and comp.load then
			comp:load(self, options, version)
		end
	end
end

return mod
