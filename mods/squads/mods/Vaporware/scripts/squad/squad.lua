
local mod = modApi:getCurrentMod()

local function addSquad(modId)
	if modId ~= mod.id then return end

	modApi:addSquad(
		{
			id = "vaporware",
			"Vaporware",
			"vw_shroud",
			"vw_zephyr",
			"vw_vortex",
		},
		"Vaporware",
		"Made as a response to all the havoc caused by Mechs \"protecting\" cities, these Mechs use Smoke to ward off the Vek.",
		mod.resourcePath.."img/icon.png"
	)
end

modApi.events.onModLoaded:subscribe(addSquad)
