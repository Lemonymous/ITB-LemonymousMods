
local mod = {
	id = "vaporware",
	name = "Vaporware",
	version = "1.0.1",
	modApiVersion = "2.6.4",
	icon = "img/icon.png",
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
end

return mod
