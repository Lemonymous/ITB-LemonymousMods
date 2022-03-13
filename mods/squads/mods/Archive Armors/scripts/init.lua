
local mod = {
	id = "lmn_archive_armors",
	name = "Archive Armors",
	version = "1.4.0",
	modApiVersion = "2.6.0",
	icon = "img/icon.png",
	requirements = {}
}

local scripts = {
	"squad/",
}

function mod:init()
	if not LApi then
		Assert.Error("LApi not found")
	end

	LApi.scripts:init(self.scriptPath, scripts)
end

function mod:load(options, version) end

return mod