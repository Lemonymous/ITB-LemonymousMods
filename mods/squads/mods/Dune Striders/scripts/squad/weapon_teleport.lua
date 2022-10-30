
local mod = mod_loader.mods[modApi.currentMod]
local utils = require(mod.scriptPath .."libs/utils")
local effectPreview = mod.libs.effectPreview
local effectBurst = mod.libs.effectBurst
local astar = mod.libs.astar

lmn_ds_Teleport = Skill:new{}

function lmn_ds_Teleport:GetTargetArea(point)
	return Board:GetReachable(point, Pawn:GetMoveSpeed(), Pawn:GetPathProf())
end

function lmn_ds_Teleport:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	
	if self.LeaveSmoke then
		local smoke = SpaceDamage(p1)
		smoke.iSmoke = 1
		ret:AddDamage(smoke)
		
		if Pawn:IsFire() then
			local extinguish = SpaceDamage(p2)
			extinguish.sImageMark = "combat/icons/ds_icon_fire_immune_glow.png"
			ret:AddDamage(extinguish)
		end
	end
	
	effectPreview:addTeleport(ret, p1, p2)
	ret:AddSound("/props/smoke_cloud")
	ret:AddSound("/enemy/shared/moved")
	ret:AddSound("/props/pylon_fall")
	
	ret:AddScript(string.format([[
		local pawn = Board:GetPawn(%s);
		local p1 = %s;
		local p2 = %s;
		
		Board:AddAnimation(p1, 'ds_explo_smoke', ANIM_NO_DELAY)
		pawn:SetInvisible(true);
		
	]], Board:GetPawn(p1):GetId(), p1:GetString(), p2:GetString()))
	
	ret:AddDelay(0.1)
	local path = astar:getPath(p1, p2, function() return true end)
	
	for _, p in ipairs(path) do
		effectBurst.Add(ret, p, "Emitter_Burst", DIR_NONE)
		ret:AddDelay(0.02)
	end
	
	ret:AddSound("/props/smoke_cloud")
	ret:AddScript(string.format([[
		local pawn = Board:GetPawn(%s);
		local p1 = %s;
		local p2 = %s;
		
		Board:AddAnimation(p2, 'ds_explo_smoke', ANIM_NO_DELAY)
		pawn:SetSpace(p2);
		
	]], Board:GetPawn(p1):GetId(), p1:GetString(), p2:GetString()))
	
	ret:AddDelay(0.1)
	
	ret:AddScript(string.format([[
		local pawn = Board:GetPawn(%s);
		local p1 = %s;
		local p2 = %s;
		
		pawn:SetInvisible(false);
		
	]], Board:GetPawn(p1):GetId(), p1:GetString(), p2:GetString()))
	
	return ret
end
