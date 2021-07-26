
--[[-------------------------------------------------------------------------
	API for
	 - adding achievements
	 - triggering achievements
	
	
	 request api:
	==============
	local path = mod_loader.mods[modApi.currentMod].scriptPath
	local achvApi = require(path .."achievement/api")
	
	
	-----------------
	   Method List
	-----------------
	each methods can only affect achievements of your mod.
	many of the methods might be of limited use, but are used internally.
	they are exposed in case they are needed.
	
	
	achvApi:GetVersion()
	====================
	returns the version of this library. (not the highest version initialized)
	
	
	achvApi:GetHighestVersion()
	===========================
	returns the highest version of this library.
	since mods are initialized sequentially,
	this function cannot be sure of the highest version until after init.
	
	
	achvApi:AddChievo(chievo)
	=========================
	adds an achievement for your mod.
	
	field   | type  | description
	--------+-------+-------------
	chievo  | table | (see below)
	--------+-------+-------------
	
	
	achvApi:AddChievos(chievos)
	===========================
	adds several achievements for your mod.
	
	field    | type  | description
	---------+-------+------------------
	chievos  | table | list of chievos.
	---------+-------+------------------
	
	
	achvApi:TriggerChievo(chievoId, objectives)
	===========================================
	modifies an achievement's progress.
	objectives = nil -> completed
	objectives = true -> completed
	objectives = false -> incomplete
	objective is a table -> sets progress according to progress table.
	
	field       | type    | description
	------------+---------+--------------------
	objectives  | boolean | true, false or nil
	objectives  | table   | progress table
	------------+---------+--------------------
	
	
	achvApi:TriggerAll(flag)
	========================
	sets all achievements to
	flag = true  -> completed
	flag = nil   -> completed
	flag = false -> incomplete

	field | type    | description
	------+---------+--------------------
	flag  | boolean | true, false or nil
	------+---------+--------------------
	
	
	achvApi:GetChievo(chievoId)
	===========================
	returns the chievo table from a chievoId
	
	field     | type    | description
	----------+---------+-------------------
	chievoId  | string  | id of achievement
	----------+---------+-------------------
	
	
	achvApi:GetChievoStatus(chievoId)
	=================================
	returns true if achievement has been completed, otherwise false.
	
	field      | type   | description
	-----------+--------+----------------
	chievoId   | string | achievement id
	-----------+--------+----------------
	
	
	achvApi:GetChievoTipFormatted(chievoId, reset)
	==============================================
	returns the tooltip text for the current
	progress of this achievement.
	if reset is true, returns the text
	as if the achievement has no progress.
	
	field     | type    | description
	----------+---------+-----------------------
	chievoId  | string  | id of achievement
	reset     | boolean | return reset tooltip.
	----------+---------+-----------------------
	
	
	achvApi:IsChievoProgress(chievoId, objectives)
	==============================================
	compares current achievement progress with a given table
	and returns true if all objectives in that table are complete.
	
	field      | type   | description
	-----------+--------+----------------------------------------------------
	chievoId   | string | achievement id
	objectives | table  | entries of progress we want to check is completed.
	-----------+--------+----------------------------------------------------
	
]]---------------------------------------------------------------------------

local mod = mod_loader.mods[modApi.currentMod]
local init = require(mod.scriptPath .."achievements/init")
local toast = require(mod.scriptPath .."achievements/toast")

local this = {}
local cachedSettings

-- we need to assert mod to avoid writing garble
-- to mod data when someone does something incorrectly.
assert(type(mod) == 'table')
assert(type(mod.id) == 'string')
assert(type(mod.name) == 'string')
assert(type(mod.version) == 'string')
assert(type(mod.init) == 'function')
assert(type(mod.load) == 'function')

-- we want all achievements nicely listed in modcontent.lua
-- in tables arranged by mod.
sdlext.config(
	"modcontent.lua",
	function(obj)
		obj.achievements = obj.achievements or {}
		obj.achievements[mod.id] = obj.achievements[mod.id] or {}
		cachedSettings = obj.achievements
	end
)

