
---------------------------------------------------------------------
-- Switch v1.0 - code library
--[[-----------------------------------------------------------------
	simple switch functionality.
	
	example use:
	
	local path = mod_loader.mods[modApi.currentMod].scriptPath
	local switch = require(path .."switch")
	
	local mySwitch = switch{
		[1] = function(x)
				return x ..": this is case number one"
			end,
		[2] = function(x)
				return x ..": this is case number two"
			end,
		default = function(x)
				return x ..": this is the default case"
			end
	}
	
	LOG(mySwitch:case(1))
	-- prints "1: this is case number one"
	LOG(mySwitch:case(3))
	-- prints "3: this is the default case"
	
]]-------------------------------------------------------------------

return function(t)
	t.case = function(self, x, ...)
		local f = self[x] or self.default
		if f then
			if type(f) == "function" then
				local args = {...}
				args[#args+1] = x -- pack case into return.
				
				return f(unpack(args))
			else
				error("case ".. tostring(x) .." not a function")
			end
		end
	end
	return t
end