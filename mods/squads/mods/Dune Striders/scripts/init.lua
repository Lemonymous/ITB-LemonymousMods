
local mod = {
	id = "lmn_dune_striders",
	name = "Dune Striders",
	version = "0.1.0",
	modApiVersion = "2.6.0",
	icon = "img/icon.png",
	requirements = {}
}

local scripts = {
	"palette.lua",
	"libs/",
	"squad/",
}

function mod:init()
	assert(LApi, string.format("Mod %s with id '%s' requires 'LApi' in order to function properly", self.name, self.id))
	
	LApi.scripts:init(self.scriptPath, scripts, self)
end

function mod:load(options, version)
	LApi.scripts:load(self.scriptPath, scripts, self, options, version)
end

return mod