-------------------------------------------------------------------------------------
-------------------------------- HELPER FUNCTIONS -----------------------------------

-- writes achievement data.
local function writeData(id, obj)
	sdlext.config(
		"modcontent.lua",
		function(readObj)
			readObj.achievements[mod.id][id] = obj
			cachedSettings = readObj.achievements
		end
	)
end

-- reads achievement data.
local function readData(id)
	local result = nil
	
	if cachedSettings then
		result = cachedSettings[mod.id][id]
	else
		sdlext.config(
			"modcontent.lua",
			function(readObj)
				cachedSettings = readObj.achievements
				result = cachedSettings[mod.id][id]
			end
		)
	end
	
	return result
end

local function addProgress(chievo, progress, objId)
	progress = progress[objId]
	if not progress then return end
	
	local entry = chievo.id .."_".. objId
	local curr = readData(entry)
	
	if type(progress) == 'number' then
		assert(type(curr) == 'number', "achievement objective ".. entry .." must be a number")
		curr = curr + progress
	else
		assert(type(curr) ~= 'number', "achievement objective ".. entry .." is *not* a number")
		curr = curr or progress
	end
	
	writeData(entry, curr)
end

local function isProgressComplete(chievo, objId)
	local entry = chievo.id .."_".. objId
	local goal = chievo.objective[objId]
	local curr = readData(entry)
	
	if type(goal) == 'number' then
		return curr >= goal
	else
		return curr
	end
	
	return nil
end

local function initChievos(self)
	local m = lmn_achievements
	m.chievos[mod.id] = m.chievos[mod.id] or {
		TriggerAll = function(flag) self:TriggerAll(flag) end
	}
end

-------------------------------------------------------------------------------------
-------------------------------------- API ------------------------------------------

function this:GetVersion()
	return init.version
end

function this:GetHighestVersion()
	return init.mostRecent.version
end

-- returns an achievement from an id, or nil if none can be found.
function this:GetChievo(chievoId)
	assert(type(chievoId) == 'string')
	
	initChievos(self)
	for i, chievo in ipairs(lmn_achievements.chievos[mod.id]) do
		if chievo.id == chievoId  then
			return chievo
		end
	end
	
	return nil
end

-- returns the formated tooltip text of an achievement.
-- if reset flag is set, it will list everything as incomplete.
function this:GetChievoTipFormatted(chievoId, reset)
	assert(type(chievoId) == 'string')
	
	local chievo = self:GetChievo(chievoId)
	local tip = chievo.tip
	if type(chievo.objective) == 'table' then
		for objId, obj in pairs(chievo.objective) do
			local t = type(obj)
			local curr = readData(chievo.id .."_".. objId)
			
			if reset then
				curr = t == 'number' and 0 or nil
			end
			
			if t == 'number' then
				tip = tip:gsub("$".. objId, curr .."/".. obj)
			elseif t == 'boolean' then
				tip = tip:gsub("$".. objId, curr and "Complete" or "Incomplete")
			elseif t == 'string' then
				--tip = tip:gsub(" ?$".. objId ..".?", curr and obj or "")
				undone, done = obj:match("(.+)|(.+)")
				tip = tip:gsub("$".. objId, curr and done or undone)
			end
		end
	end
	
	--return chievo.name .."\n\n".. tip
	return tip
end

-- add a table of achievements.
function this:AddChievos(chievos)
	for _, chievo in ipairs(chievos) do
		self.AddAchievement(mod, chievo)
	end
end

