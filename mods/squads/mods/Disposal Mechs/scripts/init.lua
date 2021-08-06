
local mod = {
	id = "lmn_disposal_mechs",
	name = "Disposal Mechs",
	version = "1.2.0",
	modApiVersion = "2.3.0",
	icon = "img/icons/mod_icon.png",
	requirements = {}
}

function mod:metadata()
	modApi:addGenerationOption("option_dozer", "Dozer Attack", "Alternate Dozer attacks.", {values = {1,2,3}, value = 3, strings = {"Old", "Old+", "New"}})
end

function mod:init()
	require(self.scriptPath.."palette")
	require(self.scriptPath.."mech_chemical")
	require(self.scriptPath.."mech_dozer")
	require(self.scriptPath.."mech_stacker")
	require(self.scriptPath.."squad/squad")
end

function mod:load(options, version)
end

return mod