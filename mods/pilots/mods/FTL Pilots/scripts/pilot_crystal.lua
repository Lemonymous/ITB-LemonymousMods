
local mod = modApi:getCurrentMod()
local scriptPath = mod.scriptPath
local resourcePath = mod.resourcePath
local pilotPath = "img/portraits/pilots/"
local tooltip = require(scriptPath.."pilotSkill_tooltip")

local pilot = {
	Id = "Pilot_lmn_Crystal",
	Personality = "Rock",
	Name = "Ruwen",
	Rarity = 1,
	Voice = "/voice/ariadne",
	Skill = "Freeze_Walk",
}

CreatePilot(pilot)

tooltip.Add(
	"Freeze_Walk",
	PilotSkill(
		"Crystallize",
		"Stopping on any liquid tile crytallizes it, making it safe to stand on."
	)
)

modApi:appendAsset(pilotPath.."Pilot_lmn_Crystal.png", resourcePath..pilotPath.."pilot_crystal.png")
modApi:appendAsset(pilotPath.."Pilot_lmn_Crystal_2.png", resourcePath..pilotPath.."pilot_crystal_2.png")
modApi:appendAsset(pilotPath.."Pilot_lmn_Crystal_blink.png", resourcePath..pilotPath.."pilot_crystal_blink.png")
