
local mod = {
	id = "lmn_dune_striders",
	name = "Dune Striders",
	version = "2.0.2",
	modApiVersion = "2.8.2",
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
	require(path.."squad/weapon_dual_pistols")
	require(path.."squad/weapon_hauler_hooks")
	require(path.."squad/weapon_pulse_rifle")
	require(path.."squad/weapon_teleport")
end

function mod:load(options, version)
end

return mod
