
local mod = {
	id = "lmn_into_the_wild",
	name = "Into The Wild",
	version = "1.4.1",
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

	local path = self.scriptPath
	require(path.."island/ceo")
	require(path.."island/corporation")
	require(path.."island/corporation_pilot")
	require(path.."island/enemyList")
	require(path.."island/bossList")
	require(path.."island/missionImages")
	require(path.."island/missionList")
	require(path.."island/structures")
	require(path.."island/structureList")
	require(path.."island/tileset")
	require(path.."island/island")
	require(path.."island/islandComposite")
	require(path.."island/exclusiveEnemies")

	require(path.."enemies/init")
	require(path.."missions/init")
	require(path.."enemies/bosses/init")
	require(path.."deathPetals")

	require(path .."weapons/weapons")

	require(path .."achievements")
	require(path .."achievementTriggers")
	require(path .."structure_emitter")
	require(path .."damageNumbers/damageNumbers")
end

function mod:load(options, version)
	local scriptPath = self.scriptPath

	if modApi.achievements:isComplete(self.id, "leaders") then
		require(scriptPath.."secret"):addSquad()
	end
end

return mod