
local path = mod_loader.mods[modApi.currentMod].resourcePath
local this = {id = "Mission_lmn_Geyser"}
local missionTemplates = require(path .."scripts/missions/missionTemplates")
local customEmitter = require(path .."scripts/customEmitter")
local worldConstants = require(path.. "scripts/worldConstants")
local utils = require(path.. "scripts/utils")

modApi:appendAsset("img/effects/smoke/lmn_geyser_spray.png", path .. "img/effects/smoke/geyser_spray.png")

local rise = Emitter:new{
	image = "effects/smoke/lmn_geyser_spray.png",
	max_alpha = 0.3, min_alpha = 0.0,
	x = 0, y = 25, variance_x = 8, variance_y = 6,
	angle = 0, angle_variance = 360,
	timer = .005, birth_rate = .01, burst_count = 5, max_particles = 128,
	speed = .40, lifespan = 2.0, rot_speed = 20, gravity = false,
	layer = LAYER_FRONT
}

local cloud = Emitter:new{
	image = "effects/smoke/art_smoke.png",
	max_alpha = 0.2,
	x = 0, y = 25, variance_x = 2, variance_y = 8,
	angle = 240, angle_variance = 50,
	timer = .005, birth_rate = .07, burst_count = 5, max_particles = 64,
	speed = 1.25, lifespan = 2.0, gravity = false,
	layer = LAYER_FRONT
}

for k = 1, 8 do
	_G["lmn_Geyser_Cloud".. k] = cloud:new{
		y = 25 - cloud.variance_y * k / 2, variance_y = cloud.variance_y * k,
		timer = cloud.timer * k
	}
	_G["lmn_Geyser_Rise".. k] = rise:new{
		y = 25 - 8 * k,
		timer = rise.timer * k
	}
end

local angle_variance = 5
local angle = 270 + angle_variance / 2

lmn_Geyser_Spray = rise:new{
	x = 0, y = 20, variance_x = 8, variance_y = 6,
	angle = angle, angle_variance = angle_variance,
	timer = 2, birth_rate = .01, burst_count = 20, max_particles = 128,
	speed = 8.00, lifespan = .30,
}

Mission_lmn_Geyser = Mission_Infinite:new{
	Name = "Geyser",
	MapTags = {"lmn_geyser"},
	BonusPool = copy_table(missionTemplates.bonusNoBlock),
	Environment = "Env_lmn_Geyser",
	UseBonus = true,
	SpawnStartMod = 1,
	SpawnMod = 2,
}
Mission_lmn_Geyser.GetCompletedStatus = missionTemplates.GetCompletedStatusEnvironment

function Mission_lmn_Geyser:StartMission()
	local zone = extract_table(Board:GetZone("geyser"))
	
	for _, p in ipairs(zone) do
		Board:SetCustomTile(p, "lmn_ground_geyser.png")
		Board:BlockSpawn(p, BLOCKED_PERM)
	end
	
	Board:StopWeather()
end

Env_lmn_Geyser = Env_Attack:new{
	Image = "lmn_geyser_eruption",
	Name = "Active Geysers",
	Text = "Geysers will erupt sporadically, launching units to a random location which will turn into water.",
	StratText = "GEYSER",
	CombatIcon = "combat/tile_icon/lmn_tile_geyser.png",
	CombatName = "GEYSER",
	chance = .5
}

function Env_lmn_Geyser:MarkSpace(loc, active)
	Board:MarkSpaceImage(loc, self.CombatIcon, GL_Color(255,226,88,0.75))
	Board:MarkSpaceDesc(loc, "lmn_geyser")
	
	if active then
		Board:MarkSpaceImage(loc, self.CombatIcon, GL_Color(255,150,150,0.75))
	end
end

