
----------------------------------------------------------------------
-- Weapon Preview v3.0.0 - code library
-- https://github.com/Lemonymous/ITB-LemonymousMods/wiki/weaponPreview
--
-- by Lemonymous
----------------------------------------------------------------------
--  A library for
--   - enhancing preview of weapons/move/repair skills with
--      - damage marks
--      - colored tiles
--      - tile descriptions
--      - tile images
--      - animations
--      - emitters
--
--  methods:
--      :AddDamage(spaceDamage, duration)
--      :AddImage(point, path, gl_color, duration)
--      :AddDesc(point, desc, flag, duration)
--      :AddColor(point, gl_color, duration)
--      :AddSimpleColor(point, gl_color, duration)
--      :AddFlashing(point, flag, duration)
--      :AddAnimation(point, animation, delay)
--      :AddEmitter(point, emitter, duration)
--      :AddDelay(duration)
--      :SetLooping(flag)
--      :ClearMarks()
--      :ResetTimer()
--
--  All methods are meant to be used in either GetTargetArea or
--  GetSkillEffect, whichever makes the most sense.
--  GetTargetArea can display marks as soon as a weapon is selected.
--  GetSkillEffect can display marks only after a tile is highlighted,
--  and should be used if mark is dependent of target location.
--
----------------------------------------------------------------------


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

local VERSION = "3.0.0"
local PREFIX = "_weapon_preview_%s_"

local STATE_NONE = 0
local STATE_SKILL_EFFECT = 1
local STATE_TARGET_AREA = 2

local oldGetTargetAreas = {}
local oldGetSkillEffects = {}
local globalCounter = 0
local prevArmedWeaponId
local previewTargetArea = PointList()
local previewState = STATE_NONE
local previewMarks = {}

local function spaceEmitter(loc, emitter)
	local fx = SkillEffect()
	fx:AddEmitter(loc, emitter)
	return fx.effect:index(1)
end

local function createAnim(anim)
	local base = ANIMS[anim]
	local prefix = string.format(PREFIX, 1)

	-- chop up animation to single frame units.
	if not ANIMS[prefix..anim] then
		local frames = base.Frames
		local lengths = base.Lengths

		if not frames then
			frames = {}
			for i = 1, base.NumFrames do
				frames[i] = i - 1
			end
		end

		if not lengths then
			lengths = {}
			for i = 1, #frames do
				lengths[i] = base.Time
			end
		end

		for i, frame in ipairs(frames) do
			local prefix = string.format(PREFIX, i)
			ANIMS[prefix..anim] = base:new{
				__NumFrames = #frames,
				__Lengths = lengths,
				Frames = { frame },
				Lengths = nil,
				Loop = false,
				Time = 0,
			}
		end
	end
end

local function sum(t)
	local result = 0
	for i = 1, #t do
		result = result + t[i]
	end
	return result
end

local function isPreviewerUnavailable()
	return previewState == STATE_NONE or Board:IsTipImage()
end

local function addDamage(self, d, duration)
	if isPreviewerUnavailable() then return end

	Assert.Equals({'userdata', 'table'}, type(d), "Argument #1")
	Assert.Equals({'nil', 'number'}, type(duration), "Argument #2")
	Assert.TypePoint(d.loc, "Argument #1 - Field 'loc'")

	table.insert(previewMarks[previewState], {
		fn = 'MarkSpaceDamage',
		data = {shallow_copy(d)},
		duration = duration
	})
end

local function addImage(self, p, path, gl_color, duration)
	if isPreviewerUnavailable() then return end

	Assert.TypePoint(p, "Argument #1")
	Assert.Equals('string', type(path), "Argument #2")
	Assert.TypeGLColor(gl_color, "Argument #3")
	Assert.Equals({'nil', 'number'}, type(duration), "Argument #4")

	table.insert(previewMarks[previewState], {
		fn = 'MarkSpaceImage',
		data = {p, path, gl_color},
		duration = duration
	})
end

local function addDesc(self, p, desc, flag, duration)
	if isPreviewerUnavailable() then return end

	Assert.TypePoint(p, "Argument #1")
	Assert.Equals('string', type(desc), "Argument #2")
	Assert.Equals({'nil', 'boolean'}, type(flag), "Argument #3")
	Assert.Equals({'nil', 'number'}, type(duration), "Argument #4")

	flag = flag ~= false

	table.insert(previewMarks[previewState], {
		fn = 'MarkSpaceDesc',
		data = {p, desc, flag},
		duration = duration
	})
end

local function addColor(self, p, gl_color, duration)
	if isPreviewerUnavailable() then return end

	Assert.TypePoint(p, "Argument #1")
	Assert.TypeGLColor(gl_color, "Argument #2")
	Assert.Equals({'nil', 'number'}, type(duration), "Argument #3")

	table.insert(previewMarks[previewState], {
		fn = 'MarkSpaceColor',
		data = {p, gl_color},
		duration = duration
	})
