
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
	self.modApiExt = require(self.scriptPath .."modApiExt/modApiExt")
	self.modApiExt:init()
	
	self.replaceRepair = require(self.scriptPath .."replaceRepair/replaceRepair")
	self.replaceRepair:init(self, self.modApiExt)
	
	self.crystal = require(self.scriptPath .."pilot_crystal")
	self.slug = require(self.scriptPath .."pilot_slug")
	self.engi = require(self.scriptPath .."pilot_engi")
	--self.lanius = require(self.scriptPath .."pilot_lanius")
	
	self.crystal:init(self)
	self.slug:init(self)
	self.engi:init(self)
	--self.lanius:init(self)
end

function mod:load(options, version)
	self.modApiExt:load(self, options, version)
	self.replaceRepair:load(self, options, version)
	
	self.crystal:load(self.modApiExt, options)
	self.slug:load(self.modApiExt, options)
	self.engi:load(self.modApiExt, options)
	--self.lanius:load(self.modApiExt, options)
end

return mod