
local path = mod_loader.mods[modApi.currentMod].scriptPath
local this = {id = "Mission_lmn_Volcanic_Vents"}
local missionTemplates = require(path .."missions/missionTemplates")

Mission_lmn_Volcanic_Vents = Mission_Infinite:new{
	Name = "Volcanic Vents",
	MapTags = {"lmn_volcanic_vent"},
	BonusPool = copy_table(missionTemplates.bonusNoBlock),
	Environment = "Env_lmn_Volcanic_Vents",
	UseBonus = true,
	SpawnStartMod = 1,
	SpawnMod = 2,
}
--Mission_lmn_Volcanic_Vents.GetCompletedStatus = missionTemplates.GetCompletedStatusEnvironment

function Mission_lmn_Volcanic_Vents:StartMission()
	local zone = extract_table(Board:GetZone("volcanic_vent"))
	
	for _, p in ipairs(zone) do
		Board:BlockSpawn(p, BLOCKED_PERM)
	end
	
	Board:StopWeather()
end

Env_lmn_Volcanic_Vents = Env_Attack:new{
	Image = "lmn_volcanic_eruption",
	Name = "Volcanic Vents",
	Text = "Volcanic Vents will erupt sporadically, killing any unit on the marked tiles.",
	StratText = "VOLCANIC VENTS",
	CombatIcon = "combat/tile_icon/lmn_tile_volcanic_vent.png",
	CombatName = "VOLCANIC VENT",
	chance = 50,
}

function Env_lmn_Volcanic_Vents:MarkSpace(loc, active)
	Board:MarkSpaceImage(loc, self.CombatIcon, GL_Color(255,226,88,0.75))
	
	-- one user reported that MarkSpaceDesc did not have a function with 3 parameteres.
	-- attempting to solve this by checking if the constant EFFECT_DEADLY exists.
	if EFFECT_DEADLY then
		Board:MarkSpaceDesc(loc, "lmn_volcanic_vent", EFFECT_DEADLY)
	else
		Board:MarkSpaceDesc(loc, "lmn_volcanic_vent")
	end
	
	if active then
		Board:MarkSpaceImage(loc, self.CombatIcon, GL_Color(255,150,150,0.75))
	end
end

function Env_lmn_Volcanic_Vents:GetAttackEffect(loc)
	local effect = SkillEffect()
	effect.iOwner = ENV_EFFECT
	
	--damage.sAnimation = self.Image --TODO: make better volcano eruption anim
	effect:AddScript("Board:AddAnimation(".. loc:GetString() ..",'".. self.Image .."', ANIM_NO_DELAY)")
	
	effect:AddSound("/weapons/flamethrower") --TODO: find volcano sound
	effect:AddEmitter(loc, "lmn_Emitter_Volcanic_Vent")
	
	local pawn = Board:GetPawn(loc)
	if pawn and pawn:IsEnemy() then
		effect:AddVoice("Mission_lmn_Volcanic_Vent_Erupt_Vek", -1)
	end
	
	effect:AddDamage(SpaceDamage(loc, DAMAGE_DEATH))
	effect:AddDelay(1.50)
	
	--local script = "Board:SetWeather(20,0,".. loc:GetString() ..",Point(1,1),0.5)"
	--effect:AddScript(script)
	
	return effect
end

function Env_lmn_Volcanic_Vents:SelectSpaces()
	local ret = {}
	local zone = extract_table(Board:GetZone("volcanic_vent"))
	
	for _, p in ipairs(zone) do
		if math.random(100) < self.chance then
			ret[#ret+1] = p
		end
	end
	
	return ret
end

function Env_lmn_Volcanic_Vents:Plan()
	local ret = Env_Attack.Plan(self)
	
	for _, p in ipairs(self.Planned) do
		Board:BlockSpawn(p, BLOCKED_PERM)
	end
	
	return ret
end

function this:init(mod)
	modApi:appendAsset("img/combat/tiles_grass/lmn_ground_volcanic_vent.png", mod.resourcePath .."img/tileset_plant/ground_volcanic_vent.png")
	modApi:appendAsset("img/combat/tile_icon/lmn_tile_volcanic_vent.png", mod.resourcePath .."img/combat/icon_volcanic_vent.png")
	modApi:appendAsset("img/effects/lmn_volcanic_eruption.png", mod.resourcePath .."img/effects/volcanic_eruption.png")
	Location["combat/tile_icon/lmn_tile_volcanic_vent.png"] = Point(-27,2)
	
	TILE_TOOLTIPS.lmn_volcanic_vent = {"Volcanic Vent", "Volcanic Vent is about to erupt here, killing any unit."}
	Global_Texts["TipTitle_".."Env_lmn_Volcanic_Vents"] = Env_lmn_Volcanic_Vents.Name
	Global_Texts["TipText_".."Env_lmn_Volcanic_Vents"] = Env_lmn_Volcanic_Vents.Text
	
	for i = 0, 11 do
		modApi:addMap(mod.resourcePath .."maps/lmn_vent".. i ..".map")
	end
	
	lmn_Emitter_Volcanic_Vent = Emitter:new{
		image = "effects/smoke/fireball_smoke.png",
		max_alpha = 0.2,
		x = 0, y = 20, variance = 8,
		angle = 240, angle_variance = 50,
		burst_count = 50, speed = 1.25, lifespan = 1.0, birth_rate = 1, timer = 3,
		max_particles = 64,
		gravity = false,
		layer = LAYER_FRONT
	}
	
	ANIMS.lmn_volcanic_eruption = ANIMS.Animation:new{
		Image = "effects/lmn_volcanic_eruption.png",
		NumFrames = 9,
		Time = 0.07,
		PosX = -6,
		PosY = -70
	}
end

function this:load(mod, options, version)

end

return this