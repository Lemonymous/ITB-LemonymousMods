
local mod =  {
	id = "lmn_RF1995",
	name = "RF1995",
	version = "1.6.3",
	modApiVersion = "2.6.4",
	icon = "img/icon.png",
	requirements = {}
}

local scripts = {
	"libs/",
	"squad/",
}

function mod:init()
	if not easyEdit then
		Assert.Error("Easy Edit not found")
	end

	if not LApi then
		Assert.Error("LApi not found")
	end

	LApi.scripts:init(self.scriptPath, scripts)
end

function mod:load(options, version)
	LApi.scripts:load(self.scriptPath, scripts, self)
end

return mod
