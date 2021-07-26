
local this = {}

local pilot = {
	Id = "Pilot_lmn_Lanius",
	Personality = "lmn_Lanius",
	Name = "Translator", --tmp?
	Rarity = 1,
	Voice = "/voice/silica",
	Skill = "lmn_lanius_aggressive",
}

local function is_adjacent(tile1, tile2)
	return
		tile1 == tile2 + VEC_UP    or
		tile1 == tile2 + VEC_RIGHT or
		tile1 == tile2 + VEC_DOWN  or
		tile1 == tile2 + VEC_LEFT
end

lmn_Lanius_Aggressive = {}

function lmn_Lanius_Aggressive:EnemyMoveEndHook(mission, pawn)
	local p2 = pawn:GetSpace()
	
	for id = 0, 2 do
		pawn = Board:GetPawn(id)
		local p1 = pawn:GetSpace()
		if pawn:IsAbility(pilot.Skill) and is_adjacent(p1, p2) then
			lmn_Lanius_Aggressive:GetSkillEffect(p1, p2)
		end
	end
end

function lmn_Lanius_Aggressive:GetSkillEffect(p1, p2)
	local effect = SkillEffect()
	
	effect:AddSound("weapons/shield_bash")
	local damage = SpaceDamage(p2, 1, GetDirection(p2 - p1))
	damage.sAnimation = "SwipeClaw1"
	effect:AddMelee(p1, damage)
	
	Board:AddEffect(effect)
end

function this:init(mod)
	CreatePilot(pilot)
	
	require(mod.scriptPath .."pilotSkill_tooltip").Add("lmn_lanius_aggressive", PilotSkill("Aggressive", "Strikes enemies ending their movement in an adjacent tile."))
	
	modApi:appendAsset("img/portraits/pilots/Pilot_lmn_Lanius.png", mod.resourcePath .."img/portraits/pilots/pilot_lanius.png")
	modApi:appendAsset("img/portraits/pilots/Pilot_lmn_Lanius_2.png", mod.resourcePath .."img/portraits/pilots/pilot_lanius_2.png")
	modApi:appendAsset("img/portraits/pilots/Pilot_lmn_Lanius_blink.png", mod.resourcePath .."img/portraits/pilots/pilot_lanius_blink.png")
end

function this:load(modApiExt, options)
	modApiExt:addPawnPositionChangedHook(function(mission, pawn, oldPosition)
		if Game:GetTeamTurn() ~= TEAM_ENEMY or pawn:GetTeam() ~= TEAM_ENEMY then
			return
		end
		
		local effect = SkillEffect()
		effect:AddScript([[
			local pawn = Board:GetPawn(]].. pawn:GetId() ..[[);
			if pawn:GetSpace() == ]].. pawn:GetSpace():GetString() ..[[ then
				lmn_Lanius_Aggressive:EnemyMoveEndHook(GetCurrentMission(), pawn);
			end
		]])
		Board:AddEffect(effect)
	end)
end

return this