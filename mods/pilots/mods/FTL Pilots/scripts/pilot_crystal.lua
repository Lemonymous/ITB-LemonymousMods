
local this = {}

local pilot = {
	Id = "Pilot_lmn_Crystal",
	Personality = "Rock",
	Name = "Ruwen",
	Rarity = 1,
	Voice = "/voice/ariadne",
	Skill = "Freeze_Walk",
}

function this:init(mod)
	CreatePilot(pilot)
	
	require(mod.scriptPath .."pilotSkill_tooltip").Add("Freeze_Walk", PilotSkill("Crystallize", "Stopping on any liquid tile crytallizes it, making it safe to stand on."))
	
	modApi:appendAsset("img/portraits/pilots/Pilot_lmn_Crystal.png", mod.resourcePath .."img/portraits/pilots/pilot_crystal.png")
	modApi:appendAsset("img/portraits/pilots/Pilot_lmn_Crystal_2.png", mod.resourcePath .."img/portraits/pilots/pilot_crystal_2.png")
	modApi:appendAsset("img/portraits/pilots/Pilot_lmn_Crystal_blink.png", mod.resourcePath .."img/portraits/pilots/pilot_crystal_blink.png")
end

function this:load(modApiExt, options)

end

return this