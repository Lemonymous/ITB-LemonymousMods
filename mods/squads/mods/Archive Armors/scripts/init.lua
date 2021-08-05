
local mod = {
	id = "lmn_archive_armors",
	name = "Archive Armors",
	version = "1.3.2",
	modApiVersion = "2.3.0",
	icon = "img/icons/mod_icon.png",
	requirements = {}
}

function mod:init()
	self.modApiExt = LApi.library:fetch("ITB-ModUtils/modApiExt/modApiExt")
	
	self.devastator = require(self.scriptPath .."mech_devastator")
	self.bomber = require(self.scriptPath .."mech_bomber")
	self.apc = require(self.scriptPath .."mech_apc")
	
	self.devastator:init(self)
	self.bomber:init(self)
	self.apc:init(self)
end

function mod:load(options, version)
	require(self.scriptPath .."shop"):load(options)
	
	self.devastator:load(self.modApiExt)
	self.bomber:load(self.modApiExt)
	self.apc:load(self.modApiExt)
	
	modApi:addSquad(
		{
			"Archive Armors",
			"lmn_DevastatorMech",
			"lmn_BomberMech",
			"lmn_SmokeMech"
		},
		"Archive Armors",
		"Archive designed this squad for engagements so dire, collateral damage was deemed unavoidable.",
		self.resourcePath .."img/icons/squad_icon.png"
	)
end

return mod