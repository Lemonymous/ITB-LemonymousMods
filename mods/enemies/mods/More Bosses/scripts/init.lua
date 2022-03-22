
local mod = {
	id = "lmn_more_bosses",
	name = "More Bosses",
	description = "Adds 7 bosses",
	version = "2.1.0",
	enabled = true,
	modApiVersion = "2.6.4",
	icon = "img/icon.png",
}

function mod:metadata()
	require(self.scriptPath.."options")
end

function mod:init(options)
	if not easyEdit.enabled then
		Assert.Error("Easy Edit is disabled. Make sure it is enabled in [Mod Content] > [Configure EasyEdit] and restart the game.")
	end

	if not LApi then
		Assert.Error("LApi not found")
	end

	LApi.scripts:init(self.scriptPath, "bosses/")
end

function mod:load(options, version)
	require(self.scriptPath.."options"):load(options)
end

return mod