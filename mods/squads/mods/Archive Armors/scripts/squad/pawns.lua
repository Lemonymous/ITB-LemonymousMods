
local path = GetParentPath(...)
require(path.."palette")

local mod = mod_loader.mods[modApi.currentMod]
local imageOffset = modApi:getPaletteImageOffset(mod.id)

lmn_DevastatorMech = Pawn:new{
	Name = "Devastator Mech",
	Class = "Brute",
	Health = 4,
	MoveSpeed = 2,
	Image = "aa_devastator",
	ImageOffset = imageOffset,
	SkillList = { "lmn_DevastatorCannon" },
	SoundLocation = "/mech/brute/tank/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Massive = true,
}
AddPawnName("lmn_DevastatorMech")

lmn_BomberMech = Pawn:new{
	Name = "Bomber Mech",
	Class = "Brute",
	Health = 2,
	MoveSpeed = 3,
	Image = "aa_bomber",
	ImageOffset = imageOffset,
	SkillList = { "lmn_Bombrun" },
	SoundLocation = "/mech/flying/jet_mech/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Massive = true,
	Flying = true,
}
AddPawnName("lmn_BomberMech")

lmn_SmokeMech = Pawn:new{
	Name = "APC Mech",
	Class = "Science",
	Health = 3,
	MoveSpeed = 4,
	Image = "aa_apc",
	ImageOffset = imageOffset,
	SkillList = { "lmn_SmokeLauncher" },
	SoundLocation = "/mech/brute/tank/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Massive = true,
	Armor = true,
}
AddPawnName("lmn_SmokeMech")
