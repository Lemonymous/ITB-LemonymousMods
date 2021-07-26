
local path = mod_loader.mods[modApi.currentMod].scriptPath
local ceo_rst_gray = require(path .."replaceIsland/ceo_rst_grayscale")
local this = {}

function this.loadIslandOrder()
	local m = lmn_replace_island
	
	m.islandOrder = {}
	for island, _ in pairs(m.islands) do
		table.insert(m.islandOrder, island)
	end
	
	local order = {}
	local i = 0
	sdlext.config("modcontent.lua", function(obj)
		for _, island in ipairs(m.mostRecent.defaultCorps) do
			if not list_contains(obj.islandOrder or {}) then
				i = i + 1
				order[island] = i
			end
		end
		
		for _, island in ipairs(obj.islandOrder or {}) do
			i = i + 1
			order[island] = i
		end
	end)
	
	for island, _ in pairs(m.islands) do
		if not order[island] then
			i = i + 1
			order[island] = i
		end
	end
	
	table.sort(m.islandOrder, function(a,b)
		return order[a] < order[b]
	end)
end

function this.saveIslandOrder()
	local m = lmn_replace_island
	
	sdlext.config("modcontent.lua", function(obj)
		obj.islandOrder = m.islandOrder
	end)
end

-- ui based heavily on pilot_arrange.lua from the mod_loader.
function this.createUi()
	local m = lmn_replace_island
	
	local islandButtons = {}
	
	local onExit = function(self)
		m.islandOrder = {}
		
		for i = 1, #islandButtons do
			m.islandOrder[i] = islandButtons[i].id
		end
		
		m.saveIslandOrder()
	end
	
	sdlext.showDialog(function(ui)
		ui.onDialogExit = onExit
		
		local portraitW = 122 + 8
		local portraitH = 122 + 8
		local gap = 10
		local cellW = portraitW + gap
		local cellH = portraitH + gap
		
		local frametop = Ui()
			:width(0.4):height(0.8)
			:posCentered()
			:caption(m.texts.IslandArrange_FrameTitle)
			:decorate({ DecoFrameHeader(), DecoFrame() })
			:addTo(ui)
		
		local scrollarea = UiScrollArea()
			:width(1):height(1)
			:padding(24)
			:addTo(frametop)
		
		local placeholder = Ui()
			:pospx(-cellW, -cellH)
			:widthpx(portraitW):heightpx(portraitH)
			:decorate({ })
			:addTo(scrollarea)
		
		local portraitsPerRow = math.floor(ui.w * frametop.wPercent / cellW)
		frametop
			:width((portraitsPerRow * cellW + scrollarea.padl + scrollarea.padr) / ui.w)
			:posCentered()
		
		local draggedElement
		local function rearrange()
			local index = list_indexof(islandButtons, placeholder)
			if index ~= nil and draggedElement ~= nil then
				local col = math.floor(draggedElement.x / cellW + 0.5)
				local row = math.floor(draggedElement.y / cellH + 0.5)
				local desiredIndex = 1 + col + row * portraitsPerRow
				
				if desiredIndex < 1 then desiredIndex = 1 end
				if desiredIndex > #islandButtons then desiredIndex = #islandButtons end
				
				if desiredIndex ~= index then
					table.remove(islandButtons, index)
					table.insert(islandButtons, desiredIndex, placeholder)
				end
				
				-- always put RST back to slot 2.
				if not m.unlockRst and islandButtons[2].id ~= "Corp_Desert" then
					for i, v in ipairs(islandButtons) do
						if v.id == "Corp_Desert" then
							if i ~= 2 then
								table.remove(islandButtons, i)
								table.insert(islandButtons, 2, v)
								break
							end
						end
					end
				end
			end
			
			for i = 1, #islandButtons do
				local col = (i - 1) % portraitsPerRow
				local row = math.floor((i - 1) / portraitsPerRow)
				local button = islandButtons[i]
				
				button:pospx(cellW * col, cellH * row)
				if button == placeholder then
					placeholderIndex = i
				end
			end
			
			if placeholderIndex ~= nil and draggedElement ~= nil then
			
			end
		end
		
		local function addIslandButton(i, id)
			local island = m.islands[id]
			local corp = m.corps[island.corp]
			local col = (i - 1) % portraitsPerRow
			local row = math.floor((i - 1) / portraitsPerRow)
			
			local surface = sdl.scaled(2, sdlext.surface("img/portraits/ceo/".. corp.CEO_Image))
			local button = Ui()
				:widthpx(portraitW):heightpx(portraitH)
				:pospx(cellW * col, cellH * row)
				:settooltip(m.corps[island.corp].Name)
				:decorate({
					DecoButton(),
					DecoAlign(-4),
					DecoSurface(surface)
				})
				:addTo(scrollarea)
			
			-- Make RST grayscale and lock the button from moving.
			if not m.unlockRst and id == "Corp_Desert" then
				local surface = ceo_rst_gray
				button
					:decorate({
						DecoFrame(),
						DecoAlign(2, -2),
						DecoSurface(surface)
					})
					:settooltip(m.corps[island.corp].Name .." is LOCKED due to final mission")
					.disabled = true
			else
				button:registerDragMove()
			end
			button.id = id
			
			islandButtons[i] = button
			
			button.startDrag = function(self, mx, my, btn)
				UiDraggable.startDrag(self, mx, my, btn)
				
				draggedElement = self
				placeholder.x = self.x
				placeholder.y = self.y
				
				local index = list_indexof(islandButtons, self)
				if index ~= nil then
					islandButtons[index] = placeholder
				end
				
				self:bringToTop()
				rearrange()
			end
			
			button.stopDrag = function(self, mx, my, btn)
				UiDraggable.stopDrag(self, mx, my, btn)
				
				local index = list_indexof(islandButtons, placeholder)
				if index ~= nil and draggedElement ~= nil then
					islandButtons[index] = draggedElement
				end
				
				placeholder:pospx(-2 * cellW, -2 * cellH)
				
				draggedElement = nil
				
				rearrange()
			end
			
			button.dragMove = function(self, mx, my)
				UiDraggable.dragMove(self, mx, my)
				
				rearrange()
			end
		end
		
		for i = 1, #m.islandOrder do
			addIslandButton(#islandButtons + 1, m.islandOrder[i])
		end
	end)
end

return this