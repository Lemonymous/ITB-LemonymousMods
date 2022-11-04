
local mod = mod_loader.mods[modApi.currentMod]
local modApiExt = mod.libs.modApiExt
local switch = mod.libs.switch

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
		title = Boss ..' Unlocked!',
		name = Boss ..' Mech',
		tooltip = Boss ..' Mech unlocked.',
		image = 'img/achievements/toasts/lmn_'.. boss ..'.png'
	}

	isCompleted['lmn_'.. Boss ..'Boss'] = function()
		return modApi.achievements:isComplete(mod.id, boss)
	end

	triggerChievo['lmn_'.. Boss ..'Boss'] = function()
		modApi.achievements:trigger(mod.id, boss)
		modApi.toasts:add(toasts[boss])
	end
end

local function onModsLoaded()
	modApiExt:addPawnKilledHook(function(mission, pawn)
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

modApi.events.onModsLoaded:subscribe(onModsLoaded)
