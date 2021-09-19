
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
--      :AddAnimation(point, animation, delay)
--      :AddColor(point, gl_color, duration)
--      :AddDamage(spaceDamage, duration)
--      :AddDelay(duration)
--      :AddDesc(point, desc, flag, duration)
--      :AddEmitter(point, emitter, duration)
--      :AddFlashing(point, flag, duration)
--      :AddImage(point, path, gl_color, duration)
--      :AddSimpleColor(point, gl_color, duration)
--      :ClearMarks()
--      :ResetTimer()
--      :SetLooping(flag)
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

local VERSION = "3.1.0"
local PREFIX = "_weapon_preview_%s_"
local PREFIX_ANIM = string.format(PREFIX, "1")
local PREFIX_EMITTER = string.format(PREFIX, "emitter")

local STATE_NONE = 0
local STATE_SKILL_EFFECT = 1
local STATE_TARGET_AREA = 2
local STATE_QUEUED_SKILL = 3

local NULL_PAWNID = -1
local NULL_WEAPON = ""
local NULL_WEAPID = -1

Preview = Class.new()
local selfMetatable = setmetatable({}, Preview)
selfMetatable.__index = Preview
selfMetatable.__call = function()
	error("attempted to call an instance\n", 2)
end
selfMetatable.__eq = function(a, b)
	return
		a.pawnId == b.pawnId and
		a.weapon == b.weapon and
		a.weapId == b.weapId
end

local Preview_mt = getmetatable(Preview)
function Preview_mt:__call(...)
	local newInstance = setmetatable({}, selfMetatable)
	newInstance:new(...)
	return newInstance
end

function Preview:new()
	self:clear()
end

function Preview:unpack()
	return self.pawnId, self.weapon, self.weapId
end

function Preview:clear()
	self.pawnId = NULL_PAWNID
	self.weapon = NULL_WEAPON
	self.weapId = NULL_WEAPID
	self.ticker = 0
end

function Preview:set(other)
	if other then
		self.pawnId = other.pawnId
		self.weapon = other.weapon
		self.weapId = other.weapId
	else
		self:clear()
	end
end

function Preview:setArmed(pawn)
	if pawn then
		self.pawnId = pawn:GetId()
		self.weapon = pawn:GetArmedWeapon()
		self.weapId = pawn:GetArmedWeaponId()
	else
		self:clear()
	end
end

function Preview:setQueued(pawn)
	if pawn then
		self.pawnId = pawn:GetId()
		self.weapon = pawn:GetQueuedWeapon()
		self.weapId = pawn:GetQueuedWeaponId()
	else
		self:clear()
	end
end

function Preview:isActive()
	return self.weapId > NULL_WEAPID
end

function Preview:isInActive()
	return not self:isActive()
end

local chosenPreview
local targetPreview
local effectPreview
local queuedPreview

local getTargetAreaCallers = {}
local getSkillEffectCallers = {}
local oldGetTargetAreas = {}
local oldGetSkillEffects = {}
local armedTargetAreaTimer = 0
local armedSkillEffectTimer = 0
local queuedSkillEffectTimer = 0
local previewTargetArea = PointList()
local previewState = STATE_NONE
local previewMarks = {}
local queuedPreviewMarks = {}
local events = {}

local function spaceEmitter(loc, emitter)
	local fx = SkillEffect()
	fx:AddEmitter(loc, emitter)
	return fx.effect:index(1)
end

local function createAnim(anim)
	local base = ANIMS[anim]

	-- chop up animation to single frame units.
	if not ANIMS[PREFIX_ANIM..anim] then
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

local function pointListContains(pointList, obj)
	for i = 1, pointList:size() do
		if obj == pointList:index(i) then
			return true
		end
	end

	return false
end

local function isPreviewerUnavailable()
	return previewState == STATE_NONE or Board:IsTipImage()
end

local function addAnimation(self, p, anim, delay)
	if isPreviewerUnavailable() then return end

	Assert.TypePoint(p, "Argument #1")
	Assert.Equals('string', type(anim), "Argument #2")
	Assert.NotEquals('nil', type(ANIMS[anim]), "Argument #2")

	createAnim(anim)

	local base = ANIMS[anim]
	local duration = sum(ANIMS[PREFIX_ANIM..anim].__Lengths)

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

