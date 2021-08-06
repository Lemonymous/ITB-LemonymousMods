
local mod =  {
	id = "lmn_RF1995",
	name = "RF1995",
	version = "1.4.0",
	modApiVersion = "2.3.0",
	icon = "img/icons/mod_icon.png",
	requirements = {}
}

local scripts = {
	"libs/hooks",
	"libs/nonMassiveDeployWarning",
	"libs/shop",
	"libs/track_items",
	"libs/track_undo_move",
	"libs/virtualBoard",
	"libs/weaponMarks",
	"palette",
	"weapons/weapon_launcher",
	"weapons/weapon_minelayer",
	"pawns/mech_helicopter",
	"pawns/mech_jeep",
	"pawns/mech_minelayer",
	"pawns/mech_tank",
}

function mod:init()
	assert(LApi, string.format("Mod %s with id '%s' requires 'LApi' in order to function properly", self.name, self.id))
	
	-- initialize scripts
	for _, subpath in ipairs(scripts) do
		local name = self.scriptPath .. subpath
		local comp = require(name)
		
		if type(comp) == 'table' and comp.init then
			comp:init()
		end
	end
end

function mod:load(options, version)
	-- load scripts
	for _, subpath in ipairs(scripts) do
		local name = self.scriptPath .. subpath
		local comp = require(name)
		
		if type(comp) == 'table' and comp.load then
			comp:load(options, version)
		end
	end
	
	math.randomseed(os.time()); math.random()
	local rng = math.random(1,4)
	local list = {}
	list[(rng + 0) % 4 + 1] = "lmn_JeepMech"
	list[(rng + 1) % 4 + 1] = "lmn_HelicopterMech"
	list[(rng + 2) % 4 + 1] = "lmn_TankMech"
	list[(rng + 3) % 4 + 1] = "lmn_MinelayerMech"
	
	modApi:addSquad(
		{
			"RF1995",
			list[1],
			list[2],
			list[3]
		},
		"RF1995",
		"How this squad got mixed up in the earth-saving business is unknown. "
		.. "Now where do the Vek hide their flag?"
		.. "\n\n(4th mech available in Custom and Random squads)",
		self.resourcePath .. "img/icons/squad_icon.png"
	)
	
	-- add a 4th member of our squad.
	table.insert(modApi.mod_squads[#modApi.mod_squads], list[4])
end

return mod
