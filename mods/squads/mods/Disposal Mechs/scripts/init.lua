
local mod = {
	id = "lmn_disposal_mechs",
	name = "Disposal Mechs",
	version = "1.3.0",
	modApiVersion = "2.6.0",
	icon = "img/icon.png",
	requirements = {}
}

local scripts = {
	"palette.lua",
	"squad/",
}

function mod:metadata()
	modApi:addGenerationOption("option_dozer", "Dozer Attack", "Alternate Dozer attacks.", {values = {1,2,3}, value = 3, strings = {"Old", "Old+", "New"}})
end

function mod:init()
	if not LApi then
		Assert.Error("LApi not found")
	end

	LApi.scripts:init(self.scriptPath, scripts)
end

function mod:load(options, version)
end

return mod