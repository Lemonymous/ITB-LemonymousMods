
local mod = mod_loader.mods[modApi.currentMod]
local toast = require(mod.scriptPath .."achievements/uiToast")

local this = {}

-- queued up a toast. automatically called when triggering an achievement.
function this:Add(chievo)
	table.insert(lmn_achievements.toasts.pending, chievo)
end

-- update function automatically called by highest version of library.
function this:Update(screen)
	local a = lmn_achievements.toasts
	
	-- if there is a toast playing, return.
	if a.current and not a.current:isStopped() then
		return
	end
	
	a.current = nil
	
	-- start the first pending toast.
	if #a.pending > 0 then
		if Game then Game:TriggerSound("ui/general/achievement") end
		a.current = toast(a.pending[1])
		table.remove(a.pending, 1)
	end
end

return this