
--[[
	provides a function to automatically clip a ui element.
	default behavior is to clip self with sdlext.CurrentWindowRect
	
	example - (instead of draw)
	---------------------------
	
	-- Ui.draw(self, screen)
	clip(Ui, self, screen)
	
	
	advanced example
	----------------
	
	local drawRect = sdl.rect(0, 0, 100, 100)
	
	-- all clipRects will be omitted when drawing.
	local clipRects =
	{
		sdlext.CurrentWindowRect,
		sdl.rect(0, 0, 10, 10)
	}
	
	clip(Ui, self, screen, drawRect, clipRects)
]]

-- remove pixels 'cullRect' from rect 'drawRect'
-- and return a table of rects
-- not intersecting each other or the cullRect.
local function splitRect(drawRect, cullRect)
	local ret = {}
	local R = drawRect
	local c = cullRect
	
	-- prepare 4 rects left, top, right, bot
	local r = {
		l = sdl.rect(0,0,0,0),
		t = sdl.rect(0,0,0,0),
		r = sdl.rect(0,0,0,0),
		b = sdl.rect(0,0,0,0),
	}
	
	r.l.x = R.x
	r.l.y = R.y
	r.l.w = math.max(0, math.min(R.w, c.x - R.x))
	r.l.h = R.h
	
	r.r.x = math.max(R.x, math.min(R.x + R.w, c.x + c.w))
	r.r.y = R.y
	r.r.w = R.x + R.w - r.r.x
	r.r.h = R.h
	
	r.t.x = r.l.x + r.l.w
	r.t.w = R.w - r.l.w - r.r.w
	r.t.y = R.y
	r.t.h = math.max(0, math.min(R.h, c.y - R.y))
	
	r.b.x = r.t.x
	r.b.w = r.t.w
	r.b.y = math.max(R.y, math.min(R.y + R.h, c.y + c.h))
	r.b.h = R.y + R.h - r.b.y
	
	for _, r in pairs(r) do
		if r.w > 0 and r.h > 0 then
			table.insert(ret, r)
		end
	end
	
	return ret
end

local function this(base, widget, screen, drawRect, cullRects)
	if cullRects == nil then
		cullRects = {sdlext.CurrentWindowRect}
	elseif type(cullRects) ~= 'table' then
		cullRects = {cullRects}
	end
	
	drawRect = drawRect or sdl.rect(
		widget.x or 0,
		widget.y or 0,
		widget.w or 0,
		widget.h or 0
	)
	
	local rects = {drawRect}
	
	for _, c in ipairs(cullRects) do
		
		local newRects = {}
		
		for _, r in ipairs(rects) do
			newRects = add_arrays(newRects, splitRect(r, c))
		end
		
		rects = newRects
	end
	
	local tmp = modApi.msDeltaTime
	local updated
	
	for _, r in ipairs(rects) do
 		screen:clip(r)
		if updated then
			modApi.msDeltaTime = 0
		end
		updated = true
		base.draw(widget, screen)
 		screen:unclip()
	end
	
	-- TODO: should there be a draw call when
	-- the whole widget is being clipped as well?
	
	modApi.msDeltaTime = tmp
end

return this
