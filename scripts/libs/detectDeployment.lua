
local VERSION = "0.0.1"
local STATE_READY = 0
local STATE_LANDING = 1

local function getMissionData(mission)
	if mission.deploymentState == nil then
		mission.deploymentState = {}
	end

	return mission.deploymentState
end

local function startDeploymentListener(mission)
	local deploymentState = getMissionData(mission)

	deploymentState[0] = STATE_READY
	deploymentState[1] = STATE_READY
	deploymentState[2] = STATE_READY
end

local function updateDeploymentListener(mission)
	local deploymentState = getMissionData(mission)

	if deploymentState == "done" then
		return
	end

	for pawnId, state in pairs(deploymentState) do
		local pawn = Board:GetPawn(pawnId)

		if state == STATE_READY then
			if pawn:IsBusy() then
				deploymentState[pawnId] = STATE_LANDING
				DetectDeployment.events.onPawnDeployStart:dispatch(pawn)
			end

		elseif state == STATE_LANDING then
			if not pawn:IsBusy() then
				deploymentState[pawnId] = nil
				DetectDeployment.events.onPawnDeployEnd:dispatch(pawn)
			end
		end
	end

	if next(deploymentState) == nil then
		deploymentState = "done"
	end
end

local function registerDeploymentSkill()
	DetectDeployment.events.onPawnDeployEnd:subscribe(function(pawn)
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
	DetectDeployment.events = {}
	DetectDeployment.events.onPawnDeployStart = Event()
	DetectDeployment.events.onPawnDeployEnd = Event()

	registerDeploymentSkill()

	modApi.events.onMissionStart:subscribe(startDeploymentListener)
	modApi.events.onMissionUpdate:subscribe(updateDeploymentListener)
end

local function onModsInitialized()
	local exit = false
		or DetectDeployment.initialized
		or DetectDeployment.version > VERSION

	if exit then
		return
	end

	DetectDeployment:finalizeInit()
	DetectDeployment.initialized = true
end


local isNewestVersion = false
	or DetectDeployment == nil
	or modApi:isVersion(VERSION, DetectDeployment.version) == false

if isNewestVersion then
	DetectDeployment = DetectDeployment or {}
	DetectDeployment.version = VERSION
	DetectDeployment.finalizeInit = finalizeInit

	modApi.events.onModsInitialized:subscribe(onModsInitialized)
end

return DetectDeployment
