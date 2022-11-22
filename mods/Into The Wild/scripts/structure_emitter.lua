
local mod = modApi:getCurrentMod()
local scriptPath = mod.scriptPath
local resourcePath = mod.resourcePath
local customEmitter = require(scriptPath.."libs/customEmitter")


modApi:appendAsset(
	"img/effects/smoke/lmn_thermal_smoke.png",
	resourcePath.."img/effects/smoke/smoke_big.png"
)

lmn_Emitter_Thermal_Plant = Emitter:new{
	image = "effects/smoke/lmn_thermal_smoke.png",
	max_alpha = 0.1,
	x = 0, y = -8, variance_x = 3, variance_y = 5,
	angle = 270, angle_variance = 60,
	timer = 1, birth_rate = 0.6, burst_count = 0, max_particles = 128,
	speed = 0.50, lifespan = 2.8, rot_speed = 10, gravity = false,
	fade_in = true, layer = LAYER_FRONT
}

BoardEvents.onUniqueBuildingCreated:subscribe(function(loc, uniqueBuildingName)
	local mission = GetCurrentMission()
	if uniqueBuildingName == "geothermal_plant" then
		customEmitter:Add(mission, loc, "lmn_Emitter_Thermal_Plant")
	end
end)

BoardEvents.onUniqueBuildingRemoved:subscribe(function(loc, uniqueBuildingName)
	local mission = GetCurrentMission()
	if uniqueBuildingName == "geothermal_plant" then
		customEmitter:Rem(mission, loc, "lmn_Emitter_Thermal_Plant")
	end
end)
