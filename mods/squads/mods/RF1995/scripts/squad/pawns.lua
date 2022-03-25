
local path = GetParentPath(...)
require(path.."palette")

local mod = modApi:getCurrentMod()
local imageOffset = modApi:getPaletteImageOffset(mod.id)

lmn_HelicopterMech = Pawn:new{
	Name = "Helicopter",
	Class = "Brute",
	Health = 1,
	MoveSpeed = 4,
	Image = "rf_helicopter",
	ImageOffset = imageOffset,
	SkillList = { "lmn_Helicopter_Rocket" },
	SoundLocation = "/support/support_drone/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Flying = true,
}
AddPawnName("lmn_HelicopterMech")

lmn_TankMech = Pawn:new{
	Name = "Light Tank",
	Class = "Brute",
	Health = 2,
	MoveSpeed = 4,
	Image = "rf_tank",
	ImageOffset = imageOffset,
	SkillList = { "lmn_Tank_Cannon" },
	SoundLocation = "/support/civilian_tank/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
}
AddPawnName("lmn_TankMech")

lmn_JeepMech = Pawn:new{
	Name = "Jeep",
	Class = "Science",
	Health = 1,
	MoveSpeed = 5,
	Image = "rf_jeep",
	ImageOffset = imageOffset,
	SkillList = { "lmn_Jeep_Grenade" },
	SoundLocation = "/support/civilian_truck/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
}
AddPawnName("lmn_JeepMech")

lmn_MinelayerMech = Pawn:new{
	Name = "Rocket Artillery",
	Class = "Ranged",
	Health = 2,
	MoveSpeed = 2,
	Image = "rf_minelayer",
	ImageOffset = imageOffset,
	SkillList = { "lmn_Minelayer_Launcher", "lmn_Minelayer_Mine" },
	SoundLocation = "/support/civilian_artillery/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
}
AddPawnName("lmn_MinelayerMech")
