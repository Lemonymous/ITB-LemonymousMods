
local mod = mod_loader.mods[modApi.currentMod]
local squad = {}

function squad:load()
	modApi:addSquad(
		{
			id = "lmn_dune_striders",
			"Dune Striders",
			"lmn_ds_Commando", "lmn_ds_Gunslinger", "lmn_ds_Swoop"
		},
		"Dune Striders",
		"These Mechs uses speed and cunning to outmaneuver their enemies.",
		mod.resourcePath .. "img/icons/squad_icon.png"
	)
end

return squad
