
local path = mod_loader.mods[modApi.currentMod].scriptPath
local switch = require(path .."switch")
local achvApi = require(path .."achievements/api")
local getModUtils = require(path .."getModUtils")
local utils = require(path .."utils")
local garble = require(path .."garble")
local this = {}

function lmn_JungleIsland_Chievo(id)
	achvApi:TriggerChievo(id)
end

function this:load()
	local modUtils = getModUtils()
	
	-- boss fight
	modUtils:addSkillBuildHook(function(mission, pawn, weaponId, p1, p2, skillEffect)
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
	modUtils:addSkillBuildHook(function(mission, pawn, weaponId, p1, p2, skillEffect)
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
			achvApi:TriggerChievo("leaders", { chili = true } )
		end,
		["lmn_ChomperBoss"] = function()
			achvApi:TriggerChievo("leaders", { chomper = true } )
		end,
		["lmn_SunflowerBoss"] = function()
			achvApi:TriggerChievo("leaders", { sunflower = true } )
		end,
		["lmn_SpringseedBoss"] = function()
			achvApi:TriggerChievo("leaders", { springseed = true } )
		end,
		["lmn_SequoiaBoss"] = function()
			achvApi:TriggerChievo("leaders", { sequoia = true } )
		end,
		default = function() end
	}
	
	-- leaders
	modUtils:addPawnKilledHook(function(mission, pawn)
		if achvApi:GetChievoStatus("leaders") then return end
		
		leaders:case(pawn:GetType())
		if achvApi:IsChievoProgress("leaders",
			{
				chili = true,
				chomper = true,
				sunflower = true,
				springseed = true,
				sequoia = true,
			})
		then
			achvApi:TriggerChievo("leaders", { reward = true } )
			achvApi:ToastUnlock(garble:get())
		end
	end)
end

return this