
-------------------------------------------------------------
-- Weapon Marks v1.1 - code library
-------------------------------------------------------------
-- allows player controlled pawns to automatically call
-- Board:MarkSpace.. functions every update while the
-- weapon is armed and hovering valid tiles.
--
-- requires the use of CustomTipImage in order to filter out
-- calls to GetSkillEffect due to looking at the tipimage.
--
-- look below for a method to detect if in tipimage.
-------------------------------------------------------------

-------------------------------
-- initialization and loading:
--[[---------------------------

	-- in init.lua
	local weaponMarks

	-- in init.lua - function init:
	weaponMarks = require(self.scriptPath .."weaponMarks")
	weaponMarks:init(self)

	-- in init.lua - function load:
	weaponMarks:load(modApiExt)
	
	
	-- after you have initialized and loaded it,
	-- you can request it again in your weapons with:
	local weaponMarks = require(self.scriptPath .."weaponMarks")
	
	
]]----------------
-- function list:
------------------

----------------------------------------------------
-- weaponMarks:new(pawnId, skill)
----------------------------------------------------
-- returns a marker object.
-- intended to be used in conjunction with a skill.
----------------------------------------------------
----------------------------------------------------


--------------------------------------------------------
-- the following functions require a marker object.
-- intended to be used in GetSkillEffect to mark tiles.
--------------------------------------------------------


------------------------------------------------------
-- marker:MarkSpaceDamage(damage, optional)
------------------------------------------------------
-- while weapon is armed and targeting,
-- marks a tile with damage.
--
-- ignores cursor position if 'optional' is true.
------------------------------------------------------

------------------------------------------------------
-- marker:MarkSpaceColor(tile, gl_color, optional)
------------------------------------------------------
-- while weapon is armed and targeting,
-- marks a tile with a color.
--
-- ignores cursor position if 'optional' is true.
------------------------------------------------------

---------------------------------------------------------
-- marker:MarkSpaceSimpleColor(tile, gl_color, optional)
---------------------------------------------------------
-- while weapon is armed and targeting,
-- marks a tile with a color.
--
-- ignores cursor position if 'optional' is true.
---------------------------------------------------------

---------------------------------------------------------
-- marker:MarkSpaceImage(tile, path, gl_color, optional)
---------------------------------------------------------
-- while weapon is armed and targeting,
-- marks a tile with an image.
--
-- ignores cursor position if 'optional' is true.
---------------------------------------------------------

--------------------------------------------------------
-- marker:MarkSpaceDesc(tile, desc, gl_color, optional)
--------------------------------------------------------
-- while weapon is armed and targeting,
-- marks a tile with a description.
--
-- ignores cursor position if 'optional' is true.
--------------------------------------------------------
--------------------------------------------------------


-- weapon pattern to determine if a GetSkillEffect call is from tipimage:
-----------------------------------------------------------------------------
--[[-------------------------------------------------------------------------

	MyWeaponSkill = Skill:new{
		CustomTipImage = "MyWeaponSkill_Tip",
	}
	
	function MyWeaponSkill:GetSkillEffect(p1, p2, parentSkill, isTipImage)
	end
	
	MyWeaponSkill_Tip = MyWeaponSkill:new{}
	
	function MyWeaponSkill_Tip:GetSkillEffect(p1, p2, parentSkill)
		return MyWeaponSkill.GetSkillEffect(self, p1, p2, parentSkill, true)
	end
	
]]---------------------------------------------------------------------------
-----------------------------------------------------------------------------

local mod = mod_loader.mods[modApi.currentMod]
local resourcePath = mod.resourcePath
local scriptPath = mod.scriptPath

local modApiExt = LApi.library:fetch("modApiExt/modApiExt", nil, "ITB-ModUtils")

local this = {markers = {}}
local marker = {}

-- returns true if the base weapons are the same.
local function IsWeapon(weapon, weaponToMatch)
	local suffix = string.match(weapon, '_[AB]+', -3) or ""	-- extract upgrade suffix.
	local base = string.match(weapon, '(.+)'.. suffix)		-- extract every character before suffix.
	
	return string.find(weaponToMatch, base)
