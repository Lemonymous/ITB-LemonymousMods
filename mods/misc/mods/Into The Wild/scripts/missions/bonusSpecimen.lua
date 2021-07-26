
local path = mod_loader.mods[modApi.currentMod].resourcePath
local bonus = require(path .."scripts/missions/bonusObjective")
local worldConstants = require(path .."scripts/worldConstants")

local this = {id = "lmn_bonus_specimen"}
local specimenBonus = 3

modApi:appendAsset("img/effects/lmn_specimen_drop_L.png", path .."img/effects/specimen_drop_L.png")
modApi:appendAsset("img/effects/lmn_specimen_explo_smoke2.png", path .."img/effects/explo_smoke2.png")
modApi:appendAsset("img/units/mission/lmn_specimen_plane.png", path .."img/units/mission/specimen_plane.png")

ANIMS.lmn_Specimen_Drop_1 = ANIMS.Animation:new{
	Image = "effects/lmn_specimen_drop_L.png",
	NumFrames = 7,
	Time = 0.05,
	PosX = -23,
	PosY = -12
}

ANIMS.lmn_Specimen_Explo_Smoke2 = ANIMS.ExploAir2:new{ Image = "effects/lmn_specimen_explo_smoke2.png" }

local function GetAlive()
	return Board:GetPawns(TEAM_ENEMY):size()
end

function this.GetStatus(mission, obj, endstate)
	local default = endstate and OBJ_FAILED or OBJ_STANDARD
	return GetAlive() >= specimenBonus and OBJ_COMPLETE or default
end

function this.GetObjective(mission, obj)
	return Objective("Secure ".. specimenBonus .." Specimen", 1)
end

function this.Update(mission, obj)
	local status = mission:GetBonusStatus(obj, false)
	
	Game:AddObjective(string.format("Keep at least %s enemies alive\n(Current: %s)", specimenBonus, GetAlive()), status)
end

function this.GetInfo(mission, obj, endstate)
	local info = {}
	info.text_id = "Mission_lmn_Specimen"
	
	if endstate then
		info.success = mission:GetBonusStatus(obj, endstate) == OBJ_COMPLETE
		info.text_id = info.text_id .. (info.success and "_Success" or "_Failure")
	else
		info.text_id = info.text_id .."_Briefing"		    	
	end
	
	return info
end

local missionEnd = Mission.MissionEnd
function Mission.MissionEnd(self, ...)
	local isBonusSpecimen = list_contains(self.BonusObjs, this.id)
	local enemies
	
	if isBonusSpecimen then
		local fx = SkillEffect()
		local t = 0
		local events = {}
		enemies = extract_table(Board:GetPawns(TEAM_ENEMY))
		
		if #enemies > 0 then
			for _, id in ipairs(enemies) do
				local pawn = Board:GetPawn(id)
				local loc = pawn:GetSpace()
				pawn:SetTeam(TEAM_NONE) -- prevent from retreating.
				if Board:IsValid(loc) then
					local t_drop = t + .15 + .20 * (loc.x + 1)
					local t_impact = t + .15 + .20 * (loc.x + 1) + .30
					events[#events+1] = {loc = loc, type = "launch", t = t}
					events[#events+1] = {loc = loc, type = "drop", t = t_drop}
					events[#events+1] = {loc = loc, type = "impact", t = t_impact}
				end
				
				t = t + 0.4
			end
			
			t = t + 1.6
			
			for _, id in ipairs(enemies) do
				local loc = Board:GetPawn(id):GetSpace()
				events[#events+1] = {loc = loc, type = "ping", t = t}
				
				t = t + 0.2
			end
			
			-- sort events in relation to time.
			table.sort(events, function(a,b) return a.t > b.t end)
			t = 0
			
			while #events > 0 do
				local e = events[#events]
				
				while e and t >= e.t do
					if e.type == "ping" then
						fx:AddSound("/props/square_lightup")
						fx:AddScript(string.format("Board:Ping(%s, GL_Color(50, 255, 50))", e.loc:GetString()))
						
					elseif e.type == "launch" then
						fx:AddSound("/props/airstrike")
						worldConstants.SetSpeed(fx, .5)
						fx:AddAirstrike(e.loc, "units/mission/lmn_specimen_plane.png")
						fx.effect:index(fx.effect:size()).fDelay = 0
						worldConstants.ResetSpeed(fx)
						
					elseif e.type == "drop" then
						fx:AddScript(string.format("Board:AddAnimation(%s, 'lmn_Specimen_Drop_1', ANIM_NO_DELAY)", e.loc:GetString()))
						
					elseif e.type == "impact" then
						fx:AddSound("/impact/generic/general")
						fx:AddSound("/enemy/shared/moved")
						fx:AddScript(string.format("Board:AddAnimation(%s, 'lmn_Specimen_Explo_Smoke2', ANIM_NO_DELAY)", e.loc:GetString()))
						fx:AddScript(string.format("Board:AddAnimation(%s, 'Stunned', ANIM_NO_DELAY)", e.loc:GetString()))
					end
					
					table.remove(events, #events)
					e = events[#events]
				end
				
				if e then
					if e.t - t > 0 then
						fx:AddDelay(e.t - t)
					end
					t = e.t
				end
			end
			
			fx:AddDelay(0.2)
			fx:AddSound("/ui/battle/mission_complete_objective_".. (#enemies >= specimenBonus and "completed" or "failed"))
			
			Board:AddEffect(fx)
		end
	end
	
	missionEnd(self, ...)
	
	if isBonusSpecimen then
		for _, id in ipairs(enemies) do
			Board:GetPawn(id):SetTeam(TEAM_ENEMY)
		end
	end
end

bonus:Add(this)