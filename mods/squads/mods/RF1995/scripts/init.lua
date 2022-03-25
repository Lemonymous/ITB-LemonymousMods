
local mod =  {
	id = "lmn_RF1995",
	name = "RF1995",
	version = "1.6.0",
	modApiVersion = "2.6.4",
	icon = "img/icon.png",
	requirements = {}
}

local scripts = {
	"libs/",
	"squad/",
}

function mod:init()
	if not easyEdit.enabled then
		Assert.Error("Easy Edit is disabled. Make sure it is enabled in [Mod Content] > [Configure EasyEdit] and restart the game.")
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
