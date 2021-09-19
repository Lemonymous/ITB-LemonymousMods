
local mod = mod_loader.mods[modApi.currentMod]

modApi.events.onModLoaded:subscribe(function(id)
	if id ~= mod.id then return end

	modApi:addSquad(
		{
			id = "lmn_dune_striders",
			"Dune Striders",
			"lmn_ds_Commando",
			"lmn_ds_Gunslinger",
			"lmn_ds_Swoop"
		},
		"Dune Striders",
		"These Mechs uses speed and cunning to outmaneuver their enemies.",
		mod.resourcePath .. "img/icon.png"
	)
end)
