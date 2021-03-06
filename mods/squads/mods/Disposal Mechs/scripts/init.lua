
local mod = {
	id = "lmn_disposal_mechs",
	name = "Disposal Mechs",
	version = "1.4.2",
	modApiVersion = "2.6.4",
	icon = "img/icon.png",
	requirements = {}
}

local scripts = {
	"squad/",
}

function mod:metadata()
	modApi:addGenerationOption("option_dozer", "Dozer Attack", "Alternate Dozer attacks.", {values = {1,2,3}, value = 3, strings = {"Old", "Old+", "New"}})
end

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
end

return mod