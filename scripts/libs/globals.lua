
local VERSION = "2.1.0"
---------------------------------------------------
-- Globals v2.1.0 - code library
--
-- by Lemonymous
---------------------------------------------------
-- Provides a way to create and access globals
-- variables dynamically.
--
--    Create a new global index:
-- local myGlobalIndex = globals:new()
--
--    Set my personal global variable:
-- globals[myGlobalIndex] = "myGlobalContent"
--
--    Get my personal global variable:
-- LOG(globals[myGlobalIndex])
--
--    Remove my personal global index:
-- globals:rem(myGlobalIndex)
---------------------------------------------------


local isNewestVersion = false
	or globals == nil
	or modApi:isVersion(VERSION, globals.version) == false

if isNewestVersion then
	globals = globals or {
		last = 0, -- a rolling index given out when there are no unused indices left
		free = {}, -- list of unused indices
	}

	function globals:new()
		local index = self.free[#self.free]

		if index ~= nil then
			table.remove(self.free, #self.free)
			self[index] = nil
			return index
		end

		self.last = self.last + 1
		return self.last
	end

	function globals:rem(index)
		self[index] = nil
		table.insert(self.free, index)
	end
end

return globals
