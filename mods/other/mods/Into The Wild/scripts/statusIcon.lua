
---------------------------------------------------------------------
-- statusIcon v1.0 - code library
---------------------------------------------------------------------
-- provides functions for swapping icons of traits.
-- only intended to use for non-mech units,
-- as mechs require much more elaborate code
-- to swap icon in hangar, region view and on mission end.

local path = mod_loader.mods[modApi.currentMod].resourcePath
local uiEnabledPawn = require(path .."scripts/uiEnabledPawn")
local decoColorMissionBlack = sdl.rgb(22, 23, 25)
local widgets = {}
local icons = {}
local uiRoot

local this = {}

local function IsMenu()
	return	sdlext.CurrentWindowRect.w == 275 and
			sdlext.CurrentWindowRect.h == 500
end

local function IsLargeTooltip()
	return	sdlext.CurrentWindowRect.w >= 260 and
			sdlext.CurrentWindowRect.w <= 278
end

local function createWidget(id)
	icons[id].UiCreated = true
	local old = icons[id].old
	local new = icons[id].new
	
	---------- SMALL ICON - scale = 1  -----------
	
	local ow, oh = old:w(), old:h() -- old width, height
	local nw, nh = new:w(), new:h() -- new width, height, x, y
	local nx = math.floor((ow - nw) / 2)
	local ny = math.floor((oh - nh) / 2)
	
	widgets[#widgets+1] = Ui():addTo(uiRoot)
		:widthpx(ow):heightpx(oh)
		:decorate({ DecoSolid(decoColorMissionBlack) })
		
	local solid = widgets[#widgets]
	local icon = Ui():addTo(solid)
		:pospx(nx, ny):widthpx(nw):heightpx(nh)
		:decorate({ DecoSurfaceOutlined(new, 1, deco.colors.buttonborder, deco.colors.focus, 1) })
		
	solid.translucent = true
	solid.visible = false
	solid.clipRect = sdl.rect(0, 0, nw, nh)
	icon.translucent = true
	icon.decorations[1].draw = function(self, screen, widget)
		self.surface = self.surface or self.surfacenormal
		DecoSurface.draw(self, screen, widget)
	end
	
	solid.draw = function(self, screen)
		self.visible = false
		
		local mission = GetCurrentMission()
		if not mission or mission.lmn_supress_icon_draw then return end
		
		if old:wasDrawn() and not IsMenu() then -- impossible to get perfect result with menu visible, so avoid it.
			
			local pawn = uiEnabledPawn()
			if pawn and list_contains(icons[id].pawnTypes, pawn:GetType()) then
				
				if not IsLargeTooltip() then
					self.x = old.x
					self.y = old.y
					
					self.clipRect.x = self.x + nx
					self.clipRect.y = self.y + ny
					
					-- TODO: sort potential clipping.
					
					icon.decorations[1].surface = icon.decorations[1].surfacenormal
				else
					icon.decorations[1].surface = icon.decorations[1].surfacehl
				end
				self.visible = true
			end
		end
		
		screen:clip(self.clipRect)
		Ui.draw(self, screen)
		screen:unclip()
	end
	
	---------- LARGE ICON - scale = 2 -----------
	
	local ow, oh = ow * 2, oh * 2 -- old width, height
	local nw, nh = nw * 2, nh * 2 -- new width, height, x, y
	local nx = math.floor((ow - nw) / 2)
	local ny = math.floor((oh - nh) / 2)
	
	local solid = Ui():addTo(uiRoot)
		:widthpx(ow):heightpx(oh)
		:decorate({ DecoSolid(deco.colors.framebg) })
		
	local icon = Ui():addTo(solid)
		:pospx(nx, ny):widthpx(nw):heightpx(nh)
		:decorate({ DecoSurfaceOutlined(new, 1, deco.colors.buttonborder, deco.colors.buttonborder, 2) })
		
	icon.translucent = true
	solid.translucent = true
	solid.visible = false
	solid.clipRect = sdl.rect(0, 0, nw, nh)
	
	solid.draw = function(self, screen)
		self.visible = false
		
		local mission = GetCurrentMission()
		if not mission or mission.lmn_supress_icon_draw then return end
		
		if old:wasDrawn() and not IsMenu() then -- impossible to get perfect result with menu visible, so avoid it.
			
			local pawn = uiEnabledPawn()
			if pawn and list_contains(icons[id].pawnTypes, pawn:GetType()) then
				if IsLargeTooltip() then
					self.x = old.x
					self.y = old.y
					
					self.clipRect.x = self.x + nx
					self.clipRect.y = self.y + ny
					
					self.visible = true
				end
			end
		end
		
		screen:clip(self.clipRect)
		Ui.draw(self, screen)
		screen:unclip()
	end
end

function this:Add(pawnType, oldIcon, newIcon)
	assert(type(pawnType) == 'string')
	assert(type(oldIcon) == 'string')
	assert(type(newIcon) == 'string')
	
	icons[oldIcon] = icons[oldIcon] or {
		old = sdlext.surface(oldIcon),
		new = sdlext.surface(newIcon),
		pawnTypes = {}
	}
	
	if not list_contains(icons[oldIcon].pawnTypes) then
		table.insert(icons[oldIcon].pawnTypes, pawnType)
	end
	
	if uiRoot and not icons[oldIcon].UiCreated then
		createWidget(oldIcon)
	end
end

sdlext.addUiRootCreatedHook(function(screen, root)
	uiRoot = root
	
	for id, v in pairs(icons) do
		if not v.UiCreated then
			createWidget(id)
		end
	end
end)

function this:load()
	modApi:addMissionEndHook(function(mission)
		-- in special cases where an enemy pawn is taken control of
		-- by the player, and is selected at the end of the mission.
		-- simple solution: stop draw, and let the original icon
		-- be displayed instead.
		mission.lmn_supress_icon_draw = true
	end)
end

return this