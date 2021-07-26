
---------------------------------------------------------------------
-- Custom Animation v1.0 - code library
--[[-----------------------------------------------------------------
	preliminary library for adding animations that can be stopped at will.
	
	currently works for
	- animations without custom Length and Frames.
	- each tile or pawn having one animation of each id.

]]-------------------------------------------------------------------

local a = ANIMS
local suffix = "_lmn_"
local this = {}

-- add an animation to a location or a pawnId
-- until it is removed by Rem.
function this:Add(mission, loc, anim, desc)
	local m = mission or GetCurrentMission()
	if not m then return end
	
	assert(type(anim) == 'string')
	assert(a[anim])
	assert(not continue or type(continue) == 'function')
	
	local base = a[anim]
	if base.Time <= 0 then return end	-- don't play animations non-positive duration.
	if base.Lengths then return end		-- no support for this yet.
	if base.Frames then return end		-- no support for this yet.
	
	if type(loc) == 'number' then
		local pawnId = loc
		-- attach animation to pawnId
		m.lmn_pawnAnims = m.lmn_pawnAnims or {}
		m.lmn_pawnAnims[pawnId] = m.lmn_pawnAnims[pawnId] or {}
		m.lmn_pawnAnims[pawnId][anim] = m.lmn_pawnAnims[pawnId][anim] or {
			t = os.clock(),
			numFrames = base.NumFrames,
			duration = base.Time * base.NumFrames,
			title = desc and desc[1] or nil,
			desc = desc and desc[2] or nil
		}
	else
		-- add animation to location
		assert(type(loc) == 'userdata')
		assert(type(loc.x) == 'number')
		assert(type(loc.y) == 'number')
		
		local pid = p2idx(loc)
		m.lmn_tileAnims = m.lmn_tileAnims or {}
		m.lmn_tileAnims[pid] = m.lmn_tileAnims[pid] or {}
		m.lmn_tileAnims[pid][anim] = m.lmn_tileAnims[pid][anim] or {
			t = os.clock(),
			numFrames = base.NumFrames,
			duration = base.Time * base.NumFrames,
			title = desc and desc[1] or nil,
			desc = desc and desc[2] or nil
		}
	end
end

-- remove an animation from a location or a pawnId
function this:Rem(mission, loc, anim)
	mission = mission or GetCurrentMission()
	if not mission then return end
	
	assert(type(anim) == 'string')
	assert(a[anim])
	
	if type(loc) == 'number' then
		-- rem animation from pawnId
		mission.lmn_pawnAnims = mission.lmn_pawnAnims or {}
		mission.lmn_pawnAnims[pawnId] = mission.lmn_pawnAnims[pawnId] or {}
		mission.lmn_pawnAnims[pawnId][anim] = nil
	else
		-- rem animation from location
		assert(type(loc) == 'userdata')
		assert(type(loc.x) == 'number')
		assert(type(loc.y) == 'number')
		
		local pid = p2idx(loc)
		mission.lmn_tileAnims = mission.lmn_tileAnims or {}
		mission.lmn_tileAnims[pid] = mission.lmn_tileAnims[pid] or {}
		mission.lmn_tileAnims[pid][anim] = nil
	end
end

-- returns true if loc of pawn has custom animation playing.
function this:Is(mission, loc, anim)
	mission = mission or GetCurrentMission()
	if not mission then return end
	
	assert(type(anim) == 'string')
	assert(a[anim])
	
	if type(loc) == 'number' then
		-- rem animation from pawnId
		mission.lmn_pawnAnims = mission.lmn_pawnAnims or {}
		mission.lmn_pawnAnims[pawnId] = mission.lmn_pawnAnims[pawnId] or {}
		
		return mission.lmn_pawnAnims[pawnId][anim]
	else
		-- rem animation from location
		assert(type(loc) == 'userdata')
		assert(type(loc.x) == 'number')
		assert(type(loc.y) == 'number')
		
		local pid = p2idx(loc)
		mission.lmn_tileAnims = mission.lmn_tileAnims or {}
		mission.lmn_tileAnims[pid] = mission.lmn_tileAnims[pid] or {}
		
		return mission.lmn_tileAnims[pid][anim]
	end
end

local function createAnim(anim)
	local base = a[anim]
	-- create animations if they don't exist.
	if not a[anim .. suffix .."1"] then
		-- TODO: make work with Frames and Lengths.
		
		-- chop up animation to single frame units.
		for i = 1, base.NumFrames do
			a[anim .. suffix .. i] = base:new{
				Frames = {i-1},
				Loop = false,
				Time = 0.032 -- 2 frames
			}
		end
	end
end

local function updateAnims(loc, anims, t)
	t = t or os.clock()
	
	if Board:IsValid(loc) then
		local copy = shallow_copy(anims)
		
		for anim, v in pairs(copy) do
			if t > v.t then
				createAnim(anim)
				
				local frame = 1 + math.floor(((v.t + t) % v.duration) * v.numFrames / v.duration)
				Board:AddAnimation(loc, anim .. suffix .. frame, ANIM_NO_DELAY)
			end
		end
	end
end

local function updateDesc(loc, anims)
	if Board:IsValid(loc) then
		for anim, v in pairs(anims) do
			if v.title and v.desc then
				
				local tooltipId = "customAnim".. suffix .. anim
				if not TILE_TOOLTIPS[tooltipId] then
					TILE_TOOLTIPS[tooltipId] = {v.title, v.desc}
				end
				
				Board:MarkSpaceDesc(loc, tooltipId)
			end
		end
	end
end

sdlext.addFrameDrawnHook(function()
	local mission = GetCurrentMission()
	if not mission or not Board then return end
	
	mission.lmn_pawnAnims = mission.lmn_pawnAnims or {}
	mission.lmn_tileAnims = mission.lmn_tileAnims or {}
	
	local t = os.clock()
	local rem = {}
	
	for pawnId, anims in pairs(mission.lmn_pawnAnims) do -- TODO: play for locations as well.
		
		local pawn = Board:GetPawn(pawnId)
		if pawn then
			updateAnims(pawn:GetSpace(), anims, t)
		else
			rem[#rem+1] = pawnId
		end
	end
	
	for pid, anims in pairs(mission.lmn_tileAnims) do
		updateAnims(idx2p(pid), anims, t)
	end
	
	for _, id in ipairs(rem) do
		table.remove(mission.lmn_pawnAnims, id)
	end
end)

function this:load()
	
	modApi:addMissionUpdateHook(function(mission)
		mission.lmn_pawnAnims = mission.lmn_pawnAnims or {}
		mission.lmn_tileAnims = mission.lmn_tileAnims or {}
		
		for pawnId, anims in pairs(mission.lmn_pawnAnims) do
			local pawn = Board:GetPawn(pawnId)
			if pawn then
				updateDesc(pawn:GetSpace(), anims)
			end
		end
		
		for pid, anims in pairs(mission.lmn_tileAnims) do
			updateDesc(idx2p(pid), anims)
		end
	end)
	
	modApi:addPostLoadGameHook(function()
		modApi:runLater(function(mission)
			local t = os.clock()
			
			mission.lmn_pawnAnims = mission.lmn_pawnAnims or {}
			mission.lmn_tileAnims = mission.lmn_tileAnims or {}
			
			for _, anims in pairs(mission.lmn_pawnAnims) do
				for _, v in pairs(anims) do
					v.t = t
				end
			end
			
			for _, anims in pairs(mission.lmn_tileAnims) do
				for _, v in pairs(anims) do
					v.t = t
				end
			end
		end)
	end)
end

return this