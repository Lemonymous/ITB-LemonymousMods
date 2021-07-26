
local this = {
	desc = "Adds the Burrower Leader",
	retaliatory,
	sMission = "Mission_BurrowerBoss",
	islandLock = 4,
}

Mission_BurrowerBoss = Mission_Boss:new{
	BossPawn = "BurrowerBoss",
	SpawnStartMod = -1,
	SpawnMod = -1,
	BossText = "Destroy the Burrower Leader"
}

local function IsBurrowerBoss(pawn)
	return pawn and pawn:GetType() == _G[this.sMission].BossPawn
end

local oldGetStatusTooltip = GetStatusTooltip
function GetStatusTooltip(id, ...)
	if
		id == "burrow"					and
		this.selected					and
		IsBurrowerBoss(this.selected)
	then
		return {"Burrower", "This Vek will burrow and move unhindered to it's target."}
	end
	
	return oldGetStatusTooltip(id, ...)
end

BurrowerBoss = Pawn:new{
	Health = 6,
	Name = "Burrower Leader",
	Image = "burrower",
	ImageOffset = 2,
	MoveSpeed = 4,
	Burrows = true,	-- this flag both enables burrowing when moving
					-- as well burrowing and hiding from being damaged.
					-- so we need to add and remove it dynamically
					-- to prevent it from burrowing from damage.
	DefaultTeam = TEAM_ENEMY,
	SkillList = {"lmn_Burrower_AtkB"},
	ImpactMaterial = IMPACT_INSECT,
	SoundLocation = "/enemy/burrower_2/",
	Pushable = false,
	Portrait = "enemy/BurrowerB",
	Tier = TIER_BOSS,
}

lmn_Burrower_AtkB = Burrower_Atk2:new{
	Name = Weapon_Texts.Burrower_Atk2_Name,
	Description = Weapon_Texts.Burrower_Atk2_Description,
	Damage = 3,
	TipImage = {
		Unit = Point(2,3),
		Enemy = Point(2,2),
		Enemy2 = Point(3,2),
		Target = Point(2,2),
		CustomPawn = "BurrowerBoss",
	}
}

local function UpdateBurrow()
	if not Game or not Board then return end
	BurrowerBoss.Burrows =
		Board:GetTurn() == 0								or
		Game:GetTeamTurn() == TEAM_ENEMY					or
		(this.selected and IsBurrowerBoss(this.selected))
end

function this:init(mod)
	self.boss = require(mod.scriptPath .."boss")
	self.boss:Add(self)
	
	self.retaliatory = require(mod.scriptPath.. "retaliatory")
	self.retaliatory:init(mod)
	
	sdlext.addGameExitedHook(function()
		self.selected = nil
	end)
end

function this:load(modApiExt)
	self.retaliatory:load(modApiExt)
	self.retaliatory:AddPawnType(_G[self.sMission].BossPawn)
	
	modApiExt:addGameLoadedHook(UpdateBurrow)
	modApiExt:addResetTurnHook(UpdateBurrow)
	modApi:addNextTurnHook(UpdateBurrow)
	modApiExt:addPawnSelectedHook(function(_, pawn) this.selected = pawn; UpdateBurrow() end)
	modApiExt:addPawnDeselectedHook(function() this.selected = nil; UpdateBurrow() end)
	
	self.boss:ResetSpawnsWhenKilled(self)
	self.boss:SetSpawnsForDifficulty(
		self,
		{
			difficulty = DIFF_EASY,
			SpawnStartMod = -1,
			SpawnMod = -2
		}
	)
end

function this:ResetTips()
	self.retaliatory:ResetTips()
end

return this