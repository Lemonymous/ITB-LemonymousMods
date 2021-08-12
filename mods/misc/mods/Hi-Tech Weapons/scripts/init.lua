
local mod = {
	id = "lmn_high_tech_weapons",
	name = "Hi-Tech Weapons",
	version = "1.1.0",
	modApiVersion = "2.3.0",
	icon = "img/mod_icon.png",
	requirements = {},
}

function mod:init()
	assert(LApi, string.format("Mod %s with id '%s' requires 'LApi' in order to function properly", self.name, self.id))
	
	self.modApiExt = require(self.scriptPath .."modApiExt/modApiExt")
	self.modApiExt:init()
	
	self.weaponMarks = require(self.scriptPath .."weaponMarks")
	
	self.weaponMarks:init(self)
	
	self.guided = require(self.scriptPath .."weapon_guided_missile")
	self.tri_striker = require(self.scriptPath .."weapon_tri_striker")
	self.autocannon = require(self.scriptPath .."weapon_autocannon")
	self.gauss = require(self.scriptPath .."weapon_gauss_cannon")
	self.multi_laser = require(self.scriptPath .."weapon_multi_laser")
	self.psionic = require(self.scriptPath .."weapon_psionic_transmitter")
	
	self.guided:init(self)
	self.tri_striker:init(self)
	self.autocannon:init(self)
	self.gauss:init(self)
	self.multi_laser:init(self)
	self.psionic:init(self)
end

function mod:load(options, version)
	self.modApiExt:load(self, options, version)
	
	self.weaponMarks:load(self.modApiExt)
	
	self.guided:load(options, self.modApiExt)
	self.tri_striker:load(options, self.modApiExt)
	self.autocannon:load(options, self.modApiExt)
	self.gauss:load(options, self.modApiExte)
	self.multi_laser:load(options, self.modApiExt)
	self.psionic:load(options, self.modApiExt)
end

return mod
