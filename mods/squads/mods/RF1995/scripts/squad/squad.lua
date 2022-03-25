
local mod = modApi:getCurrentMod()
local mechs = {
	"lmn_HelicopterMech",
	"lmn_TankMech",
	"lmn_MinelayerMech",
	"lmn_JeepMech",
}

math.randomseed(os.time())
math.random() -- first value is useless

local MECH_INDEX_EXTRA = math.random(1,4)
local mech_extra = mechs[MECH_INDEX_EXTRA]

table.remove(mechs, MECH_INDEX_EXTRA)

modApi.events.onModLoaded:subscribe(function(id)
	if id ~= mod.id then return end

	modApi:addSquad(
		{
			"RF1995",
			mechs[1],
			mechs[2],
			mechs[3],
			id = "RF1995"
		},
		"RF1995",
		"How this squad got mixed up in the earth-saving business is unknown. "
		.. "Now where do the Vek hide their flag?"
		.. "\n\n(4th mech available in Custom and Random squads)",
		mod.resourcePath.."img/icon.png"
	)

	-- add a 4th member of our squad.
	table.insert(modApi.mod_squads[#modApi.mod_squads], mech_extra)
end)
