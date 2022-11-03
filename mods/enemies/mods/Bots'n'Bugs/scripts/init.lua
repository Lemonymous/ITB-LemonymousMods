
local mod = {
	id = "lmn_bots_and_bugs",
	name = "Bots'n'Bugs",
	description = "Adds 9 enemies, 6 bosses and 5 unlockable Techno-Vek.",
	version = "2.3.0",
	modApiVersion = "2.6.7dev",
	gameVersion = "1.2.83",
	icon = "img/icon.png",
	dependencies = {"lmn_mods"},
	libs = {},
}

local choices = {
	{
		id = "option_roach_delay_spit",
		title = "Delay Roach Spit",
		text = "Roaches won't spit the turn they emerge from the ground.",
		option = {enabled = false}
	},
}

local pilots = {
	"Pilot_lmn_Swarmer",
	"Pilot_lmn_Roach",
	"Pilot_lmn_Spitter",
	"Pilot_lmn_Wyrm",
	"Pilot_lmn_Crusher"
}

local pilot_template = {
	Personality = "Vek",
	Sex = SEX_VEK,
	Skill = "Survive_Death",
	Rarity = 0,
}

function mod:metadata()
	local modcontent = modApi:getCurrentModcontentPath()
	
    sdlext.config(modcontent, function(obj)
		if not obj.modOptions then return end
		local entry = obj.modOptions[mod.id]
		if not entry then return end
		
		-- version 2.0.0 changed options substantially.
		-- Resetting options if lower version detected.
		if modApi:isVersion("2", entry.version) then
			return
		end
		
		entry.options = {}
    end)
	
	for _, v in pairs(choices) do
		modApi:addGenerationOption(v.id, v.title, v.text, v.option or { enabled == true })
	end
	
	-- add pilots in metadata to avoid error message if mod is not enabled.
	-- it might be preferrable to remove traces of pilots from profile,
	-- but that could prove difficult.
	for _, id in ipairs(pilots) do
		local pilot = {
			Id = id,
			Personality = "Vek",
			Sex = SEX_VEK,
			Skill = "Survive_Death",
			Rarity = 0
		}
		_G[id] = Pilot:new(pilot)
	end
end

function mod:init()
	for libId, lib in pairs(mod_loader.mods.lmn_mods.libs) do
		self.libs[libId] = lib
	end
	
	for _, name in ipairs{
		"tips",
		"enemies",
		"bosses",
		"enemy/swarmer",
		"enemy/roach",
		"enemy/spitter",
		"enemy/wyrm",
		"enemy/crusher",
		"enemy/blobberling",
		"enemy/floater",
		"enemy/shieldbot",
		"enemy/knightbot",
		"doubleSpawn",
		"effects",
		"secret",
		"achievements",
		"achievementTriggers",
		"enemyList",
		"bossList",
	} do
		require(self.scriptPath .. name)
	end
	
	-- modApi:addModsInitializedHook(function()
		-- local oldGetStartingSquad = getStartingSquad
		-- function getStartingSquad(choice, ...)
			-- local result = oldGetStartingSquad(choice, ...)
			
			-- if choice == 0 then
				-- local copy = {}
				-- for i, v in pairs(result) do
					-- copy[#copy+1] = v
				-- end
				
				-- for _, name in ipairs{"swarmer", "roach", "spitter", "wyrm", "crusher"} do
					-- local Name = name:gsub("^.", string.upper) -- capitalize first letter
					
					-- -- add technomechs at the end to
					-- -- enable them as random and custom mechs.
					-- if modApi.achievements:isComplete(self.id, name) then
						-- table.insert(copy, 'lmn_'.. Name)
					-- end
				-- end
				
				-- return copy
			-- end
			
			-- return result
		-- end
	-- end)
end

function mod:load(options, version)
	
	for _, name in ipairs{
		"enemy/swarmer",
		"enemy/roach",
		"enemy/spitter",
		"enemy/wyrm",
		"enemy/crusher",
		"enemy/blobberling",
		"enemy/floater",
		"enemy/shieldbot",
		"enemy/knightbot",
		"doubleSpawn",
		"secret",
	} do
		require(self.scriptPath .. name):load()
	end
end

return mod