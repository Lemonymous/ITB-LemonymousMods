
local mod = {
	id = "lmn_difficulty Modifiers",
	name = "Difficulty Modifiers",
	version = "1.0.4",
	enabled = false,
	icon = "img/icon.png",
	requirements = {"lmn_more_bosses"},
}

function mod:metadata()
	modApi:addGenerationOption("option_mod_spawn_start", "Starting spawns", "Modify missions' starting enemy count.", {values = {-1,0,1,2,3}, value = 0})
	modApi:addGenerationOption("option_mod_spawn_per_turn", "Spawns per turn", "Modify spawn count per turn.", {values = {-1,0,1,2,3}, value = 0})
	modApi:addGenerationOption("option_mod_spawn_max", "Max Vek on board", "Modify max simultaneous enemy count.", {values = {-1,0,1,2,3}, value = 0})
	modApi:addGenerationOption("option_random_bosses", "Random Bosses", "% of Alphas upgraded to Bosses.", {values = {0,1,5,10,25}, value = 0})
	modApi:addGenerationOption("option_non_island_vek", "Spice up Island Pool", "Convert % of Vek into Vek not in island's enemy pool.", {values = {0,1,5,10,25}, value = 0})
	modApi:addGenerationOption("option_jelly_no_touch", "Don't touch Psions", "Keep Psions as Island standard.",{enabled = false})
	modApi:addGenerationOption("option_starting_bosses", "Random Initial Bosses", "Bosses can spawn at the start of missions.",{enabled = false})
	modApi:addGenerationOption("option_delay_web", "Delay Web", "Scorpions, Leapers and Spiders won't web the turn they emerge from the ground", {enabled = false})
	modApi:addGenerationOption("option_logging_spice", "Logging (spice)", "Spice roll logs in the console.",{enabled = false})
	modApi:addGenerationOption("option_logging_boss", "Logging (boss)", "Boss roll logs in the console.",{enabled = false})
end

function mod:init()
	require(self.scriptPath .."spiderBoss")

	self.spawner = require(self.scriptPath .."spawners")
	self.delay_web = require(self.scriptPath .."delay_web")

	self.spawner:init(self)
end

function mod:load(options, version)
	self.spawner:load(self, options)
	self.delay_web:load(options)
end

return mod