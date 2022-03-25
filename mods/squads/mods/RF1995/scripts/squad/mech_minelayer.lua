
local mod = modApi:getCurrentMod()
local imageOffset = modApi:getPaletteImageOffset(mod.id)

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