end

local function addSimpleColor(self, p, gl_color, duration)
	if isPreviewerUnavailable() then return end

	Assert.TypePoint(p, "Argument #1")
	Assert.TypeGLColor(gl_color, "Argument #2")
	Assert.Equals({'nil', 'number'}, type(duration), "Argument #3")

	table.insert(previewMarks[previewState], {
		fn = 'MarkSpaceSimpleColor',
		data = {p, gl_color},
		duration = duration
	})
end

local function addFlashing(self, p, flag, duration)
	if isPreviewerUnavailable() then return end

	Assert.TypePoint(p, "Argument #1")
	Assert.Equals({'nil', 'boolean'}, type(flag), "Argument #2")
	Assert.Equals({'nil', 'number'}, type(duration), "Argument #3")

	flag = flag ~= false

	table.insert(previewMarks[previewState], {
		fn = 'MarkFlashing',
		data = {p, flag},
		duration = duration
	})
end

local function addAnimation(self, p, anim, delay)
	if isPreviewerUnavailable() then return end

	Assert.TypePoint(p, "Argument #1")
	Assert.Equals('string', type(anim), "Argument #2")
	Assert.NotEquals('nil', type(ANIMS[anim]), "Argument #2")

	createAnim(anim)

	local base = ANIMS[anim]
	local prefix = string.format(PREFIX, 1)
	local duration = sum(ANIMS[prefix..anim].__Lengths)

	if delay == ANIM_DELAY then
		delay = duration
	else
		delay = nil
	end

	table.insert(previewMarks[previewState], {
		fn = 'AddAnimation',
		anim = anim,
		data = {p, anim, ANIM_NO_DELAY},
		duration = duration,
		delay = delay,
		loop = base.Loop
	})
end

local function addEmitter(self, p, emitter, duration)
	if isPreviewerUnavailable() then return end

	Assert.TypePoint(p, "Argument #1")
	Assert.Equals('string', type(emitter), "Argument #2")
	Assert.NotEquals('nil', type(_G[emitter]), "Argument #2")
	Assert.Equals({'nil', 'number'}, type(duration), "Argument #3")

	local base = _G[emitter]
	local prefix = string.format(PREFIX, 1)

	if not _G[prefix..emitter] then
		_G[prefix..emitter] = base:new{
			birth_rate = base.birth_rate / 4,
			burst_count = base.burst_count / 4
		}
	end

	table.insert(previewMarks[previewState], {
		fn = 'DamageSpace',
		emitter = emitter,
		data = {spaceEmitter(p, prefix..emitter)},
		duration = duration
	})
end

local function addDelay(self, duration)
	if isPreviewerUnavailable() then return end

	Assert.Equals('number', type(duration), "Argument #1")

	table.insert(previewMarks[previewState], {
		delay = duration
	})
end

local function setLooping(self, flag)
	if isPreviewerUnavailable() then return end

	if flag == nil then
		flag = true
	end

	previewMarks[previewState].loop = flag
end

local function clearTargetAreaMarks()
	previewMarks[STATE_TARGET_AREA] = {}
end

local function clearSkillEffectMarks()
	previewMarks[STATE_SKILL_EFFECT] = {}
end

local function clearMarks()
	clearTargetAreaMarks()
	clearSkillEffectMarks()
end

local function resetTimer()
	globalCounter = 0
end

local function getTargetArea(self, p1, ...)
	if previewState ~= STATE_NONE or Board:IsTipImage() then
		return oldGetTargetAreas[self.__Id](self, p1, ...)
	end

	local skillId = self.__Id
	local armedWeapon = Pawn and Pawn:GetArmedWeapon() or nil

	if armedWeapon == skillId then
		clearTargetAreaMarks()
		previewState = STATE_TARGET_AREA
	end

	local result = oldGetTargetAreas[skillId](self, p1, ...)

	if armedWeapon == skillId then
		previewTargetArea = result
		previewState = STATE_NONE
	end

	return result
end

local function getSkillEffect(self, p1, p2, ...)
	if previewState ~= STATE_NONE or Board:IsTipImage() then
		return oldGetSkillEffects[self.__Id](self, p1, p2, ...)
	end

	local skillId = self.__Id
	local armedWeapon = Pawn and Pawn:GetArmedWeapon() or nil

	if armedWeapon == skillId then
		clearSkillEffectMarks()
		previewState = STATE_SKILL_EFFECT
	end

	local result = oldGetSkillEffects[skillId](self, p1, p2, ...)

	if armedWeapon == skillId then
		previewState = STATE_NONE
	end

	return result
end

