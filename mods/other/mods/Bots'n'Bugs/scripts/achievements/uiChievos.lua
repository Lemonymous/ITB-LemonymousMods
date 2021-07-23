
local path = mod_loader.mods[modApi.currentMod].scriptPath
local DecoChievo = require(path .."achievements/decoChievo")
local DecoSurfaceCentered = require(path .."achievements/decoSurfaceCentered")
local DecoTAlignedText = require(path .."achievements/decoTAlignedText")
local UiTooltipStatic = require(path .."achievements/uiTooltipStatic")
local surface_x, surface_undo

local function pad(widget, pad)
	widget.padt = widget.padt + (pad.padt or pad.padh or pad.pad or 0)
	widget.padr = widget.padr + (pad.padr or pad.padw or pad.pad or 0)
	widget.padb = widget.padb + (pad.padb or pad.padh or pad.pad or 0)
	widget.padl = widget.padl + (pad.padl or pad.padw or pad.pad or 0)
end

local function createUi()
	local m = lmn_achievements
	local root = sdlext.getUiRoot()
	surface_x = surface_x or sdlext.surface("img/ui/lmn_trash.png")
	surface_undo = surface_undo or sdlext.surface("img/ui/lmn_undo.png")
	
	local Tooltip = UiTooltipStatic()
		:addTo(root)
	local Reset = {}
	
	sdlext.showDialog(function(ui)
		ui.onDialogExit = function(self)
			for modId, reset in pairs(Reset) do
				if reset then
					lmn_achievements.chievos[modId].TriggerAll(false)
				end
			end
		end
		--[[
			header
			main
				scrollarea
					modframe
						modheader
						icon
		]]
		
		local header = {
			height = 50,
			gaph = 8
		}
		
		local main = {
			-- width is derived
			height = 570,
			padl = 38,
			padr = 44 - 16,
			padh = 13,
			scrollw = 16,
			border = 2,
		}
		
		local modframe = {
			padt = 28,
			padb = 7,
			padl = 6,
			padr = 7,
			gaph = 5,
			border = 2,
		}
		
		local modheader = {
			padt = 10
		}
		
		local iconsPerRow = 8
		local icon = {
			width = 64,
			height = 64,
			gapw = 8,
			gaph = 8,
		}
		
		local tooltip = {
			-- width is derived
			-- height is derived
			gaph = 8,
			padt = 12,
			padl = 14,
			padr = 14,
			padb = 12
		}
		
		local modreset = {
			width = 24,
			height = 24,
			x = -8,
			y = 2
		}
		
		main.width = iconsPerRow * (icon.width + icon.gapw) - icon.gapw
			+ modframe.padl + modframe.padr + modframe.border * 2
			+ main.padl + main.padr + main.scrollw + main.border * 2
			
		local Main = Ui()
			:width(1):height(main.height / ui.h)
			:decorate({ DecoFrame() })
			:addTo(ui)
			
		local Header = Ui()
			:width(1):height(1)
			:caption(m.texts.FrameTitle)
			:decorate({ DecoFrameHeader() })
			:addTo(ui)
			
		local scrollarea = UiScrollArea()
			:width(1):height(1)
			:addTo(Main)
			
		Main.translucent = true
		Header.translucent = true
		
		pad(scrollarea, main)
		
		Main
			:width(main.width / ui.w)
			:posCentered()
		Header
			:width(main.width / ui.w)
			:posCentered()
			:setypx(ui.h / 2 - main.height / 2 - header.height - header.gaph)
		
		local currPosH = 0
		local ModFrame
		
		local function addModFrame(mod, chievoCount)
			local rows = math.ceil(chievoCount / iconsPerRow)
			local height = rows * (icon.height + icon.gaph) - icon.gaph
				+ modframe.padt + modframe.padb + modframe.border * 2
			
			local ModReset = Ui()
				:widthpx(modreset.width):heightpx(modreset.height)
				:pospx(iconsPerRow * (icon.width + icon.gapw) - icon.gapw
					+ modframe.padl + modframe.padr + modframe.border * 2
					+ (main.padr + main.scrollw) / 2 - modreset.width / 2,
					currPosH + height / 2 - modreset.height / 2)
				:settooltip("RESET ACHIEVEMENTS")
				:decorate({
					DecoButton(),
					DecoSurfaceCentered(surface_x)
				})
				:addTo(scrollarea)
				
			function ModReset:onclicked()
				Reset[mod.id] = not Reset[mod.id]
				self.tooltip = Reset[mod.id] and "UNDO" or "RESET ACHIEVEMENTS"
				self.root.tooltip = self.tooltip
				self.root.tooltipUi.visible = false
				
				self.decorations[2].surface = Reset[mod.id] and surface_undo or surface_x
				
				return true
			end
				
			local ModHeader = Ui()
				:width(1):height(0)
				:pospx(0, currPosH + modheader.padt)
				:decorate({ DecoTAlignedText(mod.name) })
				:addTo(scrollarea)
				
			ModHeader.translucent = true
			
			ModFrame = Ui()
				:width(1):heightpx(height)
				:pospx(0, currPosH)
				:caption(mod.name)
				:decorate({ DecoFrame(deco.colors.button) })
				:addTo(scrollarea)
				
			ModFrame.translucent = true
			
			pad(ModFrame, modframe)
			currPosH = currPosH + height + modframe.gaph
		end
		
		local function addChievo(i, mod, chievo)
			local surface = sdlext.surface(chievo.GetStatus() and chievo.img or chievo.img_gray)
			local surface_gray = sdlext.surface(chievo.img_gray)
			
			-- row 0-n; col 0-n
			local row = math.ceil(i / iconsPerRow) - 1
			local col = (i-1) % iconsPerRow
			
			local Button = Ui()
				:addTo(ModFrame)
				:widthpx(icon.width):heightpx(icon.height)
				:pospx((icon.width + icon.gapw) * col, (icon.height + icon.gaph) * row)
				:decorate({
					DecoSurfaceCentered(surface),
					DecoChievo(),
				})
			
			function Button:draw(screen)
				self.decorations[1].surface = Reset[mod.id] and surface_gray or surface
				
				if self.hovered then
					Tooltip:Set(self, chievo.name, chievo.GetTip(Reset[mod.id]))
				end
				Ui.draw(self, screen)
			end
		end
		
		for modId, chievos in pairs(m.chievos) do
			local mod = mod_loader.mods[modId]
			addModFrame(mod, #chievos)
			
			for i, chievo in ipairs(chievos) do
				addChievo(i, mod, chievo)
				
			end
		end
	end)
end

return createUi