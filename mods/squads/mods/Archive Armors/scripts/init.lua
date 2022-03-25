
local mod = {
	id = "lmn_archive_armors",
	name = "Archive Armors",
	version = "1.5.2",
	modApiVersion = "2.6.4",
	icon = "img/icon.png",
	requirements = {}
}

local scripts = {
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

function mod:load(options, version) end

return mod