local function overrideAllSkillMethods()
	local skills = {}
	for skillId, skill in pairs(_G) do
		if type(skill) == 'table' then
			skills[skillId] = skill
		end
	end

	for skillId, skill in pairs(skills) do
		if type(skill.GetTargetArea) == 'function' then
			oldGetTargetAreas[skillId] = skill.GetTargetArea
			skill.__Id = skillId
		end
		if type(skill.GetSkillEffect) == 'function' then
			oldGetSkillEffects[skillId] = skill.GetSkillEffect
			skill.__Id = skillId
		end
	end

	for skillId, _ in pairs(oldGetTargetAreas) do
		_G[skillId].GetTargetArea = getTargetArea
	end

	for skillId, _ in pairs(oldGetSkillEffects) do
		_G[skillId].GetSkillEffect = getSkillEffect
	end
end

local function pointListContains(pointList, obj)
	for i = 1, pointList:size() do
		if obj == pointList:index(i) then
			return true
		end
	end

	return false
end

local function getPreviewLength(previewState)
	local marks = previewMarks[previewState]
	local delay = 0
	local length = 0

	for _, mark in ipairs(marks) do
		if mark.duration then
			length = math.max(length, delay + mark.duration)
		end

		if mark.delay then
			delay = delay + mark.delay
			length = math.max(length, delay)
		end
	end

	return length * 60
end

local function getAnimFrame(mark, timeStart, timeCurr)
	local prefix = string.format(PREFIX, 1)
	local base = ANIMS[prefix..mark.anim]
	local lengths = base.__Lengths
	local duration = mark.duration * 60

	if mark.loop then
		timeCurr = timeStart + (timeCurr - timeStart) % duration
	end

	local time = timeStart
	for i = 1, base.__NumFrames do
		time = time + lengths[i] * 60
		if time > timeCurr or i == base.__NumFrames then
			local prefix = string.format(PREFIX, i)
			return prefix..mark.anim
		end
	end
end

local function markSpaces(previewState)
	local marks = previewMarks[previewState]
	local previewCounter = 0
	local time = globalCounter
	local looping = marks.loop

	if looping ~= false then
		local length = getPreviewLength(previewState)
		if length > 0 then
			time = time % length
		else
			time = 0
		end
	end

	for _, mark in ipairs(marks) do
		if mark.fn then
			local duration = INT_MAX

			if mark.duration then
				duration = mark.duration * 60
			end

			if mark.fn == "AddAnimation" then
				mark.data[2] = getAnimFrame(mark, previewCounter, time)
			end

			if mark.loop or previewCounter <= time and time <= previewCounter + duration then
				Board[mark.fn](Board, unpack(mark.data))
			end
		end

		previewCounter = previewCounter + (mark.delay or 0) * 60
	end
end

local function onMissionUpdate()
	local selected = Board:GetSelectedPawn()

	if not selected then
		prevArmedWeaponId = -1
		return
	end

	local armedWeaponId = selected:GetArmedWeaponId()

	if armedWeaponId == prevArmedWeaponId then
		globalCounter = globalCounter + 1
	else
		globalCounter = 0
	end

	prevArmedWeaponId = armedWeaponId

	if armedWeaponId == -1 then
		return
	end

	markSpaces(STATE_TARGET_AREA)

	local highlighted = Board:GetHighlighted()
	if not pointListContains(previewTargetArea, highlighted) then
		return
	end

	markSpaces(STATE_SKILL_EFFECT)
end

local function onModsInitialized()
	if VERSION < WeaponPreview.version then
		return
	end

	if WeaponPreview.initialized then
		return
	end

	WeaponPreview:finalizeInit()
	WeaponPreview.initialized = true
end

modApi.events.onModsInitialized:subscribe(onModsInitialized)

if WeaponPreview == nil or not modApi:isVersion(VERSION, WeaponPreview.version) then
	WeaponPreview = WeaponPreview or {}
	WeaponPreview.version = VERSION

	function WeaponPreview:finalizeInit()
		overrideAllSkillMethods()

		WeaponPreview.AddDamage = addDamage
		WeaponPreview.AddImage = addImage
		WeaponPreview.AddDesc = addDesc
		WeaponPreview.AddColor = addColor
		WeaponPreview.AddSimpleColor = addSimpleColor
		WeaponPreview.AddFlashing = addFlashing
		WeaponPreview.AddAnimation = addAnimation
		WeaponPreview.AddEmitter = addEmitter
		WeaponPreview.AddDelay = addDelay
		WeaponPreview.SetLooping = setLooping
		WeaponPreview.ClearMarks = clearMarks
		WeaponPreview.ResetTimer = resetTimer

		modApi.events.onMissionUpdate:subscribe(onMissionUpdate)
	end
end

return WeaponPreview
