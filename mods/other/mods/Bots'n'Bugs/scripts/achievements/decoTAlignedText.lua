local this = Class.inherit(DecoText)

function this:draw(screen, widget)
	if self.surface == nil then return end
	local r = widget.rect

	local x = math.floor(r.x + widget.decorationx + r.w / 2 - self.surface:w() / 2)
	local y = math.floor(r.y + widget.decorationy)

	screen:blit(self.surface, nil, x, y)

	widget.decorationx = widget.decorationx + self.surface:w()
end

return this