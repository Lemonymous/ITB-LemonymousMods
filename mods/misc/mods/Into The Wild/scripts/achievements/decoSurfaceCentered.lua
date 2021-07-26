local this = Class.inherit(DecoSurface)

function this:draw(screen, widget)
	if self.surface == nil then return end
	local r = widget.rect

	screen:blit(
		self.surface,
		nil,
		r.x + r.w / 2 - self.surface:w() / 2,
		r.y + r.h / 2 - self.surface:h() / 2
	)
	
	--widget.decorationx = widget.decorationx + self.surface:w()
end

return this