
local VERSION = "1.0.2"
local STATE_SELECTED = 0
local STATE_REMAINING = 1
local STATE_DEPLOYED = 2
local STATE_LANDING = 3
local STATE_LANDED = 4
local PHASE_DEPLOYMENT = 0
local PHASE_LANDING = 1
local PHASE_LANDED = 2
local OUT_OF_BOUNDS = Point(-1,-1)
local EVENTS = {
	"onDeploymentPhaseStart",
	"onLandingPhaseStart",
	"onDeploymentPhaseEnd",
	"onPawnUnselected",
	"onPawnSelected",
	"onPawnDeployed",
	"onPawnUndeployed",
	"onPawnLanding",
	"onPawnLanded",
}

-- reusable tables
local prev = {
	[0] = {},
	[1] = {},
	[2] = {},
}
local mechs = {
	[0] = {},
	[1] = {},
	[2] = {},
}

local function initEvents()
	if DetectDeployment.events == nil then
		DetectDeployment.events = {}
	end

	for _, eventId in ipairs(EVENTS) do
		if DetectDeployment.events[eventId] == nil then
			DetectDeployment.events[eventId] = Event()
		end
	end
end

local function getMissionData(mission)
	return mission.deployment or {}
end

local function updateDeploymentListener(mission)
	local deployment = getMissionData(mission)

	if not deployment.in_progress then
		return
	end

	if deployment.phase == PHASE_DEPLOYMENT then
		local pwn0 = Board:GetPawn(0)
		local pwn1 = Board:GetPawn(1)
		local pwn2 = Board:GetPawn(2)

		local prev = prev
		prev[0].state = deployment[0].state
		prev[1].state = deployment[1].state
		prev[2].state = deployment[2].state

		local mechs = mechs
		mechs[0].loc = pwn0:GetSpace()
		mechs[1].loc = pwn1:GetSpace()
		mechs[2].loc = pwn2:GetSpace()
		mechs[0].isSelected = pwn0:IsSelected()
		mechs[1].isSelected = pwn1:IsSelected()
		mechs[2].isSelected = pwn2:IsSelected()

		for pawnId = 0, 2 do
			local mech = mechs[pawnId]
			if mech.isSelected then
				mech.state = STATE_SELECTED
			elseif mech.loc == OUT_OF_BOUNDS then
				mech.state = STATE_REMAINING
			else
				mech.state = STATE_DEPLOYED
			end
		end

		local isNoneSelected = true
			and mechs[0].state ~= STATE_SELECTED
			and mechs[1].state ~= STATE_SELECTED
			and mechs[2].state ~= STATE_SELECTED

		if isNoneSelected then
			for pawnId = 0, 2 do
				local mech = mechs[pawnId]
				if mech.state == STATE_REMAINING then
					mech.state = STATE_SELECTED
					break
				end
			end
		end

		for pawnId = 0, 2 do
			local mech = mechs[pawnId]
			local saved = deployment[pawnId]
			saved.state = mech.state
		end

		for pawnId = 0, 2 do
			local mech = mechs[pawnId]
			local prev = prev[pawnId]
			if mech.state ~= prev.state then
				if prev.state == STATE_DEPLOYED then
					DetectDeployment.events.onPawnUndeployed:dispatch(pawnId)
				elseif prev.state == STATE_SELECTED then
					DetectDeployment.events.onPawnUnselected:dispatch(pawnId)
				end

				if mech.state == STATE_DEPLOYED then
					DetectDeployment.events.onPawnDeployed:dispatch(pawnId)
				elseif mech.state == STATE_SELECTED then
					DetectDeployment.events.onPawnSelected:dispatch(pawnId)
				end
			end
		end

		local isAllDeployed = true
			and mechs[0].state == STATE_DEPLOYED
			and mechs[1].state == STATE_DEPLOYED
			and mechs[2].state == STATE_DEPLOYED
			and pwn0:IsBusy()

		if isAllDeployed then
			deployment.phase = PHASE_LANDING
			DetectDeployment.events.onLandingPhaseStart:dispatch()
		end
	end

	if deployment.phase == PHASE_LANDING then
		for pawnId = 0, 2 do
			local mech = deployment[pawnId]
			local pawn = Board:GetPawn(pawnId)

			if mech.state == STATE_DEPLOYED then
				if pawn:IsBusy() then
					mech.state = STATE_LANDING
					DetectDeployment.events.onPawnLanding:dispatch(pawnId)
				end

			elseif mech.state == STATE_LANDING then
				if not pawn:IsBusy() then
					mech.state = STATE_LANDED
					DetectDeployment.events.onPawnLanded:dispatch(pawnId)
				end
			end
		end

		local isAllLanded = true
			and deployment[0].state == STATE_LANDED
			and deployment[1].state == STATE_LANDED
			and deployment[2].state == STATE_LANDED

		if isAllLanded then
			deployment.in_progress = false
			deployment.phase = PHASE_LANDED
			DetectDeployment.events.onDeploymentPhaseEnd:dispatch()
		end
	end
