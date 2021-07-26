
local path = mod_loader.mods[modApi.currentMod].resourcePath
local utils = require(path .."scripts/utils")
local tileToScreen = require(path .."scripts/tileToScreen")
local getWeapons = require(path .."scripts/getWeapons")
local weaponPreview = require(path .."scripts/weaponPreview/api")

modApi:appendAsset("img/weapons/lmn_bioscanner.png", path .."img/weapons/bioscanner.png")
modApi:appendAsset("img/combat/lmn_bioscanner_square.png", path .."img/combat/bioscanner_square.png")
modApi:appendAsset("img/combat/lmn_bioscanner_square_red.png", path .."img/combat/bioscanner_square_red.png")

local a = ANIMS
local scan
--local scale = 2

a.lmn_Bioscanner_Radio = a.Animation:new{
	Image = "combat/icons/radio_animate.png",
	PosX = -16, PosY = -8,
	NumFrames = 3,
	Time = 0.1,
	Frames = {0,1,2,1,0,1,2,1,0},
}

a.lmn_Bioscanner_Square = a.Animation:new{
	Image = "combat/lmn_bioscanner_square.png",
	PosX = -27, PosY = 2, Time = .15,
	Layer = LAYER_FLOOR
}

a.lmn_Bioscanner_Square_Red = a.lmn_Bioscanner_Square:new{
	Image = "combat/lmn_bioscanner_square_red.png",
}

local pos = Location["combat/icons/icon_emerge_glow.png"]
a.lmn_Bioscanner_Icon_Emerge = a.Animation:new{
	Image = "combat/icons/icon_emerge_glow.png",
	PosX = pos.x, PosY = pos.y, Loop = false, Time = 3.7
}

a.lmn_Bioscanner_Emerge = a.Emerge:new{
	Frames = {0,1,2,3,4,5,0,1,2,3,4,5,0,1,2,3,4,5,0,1,2,3,4,5,0,1,2,3,4,5,0,1,2,3,4,5,0},
	Loop = false, Layer = LAYER_FRONT
}

a.lmn_Bioscanner_Scorpion = a.lmn_Sunflower1:new{
	PosY = a.lmn_Sunflower1.PosY - 15,
	Loop = false,
	Time = 2
}

local function Stop()
	scan:detach()
	scan = nil
end

local function createUi(p)
	local root = sdlext.getUiRoot()
	
	local pawn = Board:GetPawn(p)
	if not pawn then return end
	local weapons = getWeapons:GetPoweredBase(pawn)
	local weaponIndex = list_indexof(weapons, "lmn_Bioscanner")
	weaponIndex = weaponIndex > 0 and weaponIndex or nil
	
	local m = GetCurrentMission()
	if not m or not Board or pawn:GetArmedWeaponId() ~= weaponIndex then return end
	
	scan = Ui()
		:width(1)
		:height(1)
		:addTo(root)
	scan.translucent = true
	
	scan.draw = function(self, ...)
		if Board and pawn:GetArmedWeaponId() == weaponIndex then
			Ui.draw(self, ...)
		else
			Stop()
		end
	end
	
	local fx = SkillEffect()
	
	fx:AddScript(string.format("Board:Ping(%s, GL_Color(100, 255, 255))", p:GetString()))
	fx:AddScript(string.format("Board:AddAnimation(%s, 'lmn_Bioscanner_Radio', ANIM_NO_DELAY)", p:GetString()))
	fx:AddSound("/ui/general/mech_selection")
	
	local spawns = {}
	for _, spawn in ipairs(m.QueuedSpawns) do
		spawns[p2idx(spawn.location)] = spawn
	end
	
	weaponPreview:SetLooping(false)
	
	local list = utils.getBoard()
	for i, v in ipairs(list) do
		local dist_x = math.abs(v.x - p.x)
		local dist_y = math.abs(v.y - p.y)
		list[i] = {p = v, dist =  math.sqrt(dist_x * dist_x + dist_y * dist_y)}
	end
	table.sort(list, function(a,b) return a.dist > b.dist end)
	
	local radius = 0
	-- keep checking the closest tile in the list,
	-- until the list is empty.
	while #list > 0 do
		-- for every tile that is within distance;
		while #list > 0 and list[#list].dist <= radius do
			
			local n = list[#list]
			local pid = p2idx(n.p)
			
			local spawn = spawns[pid]
			if spawn then
				fx:AddSound("/ui/battle/select_unit")
				fx:AddScript(string.format("lmn_Bioscanner:ScanSpawnPoint(%s)", save_table(spawn)))
				fx:AddScript(string.format("Board:Ping(%s, GL_Color(255, 50, 0))", spawn.location:GetString()))
				spawns[pid] = nil
			end
			
			weaponPreview:AddSimpleColor(n.p, GL_Color(128,255,200), .15)
			
			-- and remove the tile from the list.
			table.remove(list, #list)
		end
		
		-- increase radius,
		radius = radius + 0.2
		-- and wait a little.
		weaponPreview:AddDelay(1/60)
		if not utils.list_isEmpty(spawns) then
			fx:AddDelay(1/60)
		end
		-- repeat.
	end
	
	Board:AddEffect(fx)
end

lmn_Bioscanner = Skill:new{
	Name = "Bioscanner",
	Description = "Reveal emerging Vek\n(free action)",
	Rarity = 1,
	Class = "",
	Icon = "weapons/lmn_bioscanner.png",
	PowerCost = 0,
	CustomTipImage = "lmn_Bioscanner_Tip",
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,1),
		Spawn = Point(2,1)
	}
}

