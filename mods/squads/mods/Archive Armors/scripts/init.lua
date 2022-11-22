
local mod = {
	id = "lmn_archive_armors",
	name = "Archive Armors",
	version = "2.0.1",
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
	require(path.."squad/weapon_apc")
	require(path.."squad/weapon_bomber")
	require(path.."squad/weapon_devastator")
end

function mod:load(options, version) end

return mod