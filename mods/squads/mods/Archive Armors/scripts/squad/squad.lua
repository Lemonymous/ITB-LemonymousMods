
local mod = mod_loader.mods[modApi.currentMod]

modApi.events.onModLoaded:subscribe(function(id)
	if id ~= mod.id then return end

	modApi:addSquad(
		{
			id = "Archive_Armors",
			"Archive Armors",
			"lmn_DevastatorMech",
			"lmn_BomberMech",
			"lmn_SmokeMech"
		},
		"Archive Armors",
		"Archive designed this squad for engagements so dire, collateral damage was deemed unavoidable.",
		mod.resourcePath .."img/icon.png"
	)
end)
