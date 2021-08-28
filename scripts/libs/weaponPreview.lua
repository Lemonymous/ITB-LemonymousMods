
-----------------------------------------------------------------------------
-- Weapon Preview v2.2.prelim2* - code library
--[[-------------------------------------------------------------------------
	* paths modified for current mod
	
	API for
	 - enhancing preview of weapons/move/repair skills with
		- damage marks
		- colored tiles
		- tile descriptions
		- tile images
		- animations
		- emitters
	
	
	 library dependencies:
	=======================
	modApiExt - manual init/load
	
	
	 request api:
	==============
	local path = mod_loader.mods[modApi.currentMod].scriptPath
	local previewer = require(path .."weaponPreview/api")
	
	library must be requested at init at least once and it will automatically initialize.
	
	
	 load library: (required)
	===============
	require(self.scriptPath .."weaponPreview/api"):load()
	
	place in load function in init.lua
	
	
	-----------------
	   Method List
	-----------------
	all methods except 'load' are meant to be used in either GetTargetArea or GetSkillEffect, whichever makes the most sense.
	GetTargetArea can display marks as soon as a weapon is selected.
	GetSkillEffect can display marks only after a tile is highlighted, and should be used if mark is dependent of target location.
	
	
	previewer:load()
	================
	loads library. (required)
	
	
	previewer:AddDelay(duration)
	============================
	adds a delay before next preview;
	essentially animating the preview data, and looping it.
	
	field    | type  | description
	---------+-------+------------------
	duration | float | delay in seconds
	---------+-------+------------------
	
	
	previewer:SetLooping(flag)
	==========================
	previews loop by default.
	if looping is set to false, preview data will be displayed
	until there are no more calls to AddDelay.
	after the last AddDelay, any preview data added after it will display continuously.
	
	field | type    | description
	------+---------+-----------------------------
	flag  | boolean | sets looping if true or nil
	------+---------+-----------------------------
	
	
	previewer:AddDamage(damage)
	===========================
	marks the board with a SpaceDamage object.
	
	field  | type        | description
	-------+-------------+-------------------
	damage | SpaceDamage | object to preview
	-------+-------------+-------------------
	
	
	previewer:AddColor(tile, gl_color)
	==================================
	colors a tile. different color marks can combine to show both.
	
	field    | type     | description
	---------+----------+-------------
	tile     | Point    | location
	gl_color | GL_Color | tile color
	---------+----------+-------------
	
	
	previewer:AddSimpleColor(tile, gl_color)
	========================================
	colors a tile. simple color does not combine colors with other color marks.
	
	field    | type     | description
	---------+----------+-------------
	tile     | Point    | location
	gl_color | GL_Color | tile color
	---------+----------+-------------
	
	
	previewer:AddImage(tile, imagePath, gl_color)
	=============================================
	adds an image to a tile.
	
	field     | type     | description
	----------+----------+--------------------
	tile      | Point    | location
	imagePath | string   | file path to image
	gl_color  | GL_Color | image color
	----------+----------+--------------------
	
	
	previewer:AddDesc(tile, desc, flag)
	===================================
	adds a description to a tile.
	
	field | type    | description
	------+---------+------------------
	tile  | Point   | location
	desc  | string  | tile description
	flag  | boolean | ?
	------+---------+------------------
	
	
	previewer:AddFlashing(tile, flag)
	=================================
	causes a building to flash.
	
	field | type    | description
	------+---------+-------------
	tile  | Point   | location
	flag  | boolean | ?
	------+---------+-------------
	
	
	previewer:AddAnimation(tile, anim)
	==================================
	plays an animation at a tile.
	
	field | type    | description
	------+---------+-----------------
	tile  | Point   | location
	anim  | string  | id of animation
	------+---------+-----------------
	
	
	previewer:AddEmitter(tile, emitter)
	===================================
	plays an animation at a tile.
	
	field   | type    | description
	--------+---------+---------------
	tile    | Point   | location
	emitter | string  | id of emitter
	--------+---------+---------------
	
	
	previewer:ClearMarks()
	======================
	not intended for normal use,
	but it can be used to clear
	all currently added marks if needed.
	
	
]]---------------------------------------------------------------------------


if Assert.TypeGLColor == nil then
	local function traceback()
		return Assert.Traceback and debug.traceback("\n", 3) or ""
	end

	function Assert.TypeGLColor(arg, msg)
		msg = (msg and msg .. ": ") or ""
		msg = msg .. string.format("Expected GL_Color, but was %s%s", tostring(type(arg)), traceback())
		assert(
			type(arg) == "userdata" and
			type(arg.r) == "number" and
			type(arg.g) == "number" and
			type(arg.b) == "number" and
			type(arg.a) == "number", msg
		)
	end
end

local mod = mod_loader.mods[modApi.currentMod]

local this = {}
local marker = {area = {weapon = {start = 0}}, effect = {weapon = {start = 0}}}
local marks = marker.area
local frame = -1
local a = ANIMS
local ignoreCall
local taggedSkills = {}
local doMarkTile = {}