local function addDelay(self, duration)
	if isPreviewerUnavailable() then return end

	Assert.Equals('number', type(duration), "Argument #1")

	table.insert(previewMarks[previewState], {
		delay = duration
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

local function addEmitter(self, p, emitter, duration)
	if isPreviewerUnavailable() then return end

	Assert.TypePoint(p, "Argument #1")
	Assert.Equals('string', type(emitter), "Argument #2")
	Assert.NotEquals('nil', type(_G[emitter]), "Argument #2")
	Assert.Equals({'nil', 'number'}, type(duration), "Argument #3")

	local base = _G[emitter]

	if not _G[PREFIX_EMITTER..emitter] then
		_G[PREFIX_EMITTER..emitter] = base:new{
			birth_rate = base.birth_rate / 4,
			burst_count = base.burst_count / 4
		}
	end

	table.insert(previewMarks[previewState], {
		fn = 'DamageSpace',
		loc = p,
		emitter = emitter,
		data = {},
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

local function clearMarks(state)
	if state then
		previewMarks[state] = {}
	else
		clearMarks(STATE_TARGET_AREA)
		clearMarks(STATE_SKILL_EFFECT)
		clearMarks(STATE_QUEUED_SKILL)
	end
end

local function setLooping(self, flag)
	if isPreviewerUnavailable() then return end

	if flag == nil then
		flag = true
	end

	previewMarks[previewState].loop = flag
end

local function resetTargetTimer()
	targetPreview.ticker = 0
end

local function resetEffectTimer()
	effectPreview.ticker = 0
end

local function resetQueuedTimer()
	queuedPreview.ticker = 0
end

local function isTargetMarker()
	return targetPreview:isActive()
end

local function isEffectMarker()
	return effectPreview:isActive()
end

local function isQueuedMarker()
	return queuedPreview:isActive()
end

local function getTargetMarker()
	return targetPreview:unpack()
end

local function getEffectMarker()
	return effectPreview:unpack()
end

local function getQueuedMarker()
	return queuedPreview:unpack()
end

local function getTargetArea(self, p1, ...)
	local skillId = getTargetAreaCallers[#getTargetAreaCallers]
	local pawn = Board:GetPawn(p1)
	local result = nil

	if previewState == STATE_NONE and not Board:IsTipImage() then

		chosenPreview:setArmed(pawn)

		if skillId == chosenPreview.weapon and chosenPreview ~= targetPreview then
			if targetPreview:isActive() then
				events.onTargetAreaHidden:dispatch(targetPreview:unpack())
				targetPreview:clear()
			end

			previewState = STATE_TARGET_AREA
			previewMarks[previewState] = {}

			targetPreview:set(chosenPreview)
			events.onTargetAreaShown:dispatch(targetPreview:unpack())

			result = oldGetTargetAreas[skillId](self, p1, ...)
			previewTargetArea = result
			previewState = STATE_NONE
		end
	end

	return result or oldGetTargetAreas[skillId](self, p1, ...)
end

local function getSkillEffect(self, p1, p2, ...)
	local skillId = getSkillEffectCallers[#getSkillEffectCallers]
	local pawn = Board:GetPawn(p1)
	local result = nil

	if previewState == STATE_NONE and not Board:IsTipImage() then

		chosenPreview:setArmed(pawn)

		if skillId == chosenPreview.weapon then
			if effectPreview ~= chosenPreview and effectPreview:isActive() then
				events.onSkillEffectHidden:dispatch(effectPreview:unpack())
				effectPreview:clear()
			end

			previewState = STATE_SKILL_EFFECT
			previewMarks[previewState] = {}

			if effectPreview:isInActive() then
				effectPreview:set(chosenPreview)
				events.onSkillEffectShown:dispatch(effectPreview:unpack())
			end

			result = oldGetSkillEffects[skillId](self, p1, p2, ...)
			previewState = STATE_NONE

		elseif skillId == pawn:GetQueuedWeapon() then
			previewState = STATE_QUEUED_SKILL
			previewMarks[previewState] = {}

			result = oldGetSkillEffects[skillId](self, p1, p2, ...)
			queuedPreviewMarks[pawn:GetId()] = previewMarks[previewState]
			previewState = STATE_NONE
		end
	end

	return result or oldGetSkillEffects[skillId](self, p1, p2, ...)
end

local function getPreviewLength(marks)
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

local function getAnimFrame(mark, frameStart, frameCurr)
	local base = ANIMS[PREFIX_ANIM..mark.anim]
	local lengths = base.__Lengths
	local duration = mark.duration * 60

	if mark.loop then
		frameCurr = frameStart + (frameCurr - frameStart) % duration
	end

	local frame = frameStart
	for i = 1, base.__NumFrames do
		frame = frame + lengths[i] * 60
		if frame > frameCurr or i == base.__NumFrames then
			local prefix = string.format(PREFIX, i)
			return prefix..mark.anim
		end
	end
end

local function markSpaces(marks, frameCurr)
	local frame = 0
	local looping = marks.loop

	if looping ~= false then
		local length = getPreviewLength(marks)
		if length > 0 then
			frameCurr = frameCurr % length
		else
			frameCurr = 0
		end
	end

	for _, mark in ipairs(marks) do
		if mark.fn then
			local duration = INT_MAX

			if mark.duration then
				duration = mark.duration * 60
			end

			if mark.fn == "AddAnimation" then
				mark.data[2] = getAnimFrame(mark, frame, frameCurr)

			elseif mark.fn == "DamageSpace" then
				mark.data[1] = spaceEmitter(mark.loc, PREFIX_EMITTER..mark.emitter)
			end

			if mark.loop or frame <= frameCurr and frameCurr <= frame + duration then
				Board[mark.fn](Board, unpack(mark.data))
			end
		end

		frame = frame + (mark.delay or 0) * 60
	end
end

local function onMissionUpdate()

	-- clear preview entries for removed units
	for pawnId, _ in pairs(queuedPreviewMarks) do
		if Board:GetPawn(pawnId) == nil then
			queuedPreviewMarks[pawnId] = nil
		end
	end

	local selected = Board:GetSelectedPawn()
	local highlighted = Board:GetHighlighted()
	local highlightedPawn = Board:GetPawn(highlighted)
	local boardIsBusy = Board:IsBusy()

	chosenPreview:setArmed(selected)

	if targetPreview:isActive() and chosenPreview:isInActive() then
		events.onTargetAreaHidden:dispatch(targetPreview:unpack())
		targetPreview:clear()
	end

	if effectPreview:isActive() and chosenPreview:isInActive() then
		events.onSkillEffectHidden:dispatch(effectPreview:unpack())
		effectPreview:clear()
	end

	if targetPreview:isActive() then
		markSpaces(previewMarks[STATE_TARGET_AREA], targetPreview.ticker)
		targetPreview.ticker = targetPreview.ticker + 1
	end

	if effectPreview:isActive() then
		if not boardIsBusy and pointListContains(previewTargetArea, highlighted) then
			markSpaces(previewMarks[STATE_SKILL_EFFECT], effectPreview.ticker)
			effectPreview.ticker = effectPreview.ticker + 1
		else
			events.onSkillEffectHidden:dispatch(effectPreview:unpack())
			effectPreview:clear()
		end
	end

	if chosenPreview.weapId <= 0 then
		chosenPreview:setQueued(highlightedPawn)
	else
		chosenPreview:clear()
	end

	if queuedPreview ~= chosenPreview then
		if queuedPreview:isActive() then
			events.onQueuedSkillEffectHidden:dispatch(queuedPreview:unpack())
			queuedPreview:clear()
		end

		queuedPreview:set(chosenPreview)

		if queuedPreview:isActive() then
			events.onQueuedSkillEffectShown:dispatch(queuedPreview:unpack())
		end
	end

	if queuedPreview:isActive() then
		local queuedMarks = queuedPreviewMarks[queuedPreview.pawnId]
		if queuedMarks then
			markSpaces(queuedMarks, queuedPreview.ticker)
			queuedPreview.ticker = queuedPreview.ticker + 1
		end
	end
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
		local skill = _G[skillId]

		function skill.GetTargetArea(...)
			getTargetAreaCallers[#getTargetAreaCallers + 1] = skillId

			local result = getTargetArea(...)

			getTargetAreaCallers[#getTargetAreaCallers] = nil

			return result
		end
	end

	for skillId, _ in pairs(oldGetSkillEffects) do
		local skill = _G[skillId]

		function skill.GetSkillEffect(...)
			getSkillEffectCallers[#getSkillEffectCallers + 1] = skillId

			local result = getSkillEffect(...)

			getSkillEffectCallers[#getSkillEffectCallers] = nil

			return result
		end
	end
end

local function initGlobals()
	clearMarks()

	chosenPreview = Preview()
	targetPreview = Preview()
	effectPreview = Preview()
	queuedPreview = Preview()

	events.onTargetAreaShown = Event()
	events.onTargetAreaHidden = Event()
	events.onSkillEffectShown = Event()
	events.onSkillEffectHidden = Event()
	events.onQueuedSkillEffectShown = Event()
	events.onQueuedSkillEffectHidden = Event()
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
		initGlobals()

		WeaponPreview.AddAnimation = addAnimation
		WeaponPreview.AddColor = addColor
		WeaponPreview.AddDamage = addDamage
		WeaponPreview.AddDelay = addDelay
		WeaponPreview.AddDesc = addDesc
		WeaponPreview.AddEmitter = addEmitter
		WeaponPreview.AddFlashing = addFlashing
		WeaponPreview.AddImage = addImage
		WeaponPreview.AddSimpleColor = addSimpleColor
		WeaponPreview.ClearMarks = clearMarks
		WeaponPreview.GetQueuedSkillEffectMarker = getQueuedMarker
		WeaponPreview.GetSkillEffectMarker = getEffectMarker
		WeaponPreview.GetTargetAreaMarker = getTargetMarker
		WeaponPreview.IsQueuedSkillEffectMarker = isQueuedMarker
		WeaponPreview.IsSkillEffectMarker = isEffectMarker
		WeaponPreview.IsTargetAreaMarker = isTargetMarker
		WeaponPreview.ResetQueuedSkillEffectTimer = resetQueuedTimer
		WeaponPreview.ResetSkillEffectTimer = resetEffectTimer
		WeaponPreview.ResetTargetAreaTimer = resetTargetTimer
		WeaponPreview.SetLooping = setLooping

		WeaponPreview.events = events

		modApi.events.onMissionUpdate:subscribe(onMissionUpdate)
	end
end

return WeaponPreview
