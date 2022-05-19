
local mod = {
	id = "lmn_dune_striders",
	name = "Dune Striders",
	version = "0.2.3",
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

	LApi.scripts:init(self.scriptPath, scripts, self)
end

function mod:load(options, version)
	LApi.scripts:load(self.scriptPath, scripts, self, options, version)
end

return mod
