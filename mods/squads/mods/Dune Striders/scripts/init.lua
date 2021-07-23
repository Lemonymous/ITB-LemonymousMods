
local mod = {
	id = "lmn_dune_striders",
	name = "Dune Striders",
	version = "0.0.1",
	modApiVersion = "2.6.0",
	icon = "img/icons/mod_icon.png",
	requirements = {"lmn_mod_pack"}
}

local scripts = {
	"modApiExt/modApiExt.lua",
	"palette.lua",
	"libs/",
	"squad/",
}

function mod:init()
	assert(LApi, string.format("Mod %s with id '%s' requires 'LApi' in order to function properly", self.name, self.id))
	
	LApi.scripts:init(self.scriptPath, scripts)
end

function mod:load(options, version)
	LApi.scripts:load(self.scriptPath, scripts, options, version)
end

return mod
