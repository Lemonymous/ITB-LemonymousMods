
local mod = {
	id = "lmn_more_bosses",
	name = "More Bosses",
	icon = "img/mod_icon.png",
	description = "Adds 7 bosses",
	version = "2.0.0",
	enabled = true,
	modApiVersion = "2.6",
}

function mod:metadata()
	require(self.scriptPath.."options")
end

function mod:init(options)
	LApi.scripts:init(self.scriptPath, "bosses/")
end

function mod:load(options, version)
	require(self.scriptPath.."options"):load(options)
end

return mod