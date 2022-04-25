
local path = GetParentPath(...)
require(path.."palette")

local mod = modApi:getCurrentMod()
local imageOffset = modApi:getPaletteImageOffset(mod.id)

vw_shroud = {
	Name = "Shroud Mech",
	Class = "Prime",
	Image = "vw_shroud",
	ImageOffset = imageOffset,
	MoveSpeed = 3,
	Health = 3,
	SkillList = { "vw_Exhaust_Vents" },
	SoundLocation = "/mech/prime/punch_mech/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Massive = true,
}
AddPawn("vw_shroud")

vw_zephyr = {
	Name = "Zephyr Mech",
	Class = "Brute",
	Image = "vw_zephyr",
	ImageOffset = imageOffset,
	MoveSpeed = 4,
	Health = 2,
	SkillList = { "vw_Zephyr_Cannon" },
	SoundLocation = "/mech/distance/artillery/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Massive = true,
}
AddPawn("vw_zephyr")

vw_vortex = {
	Name = "Vortex Mech",
	Class = "Science",
	Image = "vw_vortex",
	ImageOffset = imageOffset,
	MoveSpeed = 4,
	Health = 2,
	SkillList = { "vw_Vortex_Generator" },
	SoundLocation = "/mech/science/pulse_mech/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Massive = true,
}
AddPawn("vw_vortex")
