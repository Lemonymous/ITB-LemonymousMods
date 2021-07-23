
VERSION = "0.1.0"

if globals == nil or modApi:isVersion(VERSION, globals.version) then
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
