
---------------------------------------------------------------------
-- Trait v1.0 - code library
---------------------------------------------------------------------
-- add a trait description and icon to the tooltip of a unit type.
-- this system should only be used to give traits to pawn types
-- created by the mod it is used in, and can not be used to give
-- unit types traits in any dynamic way.
-- max one per unit type.

local path = mod_loader.mods[modApi.currentMod].resourcePath
local this = {
	traits = {},
	descs = {},
	tips = {},
	icons = {}
}

local function file_exists(name)
	local f = io.open(name, "r")
	if f then io.close(f) return true else return false end
end

-- return the description of the trait.
local oldGetStatusTooltip = GetStatusTooltip
function GetStatusTooltip(id)
	for name, desc in pairs(this.descs) do
		if id == name then
			return desc
		end
	end
	
	return oldGetStatusTooltip(id)
end

-- only call on init.
-- name should be somewhat unique, to avoid collisions with other mods.
-- TODO: manipulate name to be unique after the fact?
function this:Add(name, pawnTypes, icon, iconGlow, desc, tip, isTrait)
	assert(type(name) == 'string')
	
	if type(pawnTypes) == 'string' then
		pawnTypes = {pawnTypes}
	end
	
	assert(type(pawnTypes) == 'table')
	
	for _, pawnType in ipairs(pawnTypes) do
		assert(type(pawnType) == 'string')
		isTrait = isTrait or function() return true end
		assert(type(isTrait) == 'function')
		
		self.traits[pawnType] = function(pawn) return isTrait(pawn) and name or nil end
	end
	
	assert(type(desc) == 'table')
	desc.title = desc.title or desc[1]
	desc.text = desc.text or desc[2]
	
	assert(type(desc.title) == 'string')
	assert(type(desc.text) == 'string')
	
	this.descs[name] = desc
	
	if tip then
		assert(type(tip) == 'table')
		tip.title = tip.title or tip[1]
		tip.text = tip.text or tip[2]
		
		assert(type(tip.title) == 'string')
		assert(type(tip.text) == 'string')
		
		Global_Texts[name .."_Text"] = tip.text
		Global_Texts[name .."_Title"] = tip.title
		
		this.tips[name] = true
	end
	
	if type(icon) == 'string' then
		icon = {path = icon, loc = Point(0,0)}
	end
	
	if type(iconGlow) == 'string' then
		iconGlow = {path = iconGlow, loc = Point(0,0)}
	end
	
	if type(icon) == 'table' then
		icon.path = icon.path or icon[1]
		icon.loc = icon.loc or icon[2]
		
		if file_exists(path .. icon.path) then
			modApi:appendAsset("img/combat/icons/icon_".. name ..".png", path .. icon.path)
			Location["combat/icons/icon_".. name ..".png"] = icon.loc
		end
	end
	
	if type(iconGlow) == 'table' then
		iconGlow.path = iconGlow.path or iconGlow[1]
		iconGlow.loc = iconGlow.loc or iconGlow[2]
		
		if file_exists(path .. iconGlow.path) then
			modApi:appendAsset("img/combat/icons/icon_".. name .."_glow.png", path .. iconGlow.path)
			Location["combat/icons/icon_".. name .."_glow.png"] = iconGlow.loc
		end
	end
end

-- reset the tip of a trait.
function this:ResetTip(name)
	if not name then
		for name, _ in pairs(self.tips) do
			modApi:writeProfileData(name, false)
		end
	end
	
	if self.tips[name] then
		modApi:writeProfileData(name, false)
	end
end

function this:load()

	modApi:addPostLoadGameHook(function()
		self.icons = {}
	end)
	
	modApi:addMissionUpdateHook(function(mission)
		-- all icons currently tracked
		local trackedIcons = shallow_copy(self.icons)
		
		for _, pawnId in ipairs(extract_table(Board:GetPawns(TEAM_ANY))) do
			trackedIcons[pawnId] = nil
			
			local pawn = Board:GetPawn(pawnId)
			local trait = self.traits[pawn:GetType()]
			
			if trait then
				trait = trait(pawn)
				local loc = pawn:GetSpace()
				local oldLoc = self.icons[pawnId]
				
				-- clear location if trait is off.
				if not trait and oldLoc then
					self.icons[pawnId] = nil
					Board:SetTerrainIcon(oldLoc, "")
				end
				
				if trait then
					if loc ~= oldLoc then
						self.icons[pawnId] = loc
						
						-- clear old loc of it's icon.
						if oldLoc then
							Board:SetTerrainIcon(oldLoc, "")
						end
						
						-- add icon to new loc.
						Board:SetTerrainIcon(loc, trait)
						
						if self.tips[trait] and not modApi:readProfileData(trait) then
							Game:AddTip(trait, loc)
							modApi:writeProfileData(trait, true)
						end
					end
				end
			end
		end
		
		for pawnId, loc in pairs(trackedIcons) do
			self.icons[pawnId] = nil
			
			Board:SetTerrainIcon(loc, "")
		end
	end)
end

return this