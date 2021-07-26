
-- TODO: scale = 2 fails on fullscreen stretch scaling.
local this = { scale = 2, sdlUi = {}, deco = {}, spawnData = {}, time = 0}

local pilot = {
	Id = "Pilot_lmn_Slug",
	Personality = "lmn_Slug",
	Name = "Slocknog",
	Rarity = 1,
	Voice = "/voice/kazaaakpleth",
	Skill = "lmn_slug_telepath",
}

local function IsAbilityActive()
	local pawn = this.selected:Get()
	return 
		pawn								and
		not pawn:IsDead()					and
		pawn:IsAbility("lmn_slug_telepath")	and
		pawn:GetArmedWeaponId() <= 0
end

function this:init(mod)
	
	self.id = mod.id .."_slug_"
	
	self.tileToScreen = require(mod.scriptPath .."tileToScreen")
	self.selected = require(mod.scriptPath .."selected")
	self.selected:init()
	
	CreatePilot(pilot)
	
	require(mod.scriptPath .."pilotSkill_tooltip").Add("lmn_slug_telepath", PilotSkill("Telepathic", "Reveals emerging Vek."))
	require(mod.scriptPath .."personality_slug")
	
	modApi:appendAsset("img/portraits/pilots/Pilot_lmn_Slug.png", mod.resourcePath .."img/portraits/pilots/pilot_slug.png")
	modApi:appendAsset("img/portraits/pilots/Pilot_lmn_Slug_2.png", mod.resourcePath .."img/portraits/pilots/pilot_slug_2.png")
	modApi:appendAsset("img/portraits/pilots/Pilot_lmn_Slug_blink.png", mod.resourcePath .."img/portraits/pilots/pilot_slug_blink.png")
	
	modApi:appendAsset("img/effects/smoke/lmn_slug_telepath_smoke.png", mod.resourcePath .."img/effects/smoke/psi_smoke.png")
	
	lmn_Emitter_slug_telepath = Emitter:new{
		image = "effects/smoke/lmn_slug_telepath_smoke.png",
		fade_in = true,
		fade_out = true,
		max_alpha = 0.25,
		x = 0,
		y = 0,
		variance = 0,
		variance_x = 20,
		variance_y = 15,
		lifespan = 1.0,
		burst_count = 1,
		speed = 0.80,
		rot_speed = 360,
		gravity = false,
		layer = LAYER_BACK,
		
		angle_variance = 360,
	}
	
	local anim = ANIMS.Animation:new{
		Loop = false,
		NumFrames = 1,
		PosX = 0,
		PosY = -12,
		Layer = LAYER_FRONT,
		Time = 0, -- displays animation for one frame.
		Sound = "",
	}
	
	local function setupAnim(img)
		ANIMS[self.id .. img] = anim:new{Image = img}
		return self.id .. img
	end
	
	self.leaders = {
		[LEADER_HEALTH] =	setupAnim("combat/icons/icon_hp_glow.png"),
		[LEADER_ARMOR] =	setupAnim("combat/icons/icon_armor_leader_glow.png"),
		[LEADER_REGEN] =	setupAnim("combat/icons/icon_regen_glow.png"),
		[LEADER_EXPLODE] =	setupAnim("combat/icons/icon_explode_leader_glow.png"),
		[LEADER_TENTACLE] =	setupAnim("combat/icons/icon_tentacle_glow.png"),
		[LEADER_BOSS] =		setupAnim("combat/icons/icon_psionboss_glow.png")
	}
	
	anim.PosY = -12
	self.tiers = {
		[TIER_ALPHA] =		setupAnim("combat/icons/icon_purple_glow.png"),
		[TIER_BOSS] =		setupAnim("combat/icons/icon_boss_glow.png")
	}
	
	local display = false
	sdlext.addFrameDrawnHook(function(screen)
		if self.options and not self.options['color_emerging_vek'].enabled then return end
		local mission = GetCurrentMission()
		
		if not IsAbilityActive() then
			if display then
				display = false
				
				for _, element in ipairs(self.sdlUi) do
					element.visible = false
				end
			end
		else
			if not mission or not Board then return end
			if not display then
				display = true
				self.spawnData = {}
				
				for i, spawn in ipairs(mission.QueuedSpawns) do
					
					self.sdlUi[i] = self.sdlUi[i] or Ui()
						:addTo(sdlext.getUiRoot())
					self.sdlUi[i].translucent = true
					self.sdlUi[i].visible = false
					
					local spawn = shallow_copy(spawn)
					local pawnData = _G[spawn.type]
					local animData = ANIMS[pawnData.Image]
					self.spawnData[i] = spawn
					
					if animData then
						if not self.deco[spawn.type] then
							self.deco[spawn.type] = DecoSurface(sdl.scaled(self.scale, sdlext.surface("img/".. animData.Image)))
							local deco = self.deco[spawn.type]
							local surface = deco.surface
								
							deco.draw = function(self, screen, widget)
								widget:update()
								screen:clip(widget.cliprect)
								--self.color = sdl.rgba(255,255,255,100) -- TODO: figure out how to make surface transparent.
								DecoSurface.draw(self, screen, widget)
								screen:unclip()
							end
						end
						
						local deco = self.deco[spawn.type]
						local surface = deco.surface
						local loc = self.tileToScreen(spawn.location)
						
						self.sdlUi[i]:pospx(loc.x, loc.y)
							:widthpx(surface:w())
							:heightpx(surface:h())
							:decorate({ deco })
						
						self.sdlUi[i].update = function(self)
							local w = math.floor(surface:w() / animData.NumFrames)
							local h = math.floor(surface:h() / animData.Height or 1)
							
							self.rect.x = self.rect.x + animData.PosX * this.scale
							self.rect.y = self.rect.y - h * pawnData.ImageOffset + (animData.PosY - 15) * this.scale
							self.cliprect = sdl.rect(self.rect.x, self.rect.y + h * pawnData.ImageOffset, w, h)
							self.visible = not rect_intersects(self.cliprect, sdlext.CurrentWindowRect) -- TODO: this only detects a few clips. Good enough for now.
						end
					end
				end
			end
			
			for i, spawn in ipairs(self.spawnData) do
				self.sdlUi[i]:update()
				
				Board:AddBurst(spawn.location, "lmn_Emitter_slug_telepath", DIR_NONE)
			end
		end
	end)
