
local mod = {
	id = "lmn_into_the_wild",
	name = "Into The Wild",
	version = "1.2.2",
	modApiVersion = "2.3.0",
	icon = "img/icon.png",
	requirements = {}
}

--Currently not enough different enemy types to warrant exclusion code.
--ExclusiveElements["lmn_Sprout"] = "lmn_Chomper"			-- limit slow melee.
--ExclusiveElements["lmn_Bud"] = "lmn_Puffer"				-- limit number of stable enemies.
--ExclusiveElements["lmn_Springseed"] = "lmn_Puffer"		-- limit number of very fast enemies.
ExclusiveElements["lmn_Puffer"] = "Jelly_Explode"			-- explode near buildings is not fun.
ExclusiveElements["lmn_Infuser"] = "lmn_Beanstalker"		-- both support.

function mod:init()
	if not easyEdit.enabled then
		return
	end

	assert(LApi, string.format("Mod %s with id '%s' requires 'LApi' in order to function properly", self.name, self.id))

	local scriptPath = self.scriptPath
	local resourcePath = self.resourcePath
	
	LApi.library:new("tutorialTips")

	require(scriptPath.."island/ceo")
	require(scriptPath.."island/corporation")
	require(scriptPath.."island/corporation_pilot")
	require(scriptPath.."island/enemyList")
	require(scriptPath.."island/bossList")
	require(scriptPath.."island/missionImages")
	require(scriptPath.."island/missionList")
	require(scriptPath.."island/structures")
	require(scriptPath.."island/structureList")
	require(scriptPath.."island/tileset")
	require(scriptPath.."island/island")
	require(scriptPath.."island/islandComposite")

	require(scriptPath.."enemies/init")
	require(scriptPath.."missions/init")
	require(scriptPath.."enemies/bosses/init")
	require(scriptPath.."deathPetals")

	require(scriptPath .."weapons/weapons")

	require(scriptPath .."achievements")
	require(scriptPath .."achievementTriggers")
	require(scriptPath .."side_objectives")
	require(scriptPath .."tiles_emitters")
	require(scriptPath .."damageNumbers/damageNumbers")
end

function mod:load(options, version)
	local scriptPath = self.scriptPath

	if modApi.achievements:isComplete(self.id, "leaders") then
		require(scriptPath.."secret"):addSquad()
	end
end

return mod