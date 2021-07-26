
local this = {}

function this:Get()
	return this.selected
end

function this:IsPawn(pawn)
	return this.selected == pawn
end

function this:IsPersonality(personality)
	return this.selected and this.selected:GetPersonality() == personality or nil
end

function this:IsAbility(ability)
	return this.selected and this.selected:IsAbility(ability) or nil
end

function this:init(mod)
	sdlext.addGameExitedHook(function() self.selected = nil end)
end

function this:load(modApiExt)
	modApiExt:addPawnSelectedHook(function(_, pawn) self.selected = pawn end)
	modApiExt:addPawnDeselectedHook(function() self.selected = nil end)
	modApi:addMissionEndHook(function() self.selected = nil end)
end

return this