
local mod = {
	id = "lmn_more_bosses",
	name = "More Bosses",
	description = "Adds 7 bosses",
	version = "2.0.1",
	enabled = true,
	modApiVersion = "2.6",
	icon = "img/icon.png",
}

function mod:metadata()
	require(self.scriptPath.."options")
end

function mod:init(options)
	if not LApi then
		Assert.Error("LApi not found")
	end

	LApi.scripts:init(self.scriptPath, "bosses/")
end

function mod:load(options, version)
	require(self.scriptPath.."options"):load(options)
end

return mod