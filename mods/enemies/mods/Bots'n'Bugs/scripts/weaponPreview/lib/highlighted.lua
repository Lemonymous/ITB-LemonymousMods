
-- Highlighted - Deprecated library

local this = {}

function this:Get()
	if not Board then return nil end
	return Board:GetHighlighted()
end

function this:load() end

return this
