
local mod = {
	id = "lmn_archive_armors",
	name = "Archive Armors",
	version = "1.3.2",
	modApiVersion = "2.3.0",
	icon = "img/icons/mod_icon.png",
	requirements = {}
}

function mod:init()
	require(self.scriptPath .."mech_devastator")
	require(self.scriptPath .."mech_bomber")
	require(self.scriptPath .."mech_apc")
end

function mod:load(options, version)
	
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