end

local function startDeploymentListener(mission)
	mission.deployment = {
		in_progress = true,
		phase = PHASE_DEPLOYMENT,
		[0] = { state = STATE_REMAINING },
		[1] = { state = STATE_REMAINING },
		[2] = { state = STATE_REMAINING },
	}

	DetectDeployment.events.onDeploymentPhaseStart:dispatch()
end

local function isDeploymentPhase(self)
	local mission = GetCurrentMission()
	if mission == nil then return false end

	return getMissionData(mission).in_progress == true
end

local function isLandingPhase(self)
	local mission = GetCurrentMission()
	if mission == nil then return false end

	return getMissionData(mission).phase == PHASE_LANDING
end

local function getSelected(self)
	local mission = GetCurrentMission()
	if mission == nil then return nil end

	local deployment = getMissionData(mission)

	if deployment.in_progress then
		for pawnId = 0, 2 do
			local mech = deployment[pawnId]
			if mech.state == STATE_SELECTED then
				return pawnId
			end
		end
	end

	return nil
end

local function getDeployed(self)
	local mission = GetCurrentMission()
	if mission == nil then return {} end

	local deployment = getMissionData(mission)
	local deployed = {}

	if deployment.in_progress then
		for pawnId = 0, 2 do
			if deployment[pawnId].state == STATE_DEPLOYED then
				table.insert(deployed, pawnId)
			end
		end
	end

	return deployed
end

local function getRemaining(self)
	local mission = GetCurrentMission()
	if mission == nil then return {} end

	local deployment = getMissionData(mission)
	local remaining = {}

	if deployment.in_progress then
		for pawnId = 0, 2 do
			if deployment[pawnId].state == STATE_REMAINING then
				table.insert(remaining, pawnId)
			end
		end
	end

	return remaining
end

local function registerDeploymentSkill()
	DetectDeployment.events.onPawnLanded:subscribe(function(pawnId)
		local pawn = Board:GetPawn(pawnId)
		local pawnType = pawn:GetType()
		local deploySkill = _G[pawnType].DeploySkill

		local isValidDeploySkill = true
			and type(deploySkill) == 'string'
			and type(_G[deploySkill]) == 'table'
			and type(_G[deploySkill].GetSkillEffect) == 'function'

		if isValidDeploySkill then
			local Pawn_bak = Pawn; Pawn = pawn
			local p2 = pawn:GetSpace()
			local fx = _G[deploySkill]:GetSkillEffect(p2, p2)

			for eventIndex = 1, fx.effect:size() do
				local event = fx.effect:index(eventIndex)
				Board:DamageSpace(event)
			end

			Pawn = Pawn_bak
		end
	end)
end

local function finalizeInit(self)
	registerDeploymentSkill()

	modApi.events.onMissionStart:subscribe(startDeploymentListener)
	modApi.events.onMissionUpdate:subscribe(updateDeploymentListener)
end

local function onModsInitialized()
	local isHighestVersion = true
		and DetectDeployment.initialized ~= true
		and DetectDeployment.version == VERSION

	if isHighestVersion then
		DetectDeployment:finalizeInit()
		DetectDeployment.initialized = true
		DetectDeployment.isDeploymentPhase = isDeploymentPhase
		DetectDeployment.isLandingPhase = isLandingPhase
		DetectDeployment.getSelected = getSelected
		DetectDeployment.getDeployed = getDeployed
		DetectDeployment.getRemaining = getRemaining
	end
end


local isNewerVersion = false
	or DetectDeployment == nil
	or VERSION > DetectDeployment.version

if isNewerVersion then
	DetectDeployment = DetectDeployment or {}
	DetectDeployment.version = VERSION
	DetectDeployment.finalizeInit = finalizeInit

	initEvents()

	modApi.events.onModsInitialized:subscribe(onModsInitialized)
end

return DetectDeployment
