
local path = mod_loader.mods[modApi.currentMod].scriptPath
local this = {id = "Mission_lmn_Wind"}
local missionTemplates = require(path .."missions/missionTemplates")

Mission_lmn_Wind = Mission_Infinite:new{
	Name = "Windstorm",
	MapTags = {"lmn_wind"},
	BonusPool = copy_table(missionTemplates.bonusNoBlock),
	Environment = "Env_lmn_Wind",
	TurnLimit = 5,
	UseBonus = true
}
--Mission_lmn_Wind.GetCompletedStatus = missionTemplates.GetCompletedStatusEnvironment

local function addWind()
	local fx = SkillEffect()
	fx:AddEmitter(Point(3,3),"Emitter_lmn_Mission_Wind")
	fx:AddEmitter(Point(4,4),"Emitter_lmn_Mission_Wind")
	fx:AddEmitter(Point(3,3),"Emitter_lmn_Mission_Wind")
	fx:AddEmitter(Point(4,4),"Emitter_lmn_Mission_Wind")
	Board:AddEffect(fx)
end

function Mission_lmn_Wind:StartMission()
	Board:StopWeather()
end

function Mission_lmn_Wind:StartDeployment()
	addWind()
end

function Mission_lmn_Wind:ApplyEnvironmentEffect()
	if Game:GetTurnCount() == 0 then return false end
	
	return Mission.ApplyEnvironmentEffect(self)
end

function Mission_lmn_Wind:UpdateMission()
	local size = Board:GetSize()
	for x = 0, size.x - 1 do
		local loc = Point(x, size.y - 1)
		Board:MarkSpaceImage(loc, self.LiveEnvironment.CombatIcon, GL_Color(255,255,255,0.75))
		Board:MarkSpaceDesc(loc, "lmn_windstorm")
	end
end

Env_lmn_Wind = Environment:new{
	Name = "Windstorm",
	Text = "Wind storms over the board every turn, pushing each unit one tile northeast.",
	StratText = "WINDSTORM",
	CombatIcon = "combat/tile_icon/lmn_tile_wind.png",
	CombatName = "WINDSTORM",
	Planned = true,
}

function Env_lmn_Wind:Start()
end

function Env_lmn_Wind:IsEffect()
	return true
end

function Env_lmn_Wind:Voice_Push()
	if math.random() < .35 then
		local fx = SkillEffect()
		fx:AddVoice("Mission_lmn_Wind_Push", -1)
		Board:AddEffect(fx)
	end
end

function Env_lmn_Wind:ApplyEffect()
	local fx = SkillEffect()
	local dir = 0
	fx.iOwner = ENV_EFFECT
	
	fx:AddScript(string.format("Env_lmn_Wind:Voice_Push()"))
	
	fx:AddSound("/weapons/wind")
	fx:AddEmitter(Point(3,3),"Emitter_Wind_".. dir)
	fx:AddEmitter(Point(4,4),"Emitter_Wind_".. dir)
	
	local size = Board:GetSize()
	for y = 1, size.y - 1 do
		local delay
		for x = 0, size.x - 1 do
			local loc = Point(x, y)
			
			if Board:IsPawnSpace(loc) then
				fx:AddDamage(SpaceDamage(loc, 0, dir))
				delay = true
			end
		end
		
		if delay then
			fx:AddDelay(0.2)
		end
	end
	
    Board:AddEffect(fx)
	
	return false -- effects done for this turn.
end

Emitter_lmn_Mission_Wind = Emitter:new{
	image = "combat/tiles_grass/particle.png",
	x = -60,
	y = 40,
	max_alpha = 0.3,
	angle = -20,
	variance_x = 400,
	variance_y = 280,
	lifespan = 0.8,
	burst_count = 0,
	birth_rate = 0.1,
	timer = -1,
	max_particles = 1000,
	speed = 24,
	gravity = false,
	layer = LAYER_BACK
}


function this:init(mod)
	modApi:appendAsset("img/combat/tile_icon/lmn_tile_wind.png", mod.resourcePath .."img/combat/icon_wind.png")
	Location["combat/tile_icon/lmn_tile_wind.png"] = Point(-27,2)
	
	for i = 0, 5 do
		modApi:addMap(mod.resourcePath .."maps/lmn_wind".. i ..".map")
	end
	
	TILE_TOOLTIPS.lmn_windstorm = {Env_lmn_Wind.Name, Env_lmn_Wind.Text}
	Global_Texts["TipTitle_".."Env_lmn_Wind"] = Env_lmn_Wind.Name
	Global_Texts["TipText_".."Env_lmn_Wind"] = Env_lmn_Wind.Text
end

function this:load(mod, options, version)

	modApi:addPostLoadGameHook(function()
		if GetCurrentMission() then
			modApi:runLater(function(mission)
				if not mission then
					LOG("ERROR: mission not found. Not applying wind. This message should be impossible to get.")
					return
				end
				if mission.ID == this.id then
					addWind()
				end
			end)
		end
	end)
end

return this