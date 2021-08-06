
local mod = mod_loader.mods[modApi.currentMod]

modApi.events.onModLoaded:subscribe(function(id)
	if id ~= mod.id then return end

	modApi:addSquad(
		{
			id = "lmn_Disposal_Mechs",
			"Disposal Mechs",
			"lmn_StackerMech",
			"lmn_DozerMech",
			"lmn_ChemMech"
		},
		"Disposal Mechs",
		"Originally made by Detritus as waste disposal mechs. Now repurposed to fight the Vek.",
		mod.resourcePath .. "img/icons/squad_icon.png"
	)
end)
