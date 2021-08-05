
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
	self.modApiExt = LApi.library:fetch("ITB-ModUtils/modApiExt/modApiExt")
	
	self.colorMaps = require(self.scriptPath .."colorMaps")
	self.colorMaps.Add(
		self.id,
		{
			lights =         { 46, 229, 229},
			main_highlight = {172, 140, 108},
			main_light =     {105,  68,  72},
			main_mid =       { 67,  45,  50},
			main_dark =      { 23,  17,  19},
			metal_dark =     { 36,  37,  29},
			metal_mid =      { 82,  88,  70},
			metal_light =    {169, 183, 147}
		}
	)
	
	self.mech_chemical = require(self.scriptPath .."mech_chemical")
	self.mech_dozer = require(self.scriptPath .."mech_dozer")
	self.mech_stacker = require(self.scriptPath .."mech_stacker")
	
	self.mech_chemical:init(self)
	self.mech_dozer:init(self)
	self.mech_stacker:init(self)
end

function mod:load(options, version)
	require(self.scriptPath .."shop"):load(options)
	
	self.mech_chemical:load(self.modApiExt)
	self.mech_dozer:load(options, self.modApiExt)
	self.mech_stacker:load(self.modApiExt)
	
	modApi:addSquad(
		{
			"Disposal Mechs",
			"lmn_StackerMech", "lmn_DozerMech", "lmn_ChemMech"
		},
		"Disposal Mechs",
		"Originally made by Detritus as waste disposal mechs. Now repurposed to fight the Vek.",
		self.resourcePath .. "img/icons/squad_icon.png"
	)
end

return mod