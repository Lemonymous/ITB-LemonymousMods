
local mod = {
	id = "lmn_flt_pilots",
	name = "FTL Pilots",
	version = "1.1.0",
	modApiVersion = "2.8.0",
	gameVersion = "1.2.83",
	icon = "img/icon.png",
	dependencies = {"lmn_mods"},
	libs = {},
}

function mod:metadata()
	modApi:addGenerationOption(
		"color_emerging_vek",
		"Slug Ability Overlay Drawing",
		"Draws on top of game to correct alpha and psion colors of emerging vek. Disable for built-in drawing instead.\n\nRequires new game to take effect.",
		{enabled = true}
	)
end

function mod:init()
	for libId, lib in pairs(mod_loader.mods.lmn_mods.libs) do
		self.libs[libId] = lib
	end

	local path = mod.scriptPath
	require(path.."pilot_crystal")
	require(path.."pilot_slug")
	require(path.."pilot_engi")
end

function mod:load(options, version)
end

return mod
