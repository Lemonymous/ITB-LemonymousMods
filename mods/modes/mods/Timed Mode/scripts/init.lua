
local mod = {
	id = "lmn_timed_mode",
	name = "Timed Mode",
	description = "Adds a turn timer to missions",
	version = "0.1.1",
	modApiVersion = "2.3.5",
	icon = "mod_icon.png",
	requirements = {},
}

local option_values = {
	missionTime = {"Disabled",30,60,90,120},
	turnTime = {"Disabled",10,20,30,40,50,60}
}

function mod:metadata()
	local noerror, config, error = pcall(require, self.resourcePath .."config")
	
	if noerror then
		if type(config) == 'table' then
			setmetatable(config, {__index = option_values})
			option_values = config
		end
	end
	
	modApi:addGenerationOption(
		"option_timed_mode_mission_time",
		"Mission timer",
		"Available seconds per mission.\n(Timer is paused while actions play out)",
		{
			values = option_values.missionTime,
			value = 60
		}
	)
	modApi:addGenerationOption(
		"option_timed_mode_turn_time",
		"Turn timer",
		"Additional seconds gained per turn.\n",
		{
			values = option_values.turnTime,
			value = 20
		}
	)
end

local components = {
	"timeAttack",
}

function mod:init()
	for _, subpath in ipairs(components) do
		local name = self.scriptPath .. subpath
		local comp = require(name)
		
		if type(comp) == 'table' and comp.init then
			comp:init()
		end
	end
end

function mod:load(options, version)
	for _, subpath in ipairs(components) do
		local name = self.scriptPath .. subpath
		local comp = require(name)
		
		if type(comp) == 'table' and comp.load then
			comp:load(self, options, version)
		end
	end
end

return mod