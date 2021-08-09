
local path = mod_loader.mods[modApi.currentMod].scriptPath
local achvApi = require(path .."achievements/api")
local modUtils = LApi.library:fetch("modApiExt/modApiExt", nil, "ITB-ModUtils")
local switch = LApi.library:fetch("switch")
local this = {}

local bosses = {
	"swarmer",
	"roach",
	"spitter",
	"wyrm",
	"crusher"
}

local toasts = {}
local isCompleted = switch{ default = function() end }
local triggerChievo = switch{ default = function() end }

for _, boss in ipairs(bosses) do
	local Boss = boss:gsub("^.", string.upper) -- capitalize first letter
	toasts[boss] = {
		unlockTitle = Boss ..' Unlocked!',
		name = Boss ..' Mech',
		tip = Boss ..' Mech unlocked.',
		img = 'img/achievements/toasts/lmn_'.. boss ..'.png'
	}
	
	isCompleted['lmn_'.. Boss ..'Boss'] = function()
		return achvApi:GetChievoStatus(boss)
	end
	
	triggerChievo['lmn_'.. Boss ..'Boss'] = function()
		achvApi:TriggerChievo(boss)
		achvApi:ToastUnlock(toasts[boss])
	end
end

function this:load()
	modUtils:addPawnKilledHook(function(mission, pawn)
		local pawnType = pawn:GetType()
		
		if isCompleted:case(pawnType) then
			return
		end
		
		-- special case for swarmers.
		if pawnType == 'lmn_SwarmerBoss' then
			local pawns = extract_table(Board:GetPawns(TEAM_ENEMY))
			
			for _, id in ipairs(pawns) do
				if Board:GetPawn(id):GetType() == 'lmn_SwarmerBoss' then
					return
				end
			end
		end
		
		triggerChievo:case(pawnType)
	end)
end

return this