function lmn_Bioscanner:ScanSpawnPoint(spawn)
	if not scan then return end
	
	local data = _G[spawn.type]
	local anim = a[data.Image]
	if anim then
		local scale = GetBoardScale() * GetUiScale()
		local deco = DecoSurface(sdl.scaled(scale, sdlext.surface("img/".. anim.Image)))
		local surface = deco.surface
		local loc = tileToScreen(spawn.location)
		
		local icon = Ui()
			:widthpx(surface:w())
			:heightpx(surface:h())
			:decorate({ deco })
			:addTo(scan)
			:pospx(loc.x, loc.y)
		icon.translucent = true
		icon.visible = true
		
		local w = math.floor(surface:w() / (anim.NumFrames or 1))
		local h = math.floor(surface:h() / (anim.Height or 1))
		icon.x = icon.x + anim.PosX * scale
		icon.y = icon.y - h * data.ImageOffset + (anim.PosY - 15) * scale
		icon.cliprect = sdl.rect(icon.x, icon.y + h * data.ImageOffset, w, h)
		
		deco.draw = function(self, screen, widget)
			screen:clip(widget.cliprect)
			DecoSurface.draw(self, screen, widget)
			screen:unclip()
		end
	end
end

function lmn_Bioscanner:GetTargetArea(p)
	local ret = PointList()
	local user = Board:GetPawn(p)
	if not user then return ret end
	
	local size = Board:GetSize()
	for x = 0, size.x - 1 do
		for y = 0, size.y - 1 do
			local curr = Point(x,y)
			if Board:IsSpawning(curr) then
				ret:push_back(curr)
			end
		end
	end
	
	if not scan then
		createUi(p)
	end
	
	return ret
end

lmn_Bioscanner_Tip = lmn_Bioscanner:new{}
function lmn_Bioscanner_Tip:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local spawn = self.TipImage.Spawn
	Board:SpawnQueued()
	Board:RemovePawn(Board:GetPawn(spawn))
	Board:AddAnimation(spawn, "lmn_Bioscanner_Icon_Emerge", ANIM_NO_DELAY)
	Board:AddAnimation(spawn, "lmn_Bioscanner_Emerge", ANIM_NO_DELAY)
	
	ret:AddScript(string.format("Board:Ping(%s, GL_Color(100, 255, 255))", p1:GetString()))
	ret:AddScript(string.format("Board:AddAnimation(%s, 'lmn_Bioscanner_Radio', ANIM_NO_DELAY)", p1:GetString()))
	
	local list = utils.getBoard()
	for i, v in ipairs(list) do
		local dist_x = math.abs(v.x - p1.x)
		local dist_y = math.abs(v.y - p1.y)
		list[i] = {p = v, dist =  math.sqrt(dist_x * dist_x + dist_y * dist_y)}
	end
	table.sort(list, function(a,b) return a.dist > b.dist end)
	
	local radius = 0
	-- keep checking the closest tile in the list,
	-- until the list is empty.
	while #list > 0 do
		-- for every tile that is within distance;
		while #list > 0 and list[#list].dist <= radius do
			
			local n = list[#list]
			
			if n.p == spawn then
				ret:AddScript(string.format("Board:Ping(%s, GL_Color(255, 50, 0))", n.p:GetString()))
				ret:AddAnimation(n.p, "lmn_Bioscanner_Square_Red")
				ret:AddAnimation(n.p, "lmn_Bioscanner_Scorpion")
			else
				ret:AddAnimation(n.p, "lmn_Bioscanner_Square")
			end
			
			-- and remove the tile from the list.
			table.remove(list, #list)
		end
		
		-- increase radius,
		radius = radius + 0.2
		-- and wait a little
		ret:AddDelay(1/60)
		-- repeat.
	end
	
	return ret
end
