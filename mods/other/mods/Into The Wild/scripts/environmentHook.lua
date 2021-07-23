
-- workaround to make environment hooks only trigger once.
-- very incomplete

local this = {preHooks = {}, postHooks = {}}
local version = "2.3.2.2"

function this:init(func)
	if not modApi:isVersion(version, modApi.version) then
		LOG("mod loader older than ".. version .." - applying environment hook fix.")
		
		--table.insert(self.preHooks, func)
		table.insert(self.postHooks, func)
		
		local oldApplyEnvironmentEffect = Mission.ApplyEnvironmentEffect
		function Mission:ApplyEnvironmentEffect()
			if not self.LiveEnvironment.lmn_preHookFired then
				self.LiveEnvironment.lmn_preHookFired = true
				
				for i, hook in ipairs(this.preHooks) do
					hook(self)
				end
			end
			
			local retValue = false
			if self.LiveEnvironment:IsEffect() then
				retValue = oldApplyEnvironmentEffect(self)
			end
			
			if not retValue then
				self.LiveEnvironment.lmn_preHookFired = nil
				
				for i, hook in ipairs(this.postHooks) do
					hook(self)
				end
			end
			
			return retValue
		end
	else
		LOG("mod loader ".. version .." or newer - skipping environment hook fix.")
	end
end

return this