
local mod = mod_loader.mods[modApi.currentMod]	-- this grabs our mod as long as we open this file when initializing our mod.
local path = mod.resourcePath
local achvApi = require(path .."scripts/achievements/api")
local getModUtils = require(path .."scripts/getModUtils")

local this = {}

local chievo1 = {
	id = "commit_sudoku",						-- id must only be unique within our mod.
	name = "Commit Sudoku",						-- displayed name.
	img = "img/achievements/Archive_B_1.png",	-- image used. *_gray.png must also exist.
	tip = "Have a friendly unit get destroyed."	-- displayed tip.
}

-- add an achievement to the game.
achvApi:AddChievo(chievo1)
for i = 1, 4 do
	achvApi:AddChievo({id="dummy".. i})
end

-- we can reset the achievement with this, so it is always off when restarting the game.
-- useful for testing, but should be the choice of the player in a release version.
achvApi:TriggerChievo(chievo1.id, false)

function this:load()
	local modUtils = getModUtils()
	
	-- trigger our achievement when a player owned unit is killed.
	modUtils:addPawnKilledHook(function(_, pawn)
		if pawn:GetTeam() == TEAM_PLAYER then
			achvApi:TriggerChievo(chievo1.id)
		end
	end)
end

return this