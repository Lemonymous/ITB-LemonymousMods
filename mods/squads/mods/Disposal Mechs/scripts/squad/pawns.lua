
local path = GetParentPath(...)
require(path.."palette")

local mod = mod_loader.mods[modApi.currentMod]
local imageOffset = modApi:getPaletteImageOffset(mod.id)

lmn_StackerMech = Pawn:new{
	Name = "Stacker Mech",
	Class = "Prime",
	Health = 3,
	MoveSpeed = 3,
	Image = "dm_stacker",
	ImageOffset = imageOffset,
	SkillList = { "lmn_LiftAtk" },
	SoundLocation = "/mech/prime/punch_mech/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Massive = true,
}
AddPawnName("lmn_StackerMech")

lmn_DozerMech = Pawn:new{
	Name = "Dozer Mech",
	Class = "Brute",
	Health = 3,
	MoveSpeed = 3,
	Image = "dm_dozer",
	ImageOffset = imageOffset,
	SkillList = { "lmn_DozerAtk" },
	SoundLocation = "/mech/brute/tank/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Massive = true,
}
AddPawnName("lmn_DozerMech")

lmn_ChemMech = Pawn:new{
	Name = "Dissolver Mech",
	Class = "Science",
	Health = 3,
	MoveSpeed = 3,
	Image = "dm_dissolver",
	ImageOffset = imageOffset,
	SkillList = { "lmn_ChemicalAtk" },
	SoundLocation = "/mech/science/pulse_mech/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Massive = true,
}
AddPawnName("lmn_ChemMech")
