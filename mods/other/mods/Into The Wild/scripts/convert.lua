
local this = {}

function this.toByte(input)
	local s = input:gsub(".", function(s) return string.byte(s).." " end)
	return s
end

function this.toChar(input)
	local s = input:gsub('(%d+)%s', function(s) return string.char(s) end)
	return s
end

return this