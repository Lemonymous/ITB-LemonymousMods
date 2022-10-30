
Assert.NotEquals(nil, memedit, "Library requires memedit")
Assert.NotEquals(nil, DetectDeployment, "Library requires detectDeployment")

local VERSION = "1.0.0"
local DEPLOYMENT_X = "combat/deployment_x_water.png"
local DEPLOYMENT_X_COLOR = GL_Color(255, 150, 140, 1)
local DEPLOYMENT_TILE_COLOR = GL_Color(255, 50, 50, 0.75)
local DEFAULT_DEPLOYMENT_ZONE = {}
for x = 1, 3 do
	for y = 1, 6 do
		table.insert(DEFAULT_DEPLOYMENT_ZONE, Point(x,y))
	end
end

local function updateDeploymentUi()
	if DetectDeployment:isDeploymentPhase() == false then
		return
	end

	local selectedPawnId = DetectDeployment:getSelected()

	if selectedPawnId == nil then
		return
	end

	local selectedPawn = Board:GetPawn(selectedPawnId)
	local origin = selectedPawn:GetSpace()
	local target = Board:GetHighlighted()
	local targetPawn = Board:GetPawn(target)

	local deploymentZone = extract_table(Board:GetZone("deployment"))
	if #deploymentZone == 0 then
		deploymentZone = DEFAULT_DEPLOYMENT_ZONE
	end

	local isWaterDangerousToSelected = true
		and selectedPawn:IsFlying() == false
		and selectedPawn:IsMassive() == false

	if isWaterDangerousToSelected then
		for _, loc in ipairs(deploymentZone) do
			if Board:GetTerrain(loc) == TERRAIN_WATER then
				Board:MarkSpaceImage(loc, DEPLOYMENT_X, DEPLOYMENT_X_COLOR)
				Board:MarkSpaceSimpleColor(loc, DEPLOYMENT_TILE_COLOR)
			end
		end
	elseif targetPawn and Board:GetTerrain(origin) == TERRAIN_WATER then
		local isWaterDangerousToTarget = true
			and targetPawn:IsFlying() == false
			and targetPawn:IsMassive() == false

		if isWaterDangerousToTarget then
			Board:MarkSpaceImage(origin, DEPLOYMENT_X, DEPLOYMENT_X_COLOR)
			Board:MarkSpaceSimpleColor(origin, DEPLOYMENT_TILE_COLOR)
		end
	end
end

local function createClickBlocker(screen, uiRoot)
	local clickBlocker = Ui()
		:width(1):height(1)
		:setTranslucent()
		:addTo(uiRoot)

	function clickBlocker:mousedown(mx, my, button)
		local exitEarly = false
			or button ~= 1
			or DetectDeployment:isDeploymentPhase() == false

		if exitEarly then
			return false
		end

		local blockClick = false
		local selectedPawnId = DetectDeployment:getSelected()

		if selectedPawnId then
			local selectedPawn = Board:GetPawn(selectedPawnId)
			local origin = selectedPawn:GetSpace()
			local originIsWater = Board:GetTerrain(origin) == TERRAIN_WATER
			local target = Board:GetHighlighted()
			local targetPawn = Board:GetPawn(target)
			local targetIsWater = Board:GetTerrain(target) == TERRAIN_WATER

			local isWaterDangerousToSelected = true
				and selectedPawn:IsFlying() == false
				and selectedPawn:IsMassive() == false

			local isWaterDangerousToTarget = true
				and targetPawn ~= nil
				and targetPawn:IsFlying() == false
				and targetPawn:IsMassive() == false

			if isWaterDangerousToSelected and targetIsWater then
				blockClick = true
			elseif isWaterDangerousToTarget and originIsWater then
				blockClick = true
			end
		end

		return blockClick
	end
end

local function finalizeInit(self)
	modApi:copyAsset("img/combat/deployment_x.png", "img/combat/deployment_x_water.png")
	Location["combat/deployment_x_water.png"] = Point(-13,8)

	modApi.events.onMissionUpdate:subscribe(updateDeploymentUi)
	modApi.events.onUiRootCreated:subscribe(createClickBlocker)
end

local function onModsInitialized()
	local isHighestVersion = true
		and BlockDeathByDeployment.initialized ~= true
		and BlockDeathByDeployment.version == VERSION

	if isHighestVersion then
		BlockDeathByDeployment:finalizeInit()
		BlockDeathByDeployment.initialized = true
	end
end


local isNewerVersion = false
	or BlockDeathByDeployment == nil
	or VERSION > DetectDeployment.version

if isNewerVersion then
	BlockDeathByDeployment = BlockDeathByDeployment or {}
	BlockDeathByDeployment.version = VERSION
	BlockDeathByDeployment.finalizeInit = finalizeInit

	modApi.events.onModsInitialized:subscribe(onModsInitialized)
end
