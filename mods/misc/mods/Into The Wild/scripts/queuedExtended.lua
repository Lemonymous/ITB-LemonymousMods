---------------------------------------------------------------------
-- queuedExtended v1.0 - code library
---------------------------------------------------------------------
-- adds missing queued functions to SkillEffect

local function AddQueued(name)
	SkillEffect["AddQueued".. name] = function(self, ...)
		local fx = SkillEffect()
		fx["Add".. name](fx, ...)
		self.q_effect:push_back(fx.effect:index(1))
	end
end

AddQueued("Airstrike")
AddQueued("Animation")
AddQueued("BoardShake")
AddQueued("Bounce")
AddQueued("Delay")
AddQueued("Dropper")
AddQueued("Emitter")
AddQueued("Grapple")
AddQueued("Leap")
AddQueued("Sound")