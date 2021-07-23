
local path = mod_loader.mods[modApi.currentMod].scriptPath
local DecoChievo = require(path .."achievements/decoChievo")
local DecoSurfaceCentered = require(path .."achievements/decoSurfaceCentered")
local fontChievo = sdlext.font("fonts/NunitoSans_Bold.ttf", 19)
local shadowl, shadowc, shadowr

local function createUi(chievo)
	local root = sdlext.getUiRoot()
	
	local surface = sdlext.surface(chievo.img)
	local icon = {
		width = surface:w(),
		height = surface:h(),
		gapr = 13
	}
	
	local Text = Ui()
		:width(1):height(1)
		:decorate({ DecoText(chievo.name, fontChievo, deco.textset(deco.colors.white, nil, 0, true)) })
		
	local iconholderW = Text.decorations[1].surface:w() + icon.width + icon.gapr
	
	local main = {
		gapt = 12,
		gapr = 15,
		width =  math.max(310, iconholderW + 23 * 2),
		height = 143,
		border = 2,
	}
	
	main.posx = root.w - main.width - main.gapr
	main.posy = main.gapt
	
	local shadow = {
		posx = 0,
		posy = 48,
		offx = 4,
		offy = -7,
	}
	
	local Main = Ui()
		:widthpx(main.width):heightpx(main.height)
		:pospx(main.posx, main.posy)
		
	shadowl = shadowl or sdlext.surface("img/ui/lmn_chievo_shadowl.png")
	shadowc = shadowc or sdlext.surface("img/ui/lmn_chievo_shadowc.png")
	shadowr = shadowr or sdlext.surface("img/ui/lmn_chievo_shadowr.png")
	
	-- construct shadow.
	local d = {}
	d[#d+1] = DecoSurface(shadowl)
	for i = 1, main.width - 8 * 2 do d[#d+1] = DecoSurface(shadowc) end
	d[#d+1] = DecoSurface(shadowr)
	
	local Shadow = Ui()
		:width(1):height(1)
		:pospx(shadow.posx + shadow.offx, shadow.posy + shadow.offy)
		:decorate(d)
		
	local Frame = Ui()
		:width(1):height(1)
		:caption(chievo.unlockTitle or "Achievement!")
		:settooltip(chievo.GetTip())
		:decorate({ DecoFrameHeader(), DecoFrame() })
		
	local Icon = Ui()
		:widthpx(icon.width):heightpx(icon.height)
		:decorate({
			DecoSurfaceCentered(surface),
			DecoChievo(deco.colors.buttonborderhl, 1, deco.colors.buttonborderhl, 1),
		})
	icon.posX = (main.width - iconholderW) / 2
	icon.posY = (main.height - 48 - icon.height) / 2
	
	Text:pospx(icon.width + icon.gapr, 0)
	
	local IconHolder = Ui()
		:widthpx(iconholderW):heightpx(icon.height)
		:pospx(icon.posX, icon.posY)
	
	Shadow.translucent = true
	IconHolder.translucent = true
	Icon.translucent = true
	Text.translucent = true
	
	IconHolder:add(Icon)
	IconHolder:add(Text)
	Frame:add(IconHolder)
	Main:add(Frame)
	Main:add(Shadow)
	
	Main.animations.fadeOut = UiAnim(Main, 4000, function() end)
	Main.animations.fadeOut.onFinished = function(self) self.widget:detach() end
	Main.animations.fadeOut:start()
	Main:addTo(root):bringToTop()
	
	return Main.animations.fadeOut
end

return createUi