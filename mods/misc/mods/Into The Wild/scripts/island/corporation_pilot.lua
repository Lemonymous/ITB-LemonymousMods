
local path = GetParentPath(...)
local pilot_dialog = require(path.."corporation_pilot_dialog")

local mod = modApi:getCurrentMod()
local resourcePath = mod.resourcePath

-- append pilot images
modApi:appendAsset(
	"img/portraits/npcs/lmn_jungle1.png",
	resourcePath.."img/portraits/npcs/jungle1.png"
)
modApi:appendAsset(
	"img/portraits/npcs/lmn_jungle1_2.png",
	resourcePath.."img/portraits/npcs/jungle1_2.png"
)
modApi:appendAsset(
	"img/portraits/npcs/lmn_jungle1_blink.png",
	resourcePath.."img/portraits/npcs/jungle1_blink.png"
)

-- create personality
local personality = CreatePilotPersonality("Meridia")
personality:AddDialogTable(pilot_dialog)
Personality["Meridia"] = personality

-- create pilot
CreatePilot{
	Id = "Pilot_Meridia",
	Personality = "Meridia",
	Rarity = 0,
	Cost = 1,
	Portrait = "npcs/lmn_jungle1",
	Voice = "/voice/rust",
}
