
local path = mod_loader.mods[modApi.currentMod].resourcePath
local personality = require(path .."scripts/personality")
local dialog = require(path .."scripts/recruit_dialog")

modApi:appendAsset("img/portraits/npcs/lmn_jungle1.png", path .."img/portraits/npcs/jungle1.png")
modApi:appendAsset("img/portraits/npcs/lmn_jungle1_2.png", path .."img/portraits/npcs/jungle1_2.png")
modApi:appendAsset("img/portraits/npcs/lmn_jungle1_blink.png", path .."img/portraits/npcs/jungle1_blink.png")

Personality["lmn_Meridia_Recruit"] = personality:new{Label = "Meridia Pilot"}
Personality["lmn_Meridia_Recruit"]:AddDialog(dialog)

CreatePilot{
	Id = "Pilot_lmn_Meridia",
	Personality = "lmn_Meridia_Recruit",
	Rarity = 0,
	Cost = 1,
	Portrait = "npcs/lmn_jungle1",
	Voice = "/voice/rust",
}

return {
	Add = function()
		table.insert(Pilot_Recruits, "Pilot_lmn_Meridia")
	end
}