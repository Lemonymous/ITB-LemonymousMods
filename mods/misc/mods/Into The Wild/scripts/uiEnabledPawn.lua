
local path = mod_loader.mods[modApi.currentMod].resourcePath
local selected = require(path .."scripts/selected")
local highlighted = require(path .."scripts/highlighted")

local function GetUIEnabledPawn()
	if Board then
		local selected = selected:Get()
		local highlighted = highlighted:Get()
		if selected  then
			return selected
			
		elseif highlighted and Board:IsPawnSpace(highlighted) then
			return Board:GetPawn(highlighted)
		end
	end
	
    return nil
end

return GetUIEnabledPawn