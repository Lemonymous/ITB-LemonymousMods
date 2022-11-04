
local mod = {
	id = "lmn_disposal_mechs",
	name = "Disposal Mechs",
	version = "2.0.0",
	modApiVersion = "2.8.0",
	gameVersion = "1.2.83",
	icon = "img/icon.png",
	dependencies = {"lmn_mods"},
	libs = {},
}

function mod:metadata()
	modApi:addGenerationOption("option_dozer", "Dozer Attack", "Alternate Dozer attacks.", {values = {1,2,3}, value = 3, strings = {"Old", "Old+", "New"}})
end

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
	require(path.."squad/weapon_dissolver")
	require(path.."squad/weapon_dozer")
	require(path.."squad/weapon_stacker")
end

function mod:load(options, version)
end

return mod