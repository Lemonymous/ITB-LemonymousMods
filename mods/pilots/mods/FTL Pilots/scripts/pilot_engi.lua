
local mod = modApi:getCurrentMod()
local scriptPath = mod.scriptPath
local resourcePath = mod.resourcePath
local pilotPath = "img/portraits/pilots/"
local replaceRepair = LApi.library:fetch("replaceRepair/replaceRepair")

local pilot = {
	Id = "Pilot_lmn_Engi",
	Personality = "lmn_Engi",
	Name = "Virus",
	Rarity = 1,
	Voice = "/voice/gana",
	Skill = "lmn_engi_repair",
}

lmn_Engi_Repair = Skill:new{
	Name = "Nano Repair",
	Description = "Repair a nearby unit for 2 damage and remove Fire, Ice, and A.C.I.D.",
	Amount = -2,
	PathSize = 1,
}

lmn_Engi_Repair.TipImage = shallow_copy(Skill_Repair.TipImage)

function lmn_Engi_Repair:GetTargetArea(p)
	local ret = PointList()
	ret:push_back(p)

	for dir = DIR_START, DIR_END do
		local loc = p + DIR_VECTORS[dir]
		if Board:IsValid(loc) and Board:GetPawnTeam(loc) == TEAM_PLAYER then
			ret:push_back(loc)
		end
	end

	return ret
end

function lmn_Engi_Repair:RepairTrain(p2)
	local mission = GetCurrentMission()

	local train = Board:GetPawn(mission.Train)
	if train then
		Board:RemovePawn(train)
		train = PAWN_FACTORY:CreatePawn("Train_Pawn")
		Board:AddPawn(train, mission.TrainLoc)

		mission.Train = train:GetId()
		mission.TrainStopped = false
	end
end

function lmn_Engi_Repair:GetSkillEffect(p1, p2)
	local ret = Skill_Repair_Orig.GetSkillEffect(self, p1, p2, Skill_Repair_Orig)
	local pawn = Board:GetPawn(p2)
	local pawnId = pawn:GetId()
	local mission = GetCurrentMission()

	-- if not a mech, add repair_mech sound
	if pawnId > 2 then
		ret:AddSound("/ui/map/repair_mech")
	end

	local doRepair = true
		and mission ~= nil
		and pawn ~= nil
		and pawnId == mission.Train
		and mission.TrainStopped == true

	if doRepair then
		ret:AddScript(string.format("lmn_Engi_Repair:RepairTrain(%s)", p2:GetString()))
	end

	return ret
end

CreatePilot(pilot)

require(scriptPath .."personality_engi")

modApi:appendAsset(pilotPath.."Pilot_lmn_Engi.png", resourcePath..pilotPath.."pilot_engi.png")
modApi:appendAsset(pilotPath.."Pilot_lmn_Engi_2.png", resourcePath..pilotPath.."pilot_engi_2.png")
modApi:appendAsset(pilotPath.."Pilot_lmn_Engi_blink.png", resourcePath..pilotPath.."pilot_engi_blink.png")

replaceRepair:addSkill{
	name = lmn_Engi_Repair.Name,
	description = "Repairs 2 damage.\nCan repair adjacent units.",
	weapon = "lmn_Engi_Repair",
	pilotSkill = "lmn_engi_repair",
	icon = "img/weapons/repair.png",
	iconFrozen = "img/weapons/repair_frozen.png",
}
