
local mod = {
	id = "lmn_archive_armors",
	name = "Archive Armors",
	version = "1.3.2",
	modApiVersion = "2.3.0",
	icon = "img/icons/mod_icon.png",
	requirements = {}
}

local scripts = {
	"squad/",
}

function mod:init()
	LApi.scripts:init(self.scriptPath, scripts)
end

function mod:load(options, version) end

return mod