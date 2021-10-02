
local mod =  {
	id = "lmn_RF1995",
	name = "RF1995",
	version = "1.4.1",
	modApiVersion = "2.3.0",
	icon = "img/icon.png",
	requirements = {}
}

local scripts = {
	"libs/",
	"achievements",
	"palette",
	"weapons/",
	"pawns/",
}

function mod:init()
	LApi.scripts:init(self.scriptPath, scripts)
end

function mod:load(options, version)
	LApi.scripts:load(self.scriptPath, scripts, self)
end

return mod
