local this = Class.inherit(UiDeco)

function this:new(borderColor, borderSize, highlightColor, highlightBorderSize)
    self.borderColor = borderColor or deco.colors.buttonborder
    self.highlightColor = highlightColor or deco.colors.buttonborderhl
    self.borderSize = borderSize or 1
    self.highlightBorderSize = highlightBorderSize or 4
    self.rect =  sdl.rect(0, 0, 0, 0)
end

function this:draw(screen, widget)
    local r = widget.rect
	
    self.rect.x = r.x
    self.rect.y = r.y-- + widget.decorationy
    self.rect.w = r.w
    self.rect.h = r.h-- - widget.decorationy
	
    local color = self.borderColor
	local borderSize = self.borderSize
    if widget.hovered then
        color = self.highlightColor
        borderSize = self.highlightBorderSize
    end
	
    drawborder(screen, color, self.rect, borderSize)
	
    --widget.decorationx = widget.decorationx + borderSize * 2
end

function this:apply(widget)
    widget:padding(self.borderSize * 2)
end

function this:unapply(widget)
    widget:padding(self.borderSize * 2)
end

return this