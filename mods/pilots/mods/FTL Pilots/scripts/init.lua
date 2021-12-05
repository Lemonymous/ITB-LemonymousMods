
local mod = {
	id = "lmn_flt_pilots",
	name = "FTL Pilots",
	version = "0.1.3",
	requirements = {},
	modApiVersion = "2.3.0",
	icon = "img/icon.png"
}

function mod:metadata()
	modApi:addGenerationOption(
		"color_emerging_vek",
		"Slug Ability Overlay Drawing",
		"Draws on top of game to correct alpha and psion colors of emerging vek. Disable for built-in drawing instead.\n\nRequires new game to take effect.",
		{enabled = true}
	)
end

function mod:init()
	LApi.library:fetch("replaceRepair/replaceRepair")
	
	require(self.scriptPath .."pilot_crystal")
	require(self.scriptPath.."pilot_slug")
	require(self.scriptPath.."pilot_engi")
end

function mod:load(options, version)
end

return mod