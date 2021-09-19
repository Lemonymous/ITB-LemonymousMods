
---------------------------------------------------------------------
-- Tutorial Tips v1.4 - code library
--
-- by Lemonymous
---------------------------------------------------------------------
-- small helper lib to manage tutorial tips that will only display once per profile.
-- can be reset, and would likely be done via a mod option.
--
-- Note: Each mod using this library must each have their unique instance of it.

local mod = mod_loader.mods[modApi.currentMod]
local tips = {}
local cachedTips

local function cacheCurrentProfileData()
	if not modApi:isProfilePath() then
		return
	end

	sdlext.config(
		modApi:getCurrentProfilePath().."modcontent.lua",
		function(obj)
			obj.tutorialTips = obj.tutorialTips or {}
			obj.tutorialTips[mod.id] = obj.tutorialTips[mod.id] or {}
			cachedTips = obj.tutorialTips[mod.id]
		end
	)
end

-- writes tutorial tips data.
local function writeData(id, obj)
	sdlext.config(
		modApi:getCurrentProfilePath().."modcontent.lua",
		function(readObj)
			readObj.tutorialTips[mod.id][id] = obj
			cachedTips = readObj.tutorialTips[mod.id]
		end
	)
end

-- reads tutorial tips data.
local function readData(id)
	local result = nil

	if cachedTips then
		result = cachedTips[id]
	else
		sdlext.config(
			modApi:getCurrentProfilePath().."modcontent.lua",
			function(readObj)
				cachedTips = readObj.tutorialTips[mod.id]
				result = cachedTips[id]
			end
		)
	end

	return result
end

function tips:resetAll()
	sdlext.config(
		modApi:getCurrentProfilePath().."modcontent.lua",
		function(obj)
			obj.tutorialTips = obj.tutorialTips or {}
			obj.tutorialTips[mod.id] = {}
			cachedTips = obj.tutorialTips[mod.id]
		end
	)
end

function tips:reset(id)
	Assert.Equals('string', type(id), "Argument #1")
	writeData(id, nil)
end

function tips:add(tip)
	Assert.Equals('table', type(tip), "Argument #1")
	Assert.Equals('string', type(tip.id))
	Assert.Equals('string', type(tip.title))
	Assert.Equals('string', type(tip.text))

	Global_Texts[mod.id .. tip.id .."_Title"] = tip.title
	Global_Texts[mod.id .. tip.id .."_Text"] = tip.text
end

function tips:trigger(id, loc)
	Assert.Equals('string', type(id), "Argument #1")
	Assert.TypePoint(loc, "Argument #2")

	if sdlext.isMapEditor() then
		return
	end

	if not readData(id) then
		Game:AddTip(mod.id .. id, loc)
		writeData(id, true)
	end
end

function tips:getCachedProfileData()
	return cachedTips
end

-- backwards compatibility
tips.ResetAll = tips.resetAll
tips.Reset = tips.reset
tips.Add = tips.add
tips.Trigger = tips.trigger

cacheCurrentProfileData()
modApi.events.onProfileChanged:subscribe(cacheCurrentProfileData)

return tips
