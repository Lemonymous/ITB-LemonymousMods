
local mod =  {
	id = "lmn_RF1995",
	name = "RF1995",
	version = "2.0.0",
	modApiVersion = "2.7.3dev",
	gameVersion = "1.2.83",
	icon = "img/icon.png",
	dependencies = {"lmn_mods"},
	libs = {},
}

function mod:init()
	for libId, lib in pairs(mod_loader.mods.lmn_mods.libs) do
		self.libs[libId] = lib
	end

	local path = mod.scriptPath
	require(path.."squad/achievements")
	require(path.."squad/assets")
	require(path.."squad/palette")
	require(path.."squad/pawns")
	require(path.."squad/squad")
	require(path.."squad/weapon_helicopter")
	require(path.."squad/weapon_jeep")
	require(path.."squad/weapon_launcher")
	require(path.."squad/weapon_minelayer")
	require(path.."squad/weapon_tank")
end

function mod:load(options, version)
end

return mod
