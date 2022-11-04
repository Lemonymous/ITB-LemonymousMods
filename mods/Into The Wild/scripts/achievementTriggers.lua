
local mod = modApi:getCurrentMod()
local path = mod.scriptPath
local switch = mod.libs.switch
local modApiExt = mod.libs.modApiExt
local utils = require(path .."libs/utils")
local secret = require(path .."secret")

function lmn_JungleIsland_Chievo(achievementId)
	modApi.achievements:trigger(mod.id, achievementId)
end

local function onModsLoaded()
	-- boss fight
	modApiExt:addSkillBuildHook(function(mission, pawn, weaponId, p1, p2, skillEffect)
		if utils.IsTipImage() then return end
		if not pawn or pawn:GetType():sub(-4,-1) ~= "Boss" then return end
		if skillEffect.q_effect:empty() then return end
		
		skillEffect:AddQueuedScript([[
			local pawns = extract_table(Board:GetPawns(TEAM_ENEMY));
			local leaders = {};
			for _, id in ipairs(pawns) do
				local pawn = Board:GetPawn(id);
				if pawn:GetType():sub(-4,-1) == "Boss" and not pawn:IsDead() then
					table.insert(leaders, id);
				end
			end
			for _, id in ipairs(leaders) do
				local fx = SkillEffect();
				fx:AddScript(string.format("if Board:GetPawn(%s):IsDead() then lmn_JungleIsland_Chievo('bossfight') end", id));
				Board:AddEffect(fx);
			end
		]])
	end)
	
	-- flytrap
	local chompers = {"lmn_Chomper1", "lmn_Chomper2", "lmn_ChomperBoss"}
	modApiExt:addSkillBuildHook(function(mission, pawn, weaponId, p1, p2, skillEffect)
		if utils.IsTipImage() then return end
		if not pawn or not list_contains(chompers, pawn:GetType()) then return end
		if skillEffect.q_effect:empty() then return end
		
		skillEffect:AddQueuedScript([[
			local types = {"Hornet1", "Hornet2", "HornetBoss"}
			local pawns = extract_table(Board:GetPawns(TEAM_ENEMY));
			local hornets = {};
			for _, id in ipairs(pawns) do
				local pawn = Board:GetPawn(id);
				if list_contains(types, pawn:GetType()) and not pawn:IsDead() then
					table.insert(hornets, id);
				end
			end
			for _, id in ipairs(hornets) do
				local fx = SkillEffect();
				fx:AddScript(string.format("if Board:GetPawn(%s):IsDead() then lmn_JungleIsland_Chievo('flytrap') end", id));
				Board:AddEffect(fx);
			end
		]])
	end)
	
	local leaders = switch{
		["lmn_ChiliBoss"] = function()
			modApi.achievements:addProgress(mod.id, "leaders", { chili = true } )
		end,
		["lmn_ChomperBoss"] = function()
			modApi.achievements:addProgress(mod.id, "leaders", { chomper = true } )
		end,
		["lmn_SunflowerBoss"] = function()
			modApi.achievements:addProgress(mod.id, "leaders", { sunflower = true } )
		end,
		["lmn_SpringseedBoss"] = function()
			modApi.achievements:addProgress(mod.id, "leaders", { springseed = true } )
		end,
		["lmn_SequoiaBoss"] = function()
			modApi.achievements:addProgress(mod.id, "leaders", { sequoia = true } )
		end,
		default = function() end
	}
	
	-- leaders
	modApiExt:addPawnKilledHook(function(mission, pawn)
		if modApi.achievements:isComplete(mod.id, "leaders") then
			return
		end

		leaders:case(pawn:GetType())
		if modApi.achievements:isProgress(mod.id, "leaders",
			{
				chili = true,
				chomper = true,
				sunflower = true,
				springseed = true,
				sequoia = true,
			})
		then
			modApi.achievements:addProgress(mod.id, "leaders", { reward = true } )
			modApi.toasts:add(secret:getToast())
		end
	end)
end

modApi.events.onModsLoaded:subscribe(onModsLoaded)
