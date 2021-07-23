
local path = mod_loader.mods[modApi.currentMod].resourcePath
local attachment = require(path .."scripts/missions/assetAttachment")
local customEmitter = require(path .."scripts/customEmitter")
local prefix, suffix = "lmn_", ""

-- template
local asset = {
	Name = "Coal Plant",
	Image = "str_power1",
	Reward = REWARD_POWER
}

CreateClass(asset)

local function AddBuilding(id, loc, list)
	modApi:appendAsset("img/combat/structures/".. prefix .. id .. suffix .."_on.png", path .."img/structures/".. id .."_on.png")
	modApi:appendAsset("img/combat/structures/".. prefix .. id .. suffix .."_broken.png", path .."img/structures/".. id .."_broken.png")
	Location["combat/structures/".. prefix .. id .. suffix .."_on.png"] = loc
	Location["combat/structures/".. prefix .. id .. suffix .."_broken.png"] = loc
	
	Mission_Texts[prefix .. id .."_Name"] = list.Name
	
	_G[prefix .. id] = asset:new{Image = prefix .. id .. suffix}
	
	for i, v in pairs(list) do
		_G[prefix .. id][i] = v
	end
end

AddBuilding("geothermal_plant", Point(-21,-15), {Name = "Geothermal Plant", Reward = REWARD_POWER})
AddBuilding("lightning_rod", Point(-27,-23), {Name = "Lightning Rod", Reward = REWARD_POWER})
AddBuilding("storehouse", Point(-19,3), {Name = "Storehouse", Reward = REWARD_POWER})
AddBuilding("reserves", Point(-25,-6), {Name = "Energy Reserves", Reward = REWARD_POWER})
AddBuilding("depot", Point(-17,4), {Name = "Depot", Reward = REWARD_POWER})

AddBuilding("hydroponic_farm", Point(-24,-1), {Name = "Hydroponic Farm", Reward = REWARD_REP})
AddBuilding("observatory", Point(-19,1), {Name = "Observatory", Reward = REWARD_REP})
AddBuilding("greenhouse", Point(-23,0), {Name = "Greenhouse", Reward = REWARD_REP})
AddBuilding("outpost", Point(-24,-7), {Name = "Outpost", Reward = REWARD_REP})
AddBuilding("hotel", Point(-23,-15), {Name = "Hotel", Reward = REWARD_REP})

AddBuilding("genomicslab", Point(-19,1), {Name = "Genomics Lab", Reward = REWARD_TECH})
AddBuilding("agroforest", Point(-28,-8), {Name = "Agroforest", Reward = REWARD_TECH})

modApi:appendAsset("img/effects/smoke/lmn_thermal_smoke.png", path .."img/effects/smoke/smoke_big.png")

lmn_Emitter_Thermal_Plant = Emitter:new{
	image = "effects/smoke/lmn_thermal_smoke.png",
	max_alpha = 0.1,
	x = 0, y = -8, variance_x = 3, variance_y = 5,
	angle = 270, angle_variance = 60,
	timer = 1, birth_rate = 0.6, burst_count = 0, max_particles = 128,
	speed = 0.50, lifespan = 2.8, rot_speed = 10, gravity = false,
	fade_in = true, layer = LAYER_FRONT
}

attachment:Add{
	id = prefix .."geothermal_plant".. suffix,
	OnStart = function(mission, loc)
		customEmitter:Add(mission, loc, "lmn_Emitter_Thermal_Plant")
	end,
	OnUpdate = function(mission, loc)
		if Board:IsDamaged(loc) then
			customEmitter:Rem(mission, loc, "lmn_Emitter_Thermal_Plant")
		end
	end,
	--OnLoad = 
}