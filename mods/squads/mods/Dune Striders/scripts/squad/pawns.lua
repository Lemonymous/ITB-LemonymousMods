
local path = GetParentPath(...)
require(path.."palette")

local mod = modApi:getCurrentMod()
local imageOffset = modApi:getPaletteImageOffset(mod.id)

lmn_ds_Commando = Pawn:new{
	Name = "Commando Mech",
	Class = "Prime",
	Image = "ds_commando",
	ImageOffset = imageOffset,
	MoveSpeed = 3,
	Health = 3,
	SkillList = { "lmn_ds_PulseRifle" },
	SoundLocation = "/mech/prime/punch_mech/",
	MoveSkill = "lmn_ds_Teleport",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Massive = true,
	Teleporter = true
}
AddPawnName("lmn_ds_Commando")

lmn_ds_Gunslinger = Pawn:new{
	Name = "Gunslinger Mech",
	Class = "Brute",
	Image = "ds_gunslinger",
	ImageOffset = imageOffset,
	MoveSpeed = 3,
	Health = 2,
	SkillList = { "lmn_ds_DualPistols" },
	SoundLocation = "/mech/prime/punch_mech/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Massive = true
}
AddPawnName("lmn_ds_Gunslinger")

lmn_ds_Swoop = Pawn:new{
	Name = "Swoop Mech",
	Class = "Science",
	Image = "ds_swoop",
	ImageOffset = imageOffset,
	MoveSpeed = 4,
	Health = 2,
	SkillList = { "lmn_ds_HaulerHooks" },
	SoundLocation = "/mech/flying/jet_mech/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Massive = true,
	Flying = true
}
AddPawnName("lmn_ds_Swoop")
