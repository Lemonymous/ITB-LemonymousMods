
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
	self.modApiExt = LApi.library:fetch("ITB-ModUtils/modApiExt/modApiExt")
	LApi.library:fetch("replaceRepair/replaceRepair")
	
	require(self.scriptPath .."pilot_crystal")
	self.slug = require(self.scriptPath .."pilot_slug")
	require(self.scriptPath.."pilot_engi")
	--self.lanius = require(self.scriptPath .."pilot_lanius")
	
	self.slug:init(self)
	--self.lanius:init(self)
end

function mod:load(options, version)
	self.slug:load(self.modApiExt, options)
	--self.lanius:load(self.modApiExt, options)
end

return mod