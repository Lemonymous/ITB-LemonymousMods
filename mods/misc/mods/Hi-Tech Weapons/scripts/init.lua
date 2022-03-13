
local mod = {
	id = "lmn_high_tech_weapons",
	name = "Hi-Tech Weapons",
	version = "1.1.0",
	modApiVersion = "2.3.0",
	icon = "img/icon.png",
	requirements = {},
}

function mod:init()
	if not LApi then
		Assert.Error("LApi not found")
	end
	
	require(self.scriptPath .."weapon_guided_missile")
	require(self.scriptPath .."weapon_tri_striker")
	require(self.scriptPath .."weapon_autocannon")
	require(self.scriptPath .."weapon_gauss_cannon")
	require(self.scriptPath .."weapon_multi_laser")
	require(self.scriptPath .."weapon_psionic_transmitter")
end

function mod:load(options, version)
end

return mod
