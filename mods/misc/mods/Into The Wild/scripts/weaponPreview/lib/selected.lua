
---------------------------------------------------------------------
-- Selected v1.2* - code library
--[[-----------------------------------------------------------------
	modified for Weapon Preview library
]]
local path = mod_loader.mods[modApi.currentMod].scriptPath
local modApiExt = LApi.library:fetch("modApiExt/modApiExt", nil, "ITB-ModUtils")
local this = {}

sdlext.addGameExitedHook(function()
	this.selected = nil
end)

function this:Get()
	return self.selected
end

function this:load()
	modApiExt:addPawnSelectedHook(function(_, pawn)
		self.selected = pawn
	end)
	
	modApiExt:addPawnDeselectedHook(function(_, pawn)
		self.selected = nil
	end)
	
	modApi:addTestMechEnteredHook(function()
		modApi:runLater(function()
			for id = 0, 2 do
				self.selected = Board:GetPawn(id)
				if self.selected then
					break
				end
			end
		end)
	end)
	
	modApi:addTestMechExitedHook(function()
		self.selected = nil
	end)
end

return this