local function spaceEmitter(loc, emitter)
	local fx = SkillEffect()
	fx:AddEmitter(loc, emitter)
	return fx.effect:index(1)
end

local function isMarkIgnored()
	return ignoreCall or Board:IsTipImage() or not Board:GetSelectedPawn()
end

local function isMarkUnavailable()
	return marks == nil or isMarkIgnored() or frame ~= marks.weapon.start
end

function this:AddDamage(d, duration)
	if isMarkUnavailable() then return end

	Assert.Equals({'userdata', 'table'}, type(d), "Argument #1")
	Assert.Equals({'nil', 'number'}, type(duration), "Argument #2")
	Assert.TypePoint(d.loc, "Argument #1 - Field 'loc'")

	table.insert(marks, {
		fn = 'MarkSpaceDamage',
		data = {shallow_copy(d)},
		duration = duration
	})
end

function this:AddImage(p, path, gl_color, duration)
	if isMarkUnavailable() then return end

	Assert.TypePoint(p, "Argument #1")
	Assert.Equals('string', type(path), "Argument #2")
	Assert.TypeGLColor(gl_color, "Argument #3")
	Assert.Equals({'nil', 'number'}, type(duration), "Argument #4")

	table.insert(marks, {
		fn = 'MarkSpaceImage',
		data = {p, path, gl_color},
		duration = duration
	})
end

function this:AddDesc(p, desc, flag, duration)
	if isMarkUnavailable() then return end

	Assert.TypePoint(p, "Argument #1")
	Assert.Equals('string', type(desc), "Argument #2")
	Assert.Equals({'nil', 'boolean'}, type(flag), "Argument #3")
	Assert.Equals({'nil', 'number'}, type(duration), "Argument #4")

	flag = flag ~= false

	table.insert(marks, {
		fn = 'MarkSpaceDesc',
		data = {p, desc, flag},
		duration = duration
	})
end

function this:AddColor(p, gl_color, duration)
	if isMarkUnavailable() then return end

	Assert.TypePoint(p, "Argument #1")
	Assert.TypeGLColor(gl_color, "Argument #2")
	Assert.Equals({'nil', 'number'}, type(duration), "Argument #3")

	table.insert(marks, {
		fn = 'MarkSpaceColor',
		data = {p, gl_color},
		duration = duration
	})
end

function this:AddSimpleColor(p, gl_color, duration)
	if isMarkUnavailable() then return end

	Assert.TypePoint(p, "Argument #1")
	Assert.TypeGLColor(gl_color, "Argument #2")
	Assert.Equals({'nil', 'number'}, type(duration), "Argument #3")

	table.insert(marks, {
		fn = 'MarkSpaceSimpleColor',
		data = {p, gl_color},
		duration = duration
	})
end

function this:AddFlashing(p, flag, duration)
	if isMarkUnavailable() then return end

	Assert.TypePoint(p, "Argument #1")
	Assert.Equals({'nil', 'boolean'}, type(flag), "Argument #2")
	Assert.Equals({'nil', 'number'}, type(duration), "Argument #3")

	flag = flag ~= false

	table.insert(marks, {
		fn = 'MarkFlashing',
		data = {p, flag},
		duration = duration
	})
end

function this:AddAnimation(p, anim)
	if isMarkUnavailable() then return end

	Assert.TypePoint(p, "Argument #1")
	Assert.Equals('string', type(anim), "Argument #2")
	Assert.NotEquals('nil', type(a[anim]), "Argument #2")

	table.insert(marks, {
		fn = 'AddAnimation',
		anim = anim,
		data = {p, anim, ANIM_NO_DELAY},
		duration = a[anim].Time * a[anim].NumFrames
	})
end

function this:AddEmitter(p, emitter, duration)
	if isMarkUnavailable() then return end

	Assert.TypePoint(p, "Argument #1")
	Assert.Equals('string', type(emitter), "Argument #2")
	Assert.NotEquals('nil', type(_G[emitter]), "Argument #2")
	Assert.Equals({'nil', 'number'}, type(duration), "Argument #3")

	local base = _G[emitter]

	if not _G[emitter .. mod.id] then
		_G[emitter .. mod.id] = base:new{
			timer = .017,
			birth_rate = base.birth_rate,
			burst_count = base.burst_count
		}
	end

	table.insert(marks, {
		fn = 'DamageSpace',
		emitter = emitter,
		data = {spaceEmitter(p, emitter .. mod.id)},
		duration = duration
	})
end

function this:AddDelay(duration)
	if isMarkUnavailable() then return end

	Assert.Equals('number', type(duration), "Argument #1")

	duration = duration * 60 -- fps

	table.insert(marks, {
		delay = duration
	})
	
	marks.length = marks.length or 0
	marks.length = marks.length + duration
end

function this:SetLooping(flag)
	if isMarkUnavailable() then return end
	
	marks.loop = flag
end