end

function this:load(modApiExt, options)
	self.options = options
	self.selected:load(modApiExt)
	
	if options['color_emerging_vek'].enabled then
		return
	end
	
	-- Alternate method to creating images using the built-in animation system of the game.
	-- This is less prone to drawing errors like scaling/clipping issues or possible positional errors on other display settings than I have tested.
	-- I was unfortunately unable to figure out a way to draw units in alpha/boss color as well as jelly type.
	-- TODO: find a way? Improbable.
	local display = false
	modApi:addMissionUpdateHook(function(mission)
		
		if not IsAbilityActive() then
			display = false
		else
			if not display then
				display = true
				self.spawnData = {}
				
				for _, spawn in ipairs(mission.QueuedSpawns) do
					local spawn = shallow_copy(spawn)
					table.insert(self.spawnData, spawn)
					
					local pawnData = _G[spawn.type]
					local animData = ANIMS[pawnData.Image]
					spawn.anim_static = self.id .. pawnData.Image .."_static"
					
					if not ANIMS[spawn.anim_static] then
						ANIMS[spawn.anim_static] = animData:new{
							Loop = false,
							NumFrames = 1,
							
							PosY = animData.PosY - 15,
							Layer = LAYER_FRONT,
							Time = 0, -- displays animation for one frame.
							Sound = "",
						}
						
						ANIMS[spawn.anim_static].Frames = nil
						ANIMS[spawn.anim_static].Lengths = nil
					end
					
					if pawnData.Tier then
						spawn.tier = self.tiers[pawnData.Tier]
					end
					
					if pawnData.Leader then
						spawn.leader = self.leaders[pawnData.Leader]
					end
				end
			end
			
			for _, spawn in ipairs(self.spawnData) do
				Board:AddAnimation(spawn.location, spawn.anim_static, ANIM_NO_DELAY)
				if spawn.leader then
					Board:AddAnimation(spawn.location, spawn.leader, ANIM_NO_DELAY)
				end
				if spawn.tier then
					if spawn.leader then
						ANIMS[spawn.tier].PosX = 7
						ANIMS[spawn.tier].PosY = -5
					end
					Board:AddAnimation(spawn.location, spawn.tier, ANIM_NO_DELAY)
					if spawn.leader then
						ANIMS[spawn.tier].PosX = 0
						ANIMS[spawn.tier].PosY = -12
					end
				end
				Board:AddBurst(spawn.location, "lmn_Emitter_slug_telepath", DIR_NONE)
			end
		end
	end)
end

return this