end

-- returns true if pawn has weapon armed.
local function IsWeaponArmed(pawnId, skill)
	local pawn = Board:GetPawn(pawnId)
	local armedWeaponId = pawn:GetArmedWeaponId()
	
	local weapons = modApiExt.pawn:getWeapons(pawnId)
	if type(weapons[armedWeaponId]) == 'string' then
		if IsWeapon(skill, weapons[armedWeaponId]) then
			return true
		end
	end
	
	return false
end

-- returns true if any tile on the board is highlighted.
local function IsBoardHighlighted()
	return modApiExt_internal and modApiExt_internal.currentTile or true
end

-- gets a marker that can be used to add marks
-- associated with a pawn using a weapon.
function this:new(pawnId, skill)
	assert(type(pawnId) == 'number')
	assert(type(skill) == 'string')
	assert(type(_G[skill]) == 'table')
	assert(type(_G[skill].GetTargetArea) == 'function')
	
	self.markers[pawnId] = shallow_copy(marker)
	
	local marker = self.markers[pawnId]
	marker.skill = skill
	marker.flashing = {}
	marker.color = {}
	marker.damage = {}
	marker.desc = {}
	marker.image = {}
	marker.simpleColor = {}
	
	return marker
end

-- 'sticky' is an optional flag for the following functions.
-- if true, the marks will be drawn
-- even when no tiles in GetTargetArea are highlighted.

-- adds a MarkSpaceDamage to this marker.
-- 'damage' is a spaceDamage object or a
-- table of values to add to one.
function marker:MarkSpaceDamage(damage, sticky)
	assert(type(damage) == 'userdata' or type(damage) == 'table')
	assert(type(damage.loc) == 'userdata')
	assert(type(damage.loc.x) == 'number')
	assert(type(damage.loc.y) == 'number')
	assert(type(sticky) == 'boolean' or sticky == nil)
	
	damage.sticky = sticky
	table.insert(self.damage, shallow_copy(damage))
end

-- adds a MarkSpaceImage to this marker.
-- 'color' is a GL_Color object.
function marker:MarkSpaceImage(tile, path, gl_color, sticky)
	assert(type(tile) == 'userdata')
	assert(type(tile.x) == 'number')
	assert(type(tile.y) == 'number')
	assert(type(path) == 'string')
	assert(type(gl_color) == 'userdata')
	assert(type(gl_color.r) == 'number')
	assert(type(gl_color.g) == 'number')
	assert(type(gl_color.b) == 'number')
	assert(type(gl_color.a) == 'number')
	assert(type(sticky) == 'boolean' or sticky == nil)
	
	table.insert(self.image, {point = tile, path = path, color = gl_color, sticky = sticky})
end

-- adds a MarkSpaceDesc to this marker.
function marker:MarkSpaceDesc(tile, desc, bool, sticky)
	assert(type(tile) == 'userdata')
	assert(type(tile.x) == 'number')
	assert(type(tile.y) == 'number')
	assert(type(desc) == 'string')
	assert(type(bool) == 'boolean' or bool == nil)
	assert(type(sticky) == 'boolean' or sticky == nil)
	
	table.insert(self.desc, {point = tile, desc = desc, bool = bool, sticky = sticky})
end

-- adds a MarkSpaceColor to this marker.
-- 'gl_color' is a GL_Color object.
function marker:MarkSpaceColor(tile, gl_color, sticky)
	assert(type(tile) == 'userdata')
	assert(type(tile.x) == 'number')
	assert(type(tile.y) == 'number')
	assert(type(gl_color) == 'userdata')
	assert(type(gl_color.r) == 'number')
	assert(type(gl_color.g) == 'number')
	assert(type(gl_color.b) == 'number')
	assert(type(gl_color.a) == 'number')
	assert(type(sticky) == 'boolean' or sticky == nil)
	
	assert(sticky == nil or type(sticky) == 'boolean')
	assertPoint(tile)
	assertColor(gl_color)
	
	table.insert(self.color, {point = tile, color = gl_color, sticky = sticky})