local function onModsInitialized()
	-- inject code into all GetTargetArea and GetSkillEffect functions
	for skillId, skill in pairs(_G) do
		if type(skill) == 'table' then
			
			local function addFunc(funcName, markType)
				local function addWeapon(root)
					
					-- reset weapon if at root and time mismatch.
					if (not root or list_contains(root, skillId)) and marks.weapon.start ~= frame then
						marker[markType] = {weapon = {root = skillId, start = frame}}
					end
					
					-- only add weapon if the root skill matches armed weapon id.
					if (not root or list_contains(root, marks.weapon.root)) and marker[markType].weapon.start == frame then
						table.insert(marker[markType].weapon, skillId)
					end
				end
				
				local old = skill[funcName]
				skill[funcName] = function(self, p, ...)
					local id = funcName .. markType
					
					if not taggedSkills[id] then
						taggedSkills[id] = true
						
						marks = marker[markType]
						local selected = Board:GetSelectedPawn()
						
						if not isMarkIgnored() and selected:GetSpace() == p then
							local armedId = selected:GetArmedWeaponId()
							
							if armedId == 0 then
								addWeapon{'Move'}
							elseif armedId == 50 then
								-- not sure if Skill_Repair_A is ever called.
								addWeapon{'Skill_Repair', 'Skill_Repair_A', 'Skill_Repair_Power', 'Skill_Repair_Punch'}
							else
								addWeapon()
							end
							
							marks = marker[markType]
						end
					end
					
					local result = old(self, p, ...)
					
					marks = nil
					
					return result
				end
			end
			
			if type(skill.GetTargetArea) == 'function' then
				addFunc('GetTargetArea', 'area')
			end
			
			if type(skill.GetSkillEffect) == 'function' then
				addFunc('GetSkillEffect', 'effect')
			end
		end
	end
end

local function createAnim(anim)
	local base = a[anim]
	-- create animations if they don't exist.
	if not a[anim .. mod.id .."1"] then
		-- TODO? make work with Frames and Lengths.
		assert(base.Frames == nil, "Weapon Preview library does not support animations with .Frames")
		assert(base.Lengths == nil, "Weapon Preview library does not support animations with .Lengths")
		
		-- chop up animation to single frame units.
		for i = 1, base.NumFrames do
			a[anim .. mod.id .. i] = base:new{
				Frames = {i-1},
				Loop = false,
				Time = 0
			}
		end
	end
end

local function clearMarks()
	marker.area = {weapon = {start = 0}}
	marker.effect = {weapon = {start = 0}}
end

local function nextFrame()
	frame = frame + 1
	doMarkTile = {}
	taggedSkills = {}
end

function this:ClearMarks()
	clearMarks()
end

local function onMissionUpdate()
	local selected = Board:GetSelectedPawn()
	
	if not selected or selected:GetArmedWeaponId() == -1 then
		clearMarks()
		nextFrame()
		
		return
	end
	
	for _, markType in ipairs{'area', 'effect'} do
		
		local marker = marker[markType]
		marker.loop = marker.loop ~= false
		
		local t = 0
		local t1 = frame - marker.weapon.start -- time since start
		if marker.loop then
			t1 = marker.length and frame % marker.length or 0
		end
		
		for _, mark in ipairs(marker) do
			ignoreCall = true
			
			local doMark
			
			if markType == 'area' then
				doMark = true
			elseif markType == 'effect' then
				local selectedTile = selected:GetSpace()
				local cursorTile = Board:GetHighlighted()
				local markId = marker.weapon.root .."_p".. p2idx(selectedTile)
				
				doMark = doMarkTile[markId]
				
				-- we have not cached this yet
				if doMark == nil then
					-- default to false, and change to true if we find a match.
					doMark = false
					
					if cursorTile then
						local targetArea = _G[marker.weapon.root]:GetTargetArea(selectedTile)
						
						-- let's see if it is faster not to extract the table.
						for i = 1, targetArea:size() do
							if cursorTile == targetArea:index(i) then
								
								doMark = true
								break
							end
						end
					end
				end
				
				-- cache result.
				doMarkTile[markId] = doMark
			end
			
			if doMark then
				if mark.fn then
					local duration = mark.duration and mark.duration * 60 or INT_MAX - t
					if t <= t1 and t1 <= t + duration then
						if mark.anim then
							createAnim(mark.anim)
							
							local start = marker.loop and frame or t1
							local f = 1 + math.floor((start % duration) * a[mark.anim].NumFrames / duration)
							mark.data[2] = mark.anim .. mod.id .. f
						end
						
						if not mark.emitter or (t1 - t) % 5 < 1 then
							Board[mark.fn](Board, unpack(mark.data))
						end
					end
				end
				
				t = t + (mark.delay or 0)
			end
			
			ignoreCall = nil
		end
	end
	
	nextFrame()
end

modApi.events.onModsInitialized:subscribe(onModsInitialized)
modApi.events.onMissionStart:subscribe(clearMarks)
modApi.events.onTestMechEntered:subscribe(clearMarks)
modApi.events.onPreLoadGame:subscribe(clearMarks)
modApi.events.onPawnDeselected:subscribe(clearMarks)
modApi.events.onMissionUpdate:subscribe(onMissionUpdate)

return this
