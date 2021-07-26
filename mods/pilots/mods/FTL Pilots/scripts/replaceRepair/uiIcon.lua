
local path = mod_loader.mods[modApi.currentMod].resourcePath
local uiVisiblePawn = require(path .."scripts/replaceRepair/lib/uiVisiblePawn")
local UiCover = require(path .."scripts/replaceRepair/ui/cover")
local clip = require(path .."scripts/replaceRepair/lib/clip")
local menu = require(path .."scripts/replaceRepair/lib/menu")

local icon = sdlext.surface("img/weapons/repair.png")
local iconFrozen = sdlext.surface("img/weapons/repair_frozen.png")
local iconSmoke = sdlext.surface(path .."scripts/replaceRepair/img/smoke.png")
local iconWater = sdlext.surface(path .."scripts/replaceRepair/img/water.png")
local iconAcid = sdlext.surface(path .."scripts/replaceRepair/img/acid.png")
local iconLava = sdlext.surface(path .."scripts/replaceRepair/img/lava.png")

local color_mask_140 = sdl.rgba(0, 0, 0, 140)
local cull_R_letter = sdl.rect(18, 65, 14, 15)

local this = {}

local function getTerrainOverlayIcon(loc)
	local pawn = uiVisiblePawn()
	
	if not pawn then
		return
	end
	
	local loc = pawn:GetSpace()
	local isFlying = pawn:IsFlying()
	
	if Board:IsTerrain(loc, TERRAIN_LAVA) and not isFlying then
		return iconLava
		
	elseif Board:GetTerrain(loc) == TERRAIN_WATER and not isFlying then
		return Board:IsAcid(loc) and iconAcid or iconWater
		
	elseif Board:IsSmoke(loc) and not pawn:IsAbility("Disable_Immunity") then
		return iconSmoke
	end
end

function this.createui()
	sdlext.addUiRootCreatedHook(function(screen, uiRoot)
		
		-- children are added in reverse order
		-- because the last added are drawn first.
		-- draw order: root, main, mask_inactive, mask_overlay, overlay, mask_menu
		
		-- root - container element.
		local root = Ui()
			:widthpx(32):heightpx(80)
			:addTo(uiRoot)
		
		-- 220 alpha black when menu is open
		local mask_menu = UiCover()
			:addTo(root)
		
		-- overlay icon when pawn is in water/smoke
		local overlay = Ui()
			:width(1):height(1)
			:decorate({ DecoSurface() })
			:addTo(root)
		
		-- 140 alpha black when pawn is in water/smoke
		local mask_overlay = Ui()
			:width(1):height(1)
			:decorate({ DecoSolid() })
			:addTo(root)
		
		-- 140 alpha black when pawn is inactive
		local mask_inactive = Ui()
			:width(1):height(1)
			:decorate({ DecoSolid() })
			:addTo(root)
		
		-- main drawn icon
		local main = Ui()
			:width(1):height(1)
			:decorate({ DecoSurface() })
			:addTo(root)
		
		root.visible = false
		root.translucent = true
		main.translucent = true
		mask_menu.translucent = true
		mask_inactive.translucent = true
		mask_overlay.translucent = true
		overlay.translucent = true
		
		main.decorations[1].draw = function(self, screen, widget)
			self.surface = self.surface or self.surfacenormal
			DecoSurface.draw(self, screen, widget)
		end
		
		mask_overlay.decorations[1].color = color_mask_140
		
		root.draw = function(self, screen)
			self.visible = false
			
			local drawnIcon
			local newIcon
			local skill = lmn_replaceRepair.GetCurrentSkill()
			local pawn = uiVisiblePawn()
			
			if not skill then
				return
			end
			
			if icon:wasDrawn() then
				drawnIcon = icon
				newIcon = skill.surface
				
			elseif iconFrozen:wasDrawn() then
				drawnIcon = iconFrozen
				newIcon = skill.surface_frozen or skill.surface
			end
			
			if newIcon then
				self.x = drawnIcon.x
				self.y = drawnIcon.y
				
				self.visible = true
				main.decorations[1].surface = newIcon
				
				self.parent:relayout()
			end
			
			local cullRects = {sdlext.CurrentWindowRect}
			
			if pawn and pawn:IsActive() then
				local rect = sdl.rect(
					self.x + cull_R_letter.x,
					self.y + cull_R_letter.y,
					cull_R_letter.w,
					cull_R_letter.h
				)
				
				table.insert(cullRects, rect)
			end
			
			-- we just need to clip the root's draw,
			-- and all children should stay within the clip area.
			clip(Ui, self, screen, nil, cullRects)
		end
		
		overlay.draw = function(self, screen)
			self.visible = false
			
			if icon:wasDrawn() or iconFrozen:wasDrawn() then
				
				local surface = getTerrainOverlayIcon(loc)
				
				if surface then
					self.visible = true
					self.decorations[1].surface = surface
				end
				
				mask_overlay.visible = self.visible
				
				Ui.draw(self, screen)
			end
		end
		
		mask_inactive.draw = function(self, screen)
			
			local pawn = uiVisiblePawn()
			
			if pawn and not pawn:IsActive() then
				self.decorations[1].color = color_mask_140
			else
				self.decorations[1].color = deco.colors.transparent
			end
			
			Ui.draw(self, screen)
		end
		
		lmn_replaceRepair.icon = root
		lmn_replaceRepair.iconOverlay = overlay
	end)
end

return this
