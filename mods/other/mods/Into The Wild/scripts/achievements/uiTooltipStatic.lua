
local this = Class.inherit(UiBoxLayout)
local font_title = sdlext.font("fonts/NunitoSans_Bold.ttf", 16)
local font_text = sdlext.font("fonts/NunitoSans_Regular.ttf", 12)
local color_tooltip = sdl.rgba(24, 28, 41, 240)

function this:new()
	UiBoxLayout.new(self)
	
	local root = sdlext.getUiRoot()
	local set = deco.textset(deco.colors.white, nil, 0, true)
	
	self:padding(10)
		:decorate({ DecoFrame(color_tooltip, deco.colors.white, 3) })
		:addTo(root)
	self.padt = 12
	self.padb = 16
	self.gapVertical = 5
	self.translucent = true
	
	local title = UiWrappedText(nil, font_title, set)
		:decorate({DecoText()})
		:addTo(self)
	title.limit = 28
	title.translucent = true
	title.textType = "title"
	
	local text = UiWrappedText(nil, font_text, set)
		:decorate({DecoText()})
		:addTo(self)
	text.limit = 28
	text.translucent = true
	text.textType = "text"
end

--[[
	Compute aligned position for the specified axis (horizontal/vertical).

	Returns coordinate value positioning the 'self' argument aligned with the
	target widget's origin. If this would result in 'self' clipping outside of
	the screen bounds, this function instead returns coordinate value positioning
	'self' aligned with the target widget's end.
--]]
local function computeAlignedPos(self, widget, screen, horizontal)
	if horizontal then
		return (widget.screenx + self.w <= screen:w())
			and widget.screenx
			or  (widget.screenx + widget.w - self.w)
	else
		return (widget.screeny + self.h <= screen:h())
			and widget.screeny
			or  (widget.screeny + widget.h - self.h)
	end
end

function this:SetMargin(margin)
	if type(margin) == 'number' then	-- margin = size
		self.marginl = margin
		self.marginr = margin
		self.margint = margin
		self.marginb = margin
	elseif type(margin) == 'table' then
		assert(#margin >= 2 and #margin <= 4)
		if #margin == 2 then			-- margin = {w,h}
			self.marginl = margin[1]
			self.marginr = margin[1]
			self.margint = margin[2]
			self.marginb = margin[2]
		elseif #margin == 3 then		-- margin = {l,r,h}
			self.marginl = margin[1]
			self.marginr = margin[2]
			self.margint = margin[3]
			self.marginb = margin[3]
		elseif #margin == 4 then		-- margin = {l,r,t,b}
			self.marginl = margin[1]
			self.marginr = margin[2]
			self.margint = margin[3]
			self.marginb = margin[4]
		end
	end
end

function this:SetAnchor()
	local margin = {
		self.marginl or 0,
		self.marginr or 0,
		self.margint or 0,
		self.marginb or 0,
	}
	self.anchorl = self.screenx - margin[1]
	self.anchorr = self.screenx + self.w + margin[2]
	self.anchort = self.screeny - margin[3]
	self.anchorb = self.screeny + self.h + margin[4]
end

function this:Set(widget, title, text)
	self.tip = {widget = widget, title = title, text = text}
end

function this:draw(screen)
	if not self.tip or not self.tip.widget or not self.tip.widget.hovered then self.visible = false return end
	local icon = self.tip.widget
	
	local isUpdate
	for i, v in ipairs(self.children) do
		if v.textType then
			if v.text ~= self.tip[v.textType] then
				v.text = self.tip[v.textType]
				v:widthpx(9999)
				v:rebuild()
				isUpdate = true
			end
		end
	end
	
	if isUpdate then
		local width = 0
		
		for _, child in ipairs(self.children) do
			local w = UiBoxLayout.maxChildSize(child, "width")
			width = math.max(width, w)
		end
		
		self.w = width + self.padl + self.padr
		
		-- TODO: would make more sense to set margin and anchor when creating the icons.
		self.SetMargin(icon, 10)
		self.SetAnchor(icon)
		
		-- TODO: this code should be better to put tooltip always inside screen size.
		if screen:w() - icon.anchorr > self.w then
			self:pospx(icon.anchorr, icon.screeny)
		elseif icon.anchorl > self.w then
			self:pospx(icon.anchorl - icon.w, icon.screeny)
		elseif screen:h() - icon.anchorb > icon.h then
			self:pospx(icon.screenx, icon.anchorb)
		elseif icon.anchort > icon.h then
			self:pospx(icon.screenx, icon.anchort - icon.h)
		end
		
		self.screenx = icon.screenx
		self.screeny = icon.screeny
		
		self.parent:relayout()
		self:bringToTop()
	end
	
	self.visible = true
	UiBoxLayout.draw(self, screen)
end

return this