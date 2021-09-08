
local mod = mod_loader.mods[modApi.currentMod]
local trait = LApi.library:fetch("trait")
require(mod.scriptPath.."anims")

modApi:appendAsset("img/combat/blobB.png", mod.resourcePath.."img/combat/blob.png")
modApi:appendAsset("img/weapons/enemy_blobB.png", mod.resourcePath.."img/weapons/enemy_blobB.png")
modApi:appendAsset("img/weapons/enemy_blobberB.png", mod.resourcePath.."img/weapons/enemy_blobberB.png")
modApi:appendAsset("img/effects/shotup_blobberB.png", mod.resourcePath.."img/effects/shotup_blobberB.png")

trait:add{
	pawnType = "BlobberBoss",
	icon = "img/combat/blobB",
	icon_offset = Point(0,0),
	desc_title = "Volatile Demise",
	desc_text = "Explodes into 3 blobs on death.",
}

Mission_BlobberBoss = Mission_Boss:new{
	BossPawn = "BlobberBoss",
	BossText = "Destroy the Blobber Leader",
	GlobalSpawnMod = -2,
}

function Mission_BlobberBoss:StartMission()
	self:StartBoss()
	self:GetSpawner():BlockPawns("Blobber")
	self:GetSpawner():BlockPawns("Spider")
end

BlobberBoss = Pawn:new{
	Name = "Blobber Leader",
	Health = 5,
	MoveSpeed = 2,
	Ranged = 1,
	Image = "blobberB",
	ImageOffset = 2,
	SkillList = { "BlobberAtkB" },
	SoundLocation = "/enemy/blobber_2/",
	ImpactMaterial = IMPACT_BLOB,
	DefaultTeam = TEAM_ENEMY,
	Portrait = "enemy/BlobberB",
	Tier = TIER_BOSS,
	Massive = true,
}
AddPawnName("BlobberBoss")

function BlobberBoss:GetDeathEffect(point)
	local ret = SkillEffect()

	ret:AddScript(string.format([[
		local point = %s;
		local count = 3;
		local mission = GetCurrentMission();
		local proj_info = {
			image = "effects/shotup_blobberB.png",
			launch = "/enemy/blobber_2/attack",
			impact = "/impact/generic/blob"
		};
		mission:FlyingSpawns(
			point,
			count,
			"BlobB",
			proj_info
		);
	]], point:GetString()))

	return ret
end

BlobberAtkB = BlobberAtk2:new{
	Name = "Explosive Growths",
	Description = "Throws a monstrous blob that will explode.",
	Icon = "weapons/enemy_blobberB.png",
	MyPawn = "BlobB",
	MyArtillery = "effects/shotup_blobberB.png",
	TipImage = add_tables(
		BlobberAtk2.TipImage,
		{ CustomPawn = "BlobberBoss" }
	)
}

BlobB = Blob2:new{
	Name = "Leader Blob",
	ImageOffset = 2,
	SkillList = { "BlobAtkB" },
	Portrait = "enemy/BlobB",
	Tier = TIER_BOSS,
}

BlobAtkB = BlobAtk2:new{
	Name = "Explosive Guts",
	Description = "Explode, killing itself and damaging adjacent tiles. Kill it first to stop it.",
	Icon = "weapons/enemy_blobB.png",
	TipImage = add_tables(
		BlobAtk2.TipImage,
		{ CustomPawn = "BlobB" }
	)
}