end

-- adds a MarkSpaceSimpleColor to this marker.
-- 'gl_color' is a GL_Color object.
function marker:MarkSpaceSimpleColor(tile, gl_color, sticky)
	assert(type(tile) == 'userdata')
	assert(type(tile.x) == 'number')
	assert(type(tile.y) == 'number')
	assert(type(gl_color) == 'userdata')
	assert(type(gl_color.r) == 'number')
	assert(type(gl_color.g) == 'number')
	assert(type(gl_color.b) == 'number')
	assert(type(gl_color.a) == 'number')
	assert(type(sticky) == 'boolean' or sticky == nil)
	
	table.insert(self.simpleColor, {point = tile, color = gl_color, sticky = sticky})
end

-- adds MarkFlashing to this marker. (causes pulsing building outlines)
function marker:MarkFlashing(tile, bool, sticky)
	assert(type(tile) == 'userdata')
	assert(type(tile.x) == 'number')
	assert(type(tile.y) == 'number')
	assert(type(bool) == 'boolean' or bool == nil)
	assert(type(sticky) == 'boolean' or sticky == nil)
	
	bool = bool or true
	table.insert(self.flashing, {point = tile, bool = bool, sticky = sticky})
end

sdlext.addGameExitedHook(function()
	this.markers = {}
	this.highlighted = nil
end)

function this:init() end
function this:load()
	self.highlighted = nil
	
	modApi:addMissionUpdateHook(function()
		local rem = {}
		
		for pawnId, marker in pairs(self.markers) do
			local pawn = Board:GetPawn(pawnId)
			if not pawn or not IsWeaponArmed(pawnId, marker.skill) then
				table.insert(rem, pawnId)
			else
				local highlighted = true
				
				if not IsGamepad() then
					local targetArea = extract_table(_G[marker.skill]:GetTargetArea(pawn:GetSpace(), nil, true))
					
					if not list_contains(targetArea, self.highlighted) then
						highlighted = false
					end
				end
				
				if
					Game:GetTeamTurn() == TEAM_PLAYER	and
					Board:GetBusyState() == 0
				then
					for _, mark in pairs(marker.flashing) do
						if highlighted or mark.sticky then
							Board:MarkFlashing(mark.point, mark.bool)
						end
					end
					
					for _, mark in pairs(marker.simpleColor) do
						if highlighted or mark.sticky then
							Board:MarkSpaceSimpleColor(mark.point, mark.color)
						end
					end
					
					for _, mark in pairs(marker.color) do
						if highlighted or mark.sticky then
							Board:MarkSpaceColor(mark.point, mark.color)
						end
					end
					
					for _, mark in pairs(marker.desc) do
						if highlighted or mark.sticky then
							Board:MarkSpaceDesc(mark.point, mark.desc, mark.bool)
						end
					end
					
					for _, mark in pairs(marker.image) do
						if highlighted or mark.sticky then
							Board:MarkSpaceImage(mark.point, mark.path, mark.color)
						end
					end
					
					for _, mark in pairs(marker.damage) do
						if highlighted or mark.sticky then
							
							local d = SpaceDamage()
							for i, v in pairs(mark) do
								d[i] = v 
							end
							
							Board:MarkSpaceDamage(d)
						end
					end
				end
			end
		end
		
		for _, id in ipairs(rem) do
			self.markers[id] = nil
		end
	end)
	
	modApiExt:addTileHighlightedHook(function(_, tile)
		self.highlighted = tile
	end)
	
	modApiExt:addTileUnhighlightedHook(function()
		self.highlighted = nil
	end)
	
	modApi:addTestMechExitedHook(function()
		self.markers = {}
		self.highlighted = nil
	end)
	
	modApi:addMissionEndHook(function()
		self.markers = {}
		self.highlighted = nil
	end)
end

return this
