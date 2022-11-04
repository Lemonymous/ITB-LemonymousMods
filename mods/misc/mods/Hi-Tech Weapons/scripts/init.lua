
local mod = {
	id = "lmn_high_tech_weapons",
	name = "Hi-Tech Weapons",
	version = "1.2.0",
	modApiVersion = "2.8.0",
	gameVersion = "1.2.83",
	icon = "img/icon.png",
	dependencies = {"lmn_mods"},
	libs = {},
}

function mod:init()
	for libId, lib in pairs(mod_loader.mods.lmn_mods.libs) do
		self.libs[libId] = lib
	end

	local path = self.scriptPath
	require(path.."weapon_guided_missile")
	require(path.."weapon_tri_striker")
	require(path.."weapon_autocannon")
	require(path.."weapon_gauss_cannon")
	require(path.."weapon_multi_laser")
	require(path.."weapon_psionic_transmitter")
end

function mod:load(options, version)
end

return mod