function Env_lmn_Geyser:GetAttackEffect(loc)
	local fx = SkillEffect()
	fx.iOwner = ENV_EFFECT
	
	-- TODO: figure out a better system than this mess?
	-- emitter might crash the game since it adds functions to the mission table.
	-- also might not since I am unsure if it saves during the effect.
	-- customEmitter code is potentially crash inducing in any case, and needs to be changed.
	
	local function reverse_cloudUpdate(loc, emitter)
		local i = tonumber(emitter:sub(-1,-1))
		if i > 1 then
			i = i - 1
			customEmitter:Add(nil, loc, "lmn_Geyser_Cloud".. i, nil, reverse_cloudUpdate)
		end
		
		return false
	end
	
	local maxClouds = 50
	local function cloudUpdate(loc, emitter)
		local i = tonumber(emitter:sub(-1,-1))
		if i < 8 then
			i = i + 1
			customEmitter:Add(nil, loc, "lmn_Geyser_Cloud".. i, nil, cloudUpdate)
			
		elseif maxClouds > 0 then
			maxClouds = maxClouds - 1
			return true
		else
			customEmitter:Add(nil, loc, "lmn_Geyser_Cloud8", nil, reverse_cloudUpdate)
		end
		
		return false
	end
	
	local function riseUpdate(loc, emitter)
		local i = tonumber(emitter:sub(-1,-1))
		if i < 8 then
			i = i + 1
			customEmitter:Add(nil, loc, "lmn_Geyser_Rise".. i, nil, riseUpdate)
		end
		
		return false
	end
	
	-- extinguish fire.
	local d = SpaceDamage(loc)
	d.iFire = 2
	Board:DamageSpace(d)
	
	fx:AddEmitter(loc, "lmn_Geyser_Spray")
	customEmitter:Add(nil, loc, "lmn_Geyser_Rise1", nil, riseUpdate)
	customEmitter:Add(nil, loc, "lmn_Geyser_Cloud1", nil, cloudUpdate)
	fx:AddSound("/props/tide_flood")
	
	local zone = extract_table(Board:GetZone("geyser"))
	local board = utils.getBoard()
	local pawn = Board:GetPawn(loc)
	local dest = loc
	
	utils.shuffle(board)
	for _, p in ipairs(board) do
		local terrain = Board:GetTerrain(p)
		if
			not Board:IsBlocked(p, PATH_PROJECTILE)	and
			terrain ~= TERRAIN_HOLE					and
			not Board:IsPod(p)						and
			not Board:IsSpawning(p)					and
			not list_contains(zone, p)
			-- TODO: maybe filter out more locations.
		then
			dest = p
			break
		end
	end
	
	local vacant = utils.getSpace(function(p)
		return not Board:IsPawnSpace(p) and p ~= dest and p ~= loc
	end)
	
	pawn = vacant and pawn or nil
	if pawn and pawn:IsGuarding() then
		pawn = nil
	end
	
	if pawn then
		local pawnId = pawn:GetId()
		
		local leap = PointList()
		leap:push_back(loc)
		leap:push_back(vacant)
		
		worldConstants.SetHeight(fx, 50)
		fx:AddLeap(leap, NO_DELAY)
		worldConstants.ResetHeight(fx)
		
		fx:AddDelay(.50)
		fx:AddScript(string.format("Board:GetPawn(%s):SetSpace(Point(-1,-1))", pawnId))
		fx:AddScript(string.format("Board:GetPawn(%s):SetSpace(%s)", pawnId, vacant:GetString()))
		fx:AddScript(string.format("Board:GetPawn(%s):SetInvisible(true)", pawnId))
		
		local leap = PointList()
		leap:push_back(vacant)
		leap:push_back(dest)
		
		worldConstants.SetHeight(fx, 50)
		fx:AddLeap(leap, NO_DELAY)
		worldConstants.ResetHeight(fx)
		
		---- voice ----
		if pawn:IsEnemy() then
			fx:AddVoice("Mission_lmn_Geyser_Launch_Vek", -1)
		elseif pawn:IsMech() then
			fx:AddVoice("Mission_lmn_Geyser_Launch_Mech", pawn:GetId())
		end
		---- ----- ----
		
		fx:AddDelay(0.25)
		fx:AddScript(string.format("Board:GetPawn(%s):SetInvisible(false)", pawnId))
	else
		fx:AddDelay(0.75)
	end
	
	local weather = {
		{delay = 0.0, intensity = 1, duration = 5.0},
		{delay = 0.75, flood = true},
		{delay = 0.90, intensity = 20, duration = 0.5},
		{delay = 0.30, splash = true}
	}
	
	for i, v in ipairs(weather) do
		if v.delay then
			fx:AddDelay(v.delay)
		end
		
		if v.intensity and v.duration then
			fx:AddScript(string.format("Board:SetWeather(%s, 0, %s, Point(1,1), %s)", v.intensity, dest:GetString(), v.duration))
		end
		
		if v.flood then
			-- hack to force water to sink slowly.
			local flood = SpaceDamage(dest)
			flood.bHide = true
			flood.iTerrain = TERRAIN_LAVA
			fx:AddDamage(flood)
			
			if not isAcid then
				fx:AddScript(string.format("Board:SetLava(%s, false)", dest:GetString()))
				if pawn then
					local unacid = SpaceDamage(dest)
					unacid.bHide = true
					unacid.iAcid = EFFECT_REMOVE
					fx:AddDamage(unacid)
				end
			end
		end
		
		if v.splash then
			local splash = SpaceDamage(dest)
			splash.sAnimation = "splash"
			splash.sSound = "/props/tide_flood_last"
			fx:AddDamage(splash)
		end
	end
	
	Board:BlockSpawn(dest, BLOCKED_PERM)
	
	return fx
end

function Env_lmn_Geyser:SelectSpaces()
	local ret = {}
	local zone = extract_table(Board:GetZone("geyser"))
	
	for _, p in ipairs(zone) do
		if math.random() < self.chance then
			ret[#ret+1] = p
		end
	end
	
	return ret
end

function Env_lmn_Geyser:Plan()
	local ret = Env_Attack.Plan(self)
	
	for _, p in ipairs(self.Planned) do
		Board:BlockSpawn(p, BLOCKED_PERM)
	end
	
	return ret
end

function this:init(mod)
	modApi:appendAsset("img/combat/tiles_grass/lmn_ground_geyser.png", mod.resourcePath .."img/tileset_plant/ground_geyser.png")
	modApi:appendAsset("img/combat/tile_icon/lmn_tile_geyser.png", mod.resourcePath .."img/combat/icon_geyser.png")
	Location["combat/tile_icon/lmn_tile_geyser.png"] = Point(-27,2)
	
	TILE_TOOLTIPS.lmn_geyser = {"Geyser", "Geyser is about to erupt, launching any unit there to a vacant tile and turning it to water."}
	Global_Texts["TipTitle_".."Env_lmn_Geyser"] = Env_lmn_Geyser.Name
	Global_Texts["TipText_".."Env_lmn_Geyser"] = Env_lmn_Geyser.Text
	
	for i = 0, 10 do
		modApi:addMap(mod.resourcePath .."maps/lmn_geyser".. i ..".map")
	end
end

function this:load(mod, options, version)

end

return this