-- add a single achievement.
function this:AddChievo(chievo)
	
	assert(type(chievo) == 'table')
	assert(type(chievo.id) == 'string')
	
	chievo.name = chievo.name or chievo.id
	chievo.tip = chievo.tip or ""
	
	assert(type(chievo.name) == 'string')
	assert(type(chievo.tip) == 'string')
	
	if not chievo.img then
		chievo.img = "img/achievements/No_Icon.png"
		chievo.img_gray = "img/achievements/No_Icon.png"
	else
		assert(type(chievo.img) == 'string')
		chievo.img_gray = chievo.img_gray or chievo.img:sub(1,-5) .."_gray.png"
		assert(type(chievo.img_gray) == 'string')
	end
	
	if chievo.objective then
		assert(type(chievo.objective) == 'table')
		for objId, obj in pairs(chievo.objective) do
			local t = type(obj)
			assert(type(objId) == 'string')
			assert(t == 'number' or t == 'boolean' or t == 'string')
			
			local entry = chievo.id .."_".. objId
			local curr = readData(entry)
			if t == 'number' then
				-- initialize progress objectives to 0
				writeData(entry, curr or 0)
			end
		end
	end
	
	initChievos(self)
	table.insert(lmn_achievements.chievos[mod.id], chievo)
	
	chievo.TriggerChievo = function(flag) self:TriggerChievo(chievo.id, flag) end
	chievo.GetStatus = function() return self:GetChievoStatus(chievo.id) end
	chievo.GetTip = function(reset) return self:GetChievoTipFormatted(chievo.id, reset) end
end

-- sets an achievement to complete, or incomplete if flag is false.
-- alternate signature: TriggerChievo(chievoId, objective)
-- where objective is a table with any progress changes added to the achievement.
function this:TriggerChievo(chievoId, flag)
	assert(type(chievoId) == 'string')
	
	if flag ~= false then
		if self:GetChievoStatus(chievoId) then return end	-- don't trigger completed achievements.
		if IsTestMechScenario() then return end				-- don't trigger achievements when testing mech.
		
		-- if achievement has sub-objectives.
		if type(flag) == 'table' then
			local progress = flag
			local completed = true
			local chievo = self:GetChievo(chievoId)
			assert(type(chievo.objective) == 'table')
			
			-- go through all objectives, add to progress, and check if completed.
			for objId, obj in pairs(chievo.objective) do
				addProgress(chievo, progress, objId)
				completed = completed and isProgressComplete(chievo, objId)
			end
			
			-- if not all objectives are complete, return.
			if not completed then return end
		end
		
		-- toast completed achievement.
		toast:Add(self:GetChievo(chievoId))
	end
	
	-- set achievement completion status.
	flag = flag ~= false and true or nil
	writeData(chievoId, flag)
end

-- sets all achievements to complete, or nil if flag is false.
function this:TriggerAll(flag)
	flag = flag ~= false and true or nil
	for _, chievo in ipairs(lmn_achievements.chievos[mod.id]) do
		writeData(chievo.id, flag)
		
		if chievo.objective then
			for id, v in pairs(chievo.objective) do
				if not flag then
					v = type(v) == 'number' and 0 or nil
				end
				writeData(chievo.id .."_".. id, v)
			end
		end
	end
end

-- returns true if achievement is completed, or false otherwise.
function this:GetChievoStatus(chievoId)
	assert(type(chievoId) == 'string')
	
	return readData(chievoId)
end

-- returns true if achievement progress is currently
-- more or equal the table objectives passed to the function.
function this:IsChievoProgress(chievoId, objectives)
	assert(type(chievoId) == 'string')
	assert(type(objectives) == 'table')
	
	local chievo = self:GetChievo(chievoId)
	local complete = true
	
	for objId, obj in pairs(objectives) do
		local curr = readData(chievo.id .."_".. objId)
		
		if type(chievo.objective[objId]) == 'number' then
			complete = complete and curr >= obj
		else
			complete = complete and curr
		end
	end
	
	return complete
end

-- trigger a custom unlock text.
function this:ToastUnlock(chievo)
	assert(type(chievo) == 'table')
	assert(type(chievo.name) == 'string')
	assert(type(chievo.tip) == 'string')
	assert(type(chievo.img) == 'string')
	chievo = shallow_copy(chievo)
	
	chievo.GetTip = function() return chievo.tip end
	toast:Add(chievo)
end

return this