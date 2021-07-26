
local mod = {
	id = "lmn_more_bosses",
	name = "More Bosses",
	description = "Adds up to 7 bosses.",
	version = "1.4.4",
	modApiVersion = "2.3.0",
	icon = "img/mod_icon.png",
	requirements = {},
}

local function final(options)
	local str =
	{
		["option_Mission_CrabBoss"] = "CrabBoss",
		["option_Mission_ScarabBoss"] = "ScarabBoss",
		["option_Mission_LeaperBoss"] = "LeaperBoss",
		["option_Mission_BlobberBoss"] = "BlobberBoss",
		["option_Mission_CentipedeBoss"] = "CentipedeBoss",
		["option_Mission_DiggerBoss"] = "DiggerBoss",
		["option_Mission_BurrowerBoss"] = "BurrowerBoss",
	}
	for id, boss in pairs(str) do
		if	not options[id].enabled								or
			not options["option_add_bosses_to_final"].enabled	then
			
			remove_element(boss, Mission_Final.BossList)
			remove_element(boss, Mission_Final_Cave.BossList)
		else
			if not list_contains(Mission_Final.BossList, boss) then
				table.insert(Mission_Final.BossList, boss)
			end
			if not list_contains(Mission_Final_Cave.BossList, boss) then
				table.insert(Mission_Final_Cave.BossList, boss)
			end
		end
	end
end

function mod:init()
	self.modApiExt = require(self.scriptPath .."modApiExt/modApiExt")
	self.modApiExt:init()
	
	lmn_MB_CUtils = require(self.scriptPath .."libs/CUtils")
	
	self.crab =			require(self.scriptPath.. "missions/bosses/crab")
	self.scarab =		require(self.scriptPath.. "missions/bosses/scarab")
	self.leaper =		require(self.scriptPath.. "missions/bosses/leaper")
	self.blobber =		require(self.scriptPath.. "missions/bosses/blobber")
	self.centipede =	require(self.scriptPath.. "missions/bosses/centipede")
	self.digger =		require(self.scriptPath.. "missions/bosses/digger")
	self.burrower =		require(self.scriptPath.. "missions/bosses/burrower")
	
	self.crab:init(self)
	self.centipede:init(self)
	self.blobber:init(self)
	self.scarab:init(self)
	self.leaper:init(self)
	self.digger:init(self)
	self.burrower:init(self)
	
	modApi:addGenerationOption("option_add_bosses_to_final", "Final Mission", "Expand the final mission boss pool.", {})
	modApi:addGenerationOption("option_reset_tips", "Reset Tutorial Tips", "Resets the tutorial tips.", {enabled = false})
end

function mod:load(options, version)
	self.modApiExt:load(self, options, version)
	
	self.crab:load()
	self.centipede:load()
	self.blobber:load()
	self.scarab:load(self.modApiExt)
	self.leaper:load(self.modApiExt)
	self.digger:load(self.modApiExt)
	self.burrower:load(self.modApiExt)
	
	--leaper.smokeCancel(options["option_smoked_leaper"].enabled)
	
	require(self.scriptPath .."boss"):load(options)
	final(options)
	
	if options["option_reset_tips"].enabled then
		self.leaper:ResetTips()
		self.burrower:ResetTips()
		options["option_reset_tips"].enabled = false
	end
end

return mod