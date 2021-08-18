
local this = {}

local pilot = {
	Id = "Pilot_lmn_Engi",
	Personality = "lmn_Engi",
	Name = "Virus", --tmp?
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

modApi.events.onFtldatFinalized:subscribe(function()
	-- make a copy of tipimage to not change replaceRepair.
	local tipImage = shallow_copy(Skill_Repair_Orig.TipImage)
	tipImage.Fire = Point(2,2) -- apply fire removed by replaceRepair.
	lmn_Engi_Repair.TipImage = tipImage
end)

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
	local id = pawn:GetId()
	local mission = GetCurrentMission()
	
	-- if not a mech, add repair_mech sound
	if id > 2 then
		ret:AddSound("/ui/map/repair_mech")
	end
	
	if
		pawn				and
		id == mission.Train	and
		mission.TrainStopped
	then
		ret:AddScript("lmn_Engi_Repair:RepairTrain(".. p2:GetString() ..")")
	end
	
	return ret
end

function this:init(mod)
	CreatePilot(pilot)
	
	require(mod.scriptPath .."personality_engi")
	
	modApi:appendAsset("img/portraits/pilots/Pilot_lmn_Engi.png", mod.resourcePath .."img/portraits/pilots/pilot_engi.png")
	modApi:appendAsset("img/portraits/pilots/Pilot_lmn_Engi_2.png", mod.resourcePath .."img/portraits/pilots/pilot_engi_2.png")
	modApi:appendAsset("img/portraits/pilots/Pilot_lmn_Engi_blink.png", mod.resourcePath .."img/portraits/pilots/pilot_engi_blink.png")
	
	require(mod.scriptPath .."replaceRepair/replaceRepair")
		:ForPilot(
			"lmn_engi_repair",
			"lmn_Engi_Repair",
			lmn_Engi_Repair.Name,
			"Repairs 2 damage.\nCan repair adjacent units."
		)
end

function this:load(modApiExt, options)
end

return this