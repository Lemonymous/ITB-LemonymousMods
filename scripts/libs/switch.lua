
---------------------------------------------------------------------
-- Switch v2.0 - code library
--
-- by Lemonymous
--[[-----------------------------------------------------------------
	Provides simple switch functionality.

	In contrast to switch...case statements in C, there is no
	flow or fallthrough in this implementation.
	Executing a case will only ever execute that particular
	case, or the default case if there is no case with the
	specified identifier.


	Building a switch:

	-- Fetch library
	local path = mod_loader.mods[modApi.currentMod].scriptPath
	local switch = require(path .."switch")


	-- Create a new switch with an empty case table
	local myswitch = switch{}

	-- Create a new switch with a populated case table
	local myswitch = switch{
		[1] = "case one",
		[2] = "case two",
		default = "default case"
	}

	-- Add a case to the case table
	myswitch[3] = "case three"

	-- Add a case as a function to the case table
	myswitch[4] = function()
		return "case four"
	end

	-- Add a case with additional parameters to the case table
	myswitch[5] = function(...)
		return "case five\n"..save_table{...}
	end



	Using a switch:

	-- Execute a case by calling 'case'
	LOG(myswitch:case(1))

	-- Additional arguments can be provided to
	-- the function in the case table. These
	-- arguments are ignored if the case is
	-- not a function
	LOG(myswitch:case(1, "argument1", "argument2"))


	-- Execute a case by calling the switch.
	-- This is equivalent to using 'case'
	LOG(myswitch(1))

	-- This method also supports additional arguments
	-- provided to the underlying case function
	LOG(myswitch(1, "argument1", "argument2"))


	-- Execute a case with array syntax.
	-- This is equivalent to using 'case',
	-- except this method does _not_ support
	-- additional arguments like the two
	-- previous methods.
	LOG(myswitch[1])

]]-------------------------------------------------------------------

local self_mt = {
	__newindex = function(self, key, value)
		local case_table = rawget(self, "__case_table")
		case_table[key] = value
	end,

	__index = function(self, key)
		local case_table = rawget(self, "__case_table")
		local result = case_table[key] or case_table.default

		if type(result) == 'function' then
			return result(key)
		else
			return result
		end
	end,

	__call = function(self, key, ...)
		local case_table = rawget(self, "__case_table")
		local result = case_table[key] or case_table.default

		if type(result) == 'function' then
			local args = {...}
			args[#args+1] = key -- pack case key into arguments.

			return result(unpack(args))
		else
			return result
		end
	end,
}

local switch_mt = {
	__call = function(self, case_table)
		local new_switch = {}
		new_switch.__case_table = case_table
		new_switch.case = self_mt.__call

		return setmetatable(new_switch, self_mt)
	end
}

local switch = {}
setmetatable(switch, switch_mt)

return switch
