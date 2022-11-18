
local VERSION = "1.1.0"

-- Returns tbl[arg_1][arg_2][..][arg_n]
-- Creates empty tables for any subtable that is `nil`
function getTableTail(tbl, ...)
	Assert.Equals('table', type(tbl), "Argument #1")

	local args = {...}

	if #args == 0 then
		Assert.Error("Not enough arguments")
	end

	for i = 1, #args-1 do
		local id = args[i]
		local subtbl = tbl[id]
		if subtbl == nil then
			subtbl = {}
			tbl[id] = subtbl
		end
		tbl = subtbl
	end

	local id = args[#args]
	return tbl[id]
end

-- Sets the tbl[arg_1][arg_2][..][arg_n] = obj
-- Creates empty tables for any subtable that is `nil`
function setTableTail(tbl, obj, ...)
	Assert.Equals('table', type(tbl), "Argument #1")

	local args = {...}

	if #args == 0 then
		Assert.Error("Not enough arguments")
	end

	for i = 1, #args-1 do
		local id = args[i]
		local subtbl = tbl[id]
		if subtbl == nil then
			subtbl = {}
			tbl[id] = subtbl
		end
		tbl = subtbl
	end

	local id = args[#args]
	tbl[id] = obj
end


local function updateCache()
	if not modApi:isProfilePath() then return end
	local difficulty = GetDifficultyFaceName(GetRealDifficulty())

	sdlext.config(
		modApi:getCurrentProfilePath().."modcontent.lua",
		function(readObj)
			local allAchievements = modApi.achievements:get()

			for modId, modAchievements in pairs(allAchievements) do
				for _, achievement in ipairs(modAchievements) do
					if achievement.trackByDifficulty then
						local progress = shallow_copy(getTableTail(readObj, "achievementsByDifficulty", modId, achievement.id, difficulty))

						if progress == nil then
							progress = achievement:getObjectiveInitialState()
						end

						progress.highscore = nil

						setTableTail(readObj, progress, "achievements", modId, achievement.id)
					end
				end
			end

			modApi.achievements.cachedProfileDataByDifficulty = readObj.achievementsByDifficulty
			modApi.achievements.cachedProfileData = readObj.achievements
		end
	)
end

-- writes achievement data by difficulty.
local function writeData(modId, achievementId, difficultyId, obj)
	if not modApi:isProfilePath() then return end
	local difficulty = GetDifficultyFaceName(difficultyId)

	assert(type(modId) == 'string')
	assert(type(achievementId) == 'string')

	sdlext.config(
		modApi:getCurrentProfilePath().."modcontent.lua",
		function(readObj)
			setTableTail(readObj, obj, "achievementsByDifficulty", modId, achievementId, difficulty)
			modApi.achievements.cachedProfileDataByDifficulty = readObj.achievementsByDifficulty
		end
	)
end

-- reads achievement data by difficulty.
local function readData(modId, achievementId, difficultyId)
	if not modApi:isProfilePath() then return nil end
	local difficulty = GetDifficultyFaceName(difficultyId)

	assert(type(modId) == 'string')
	assert(type(achievementId) == 'string')

	if modApi.achievements.cachedProfileDataByDifficulty == nil then
		updateCache()
	end

	local cache = modApi.achievements.cachedProfileDataByDifficulty
	return shallow_copy(getTableTail(cache, modId, achievementId, difficulty))
end


local function isFailed(self)
	return false
end

local function isNotFailed(self)
	return not self:isFailed()
end

local function getProgressOnDifficulty(self, difficultyId)
	local progress = readData(self.mod_id, self.id, difficultyId)

	if progress == nil then
		progress = self:getObjectiveInitialState()
	end

	return progress
end

local function isCompleteOnDifficulty(self, difficultyId)
	local achievementId = self.id
	local cache = modApi.achievements.cachedProfileData
	local cacheMod = getTableTail(cache, self.mod_id)
	local progress = cacheMod[achievementId]
	local progressOnDifficulty = self:getProgressOnDifficulty(difficultyId)
	progressOnDifficulty.highscore = nil

	cacheMod[achievementId] = progressOnDifficulty
	local isComplete = self:isComplete_orig()
	cacheMod[achievementId] = progress

	return isComplete
end

local function isComplete(self, objectiveId)
	if sdlext.isMainMenu() and objectiveId == nil then
		-- While in the main menu, return true if the
		-- achievement has been completed on ANY difficulty
		for diff = DIFF_EASY, DIFF_HARD do
			if self:isCompleteOnDifficulty(diff) then
				return true
			end
		end

		return false
	end

	return self:isComplete_orig(objectiveId)
end

local function getHighscore(self)
	return self:getHighscoreOnDifficulty(GetRealDifficulty())
end

local function getHighscoreOnDifficulty(self, difficultyId)
	local progressOnDifficulty = self:getProgressOnDifficulty(difficultyId)
	return progressOnDifficulty.highscore
end

local function setProgress(self, newState)
	local currState = self:getProgress()
	local difficultyId = GetRealDifficulty()
	local currHighscore = self:getHighscore() or 0
	local newHighscore = newState.highscore or 0
	local isHighscore = newHighscore > currHighscore

	for i, v in pairs(newState) do
		if type(v) == 'number' then
			local curr = currState[i] or 0
			local new = newState[i]
			newState[i] = math.max(curr, new)
		end
	end

	local function setProgress()
		writeData(self.mod_id, self.id, difficultyId, shallow_copy(newState))
		newState.highscore = nil
		self:setProgress_orig(newState)
	end

	if isHighscore and self.retoastHighscore then
		local wasComplete = self:isComplete()
		setProgress()

		if wasComplete and self:isComplete() then
			modApi.toasts:add(self)
		end
	else
		setProgress()
	end
end

local function completeWithHighscore(self, highscore)
	if self:isFailed() then
		return
	end

	local currState = shallow_copy(self:getProgress())
	local completeState = self:getObjectiveCompleteState()

	for i, v in pairs(completeState) do
		if type(v) == 'number' then
			local curr = currState[i] or 0
			local new = completeState[i]
			completeState[i] = math.max(curr, new)
		end
	end

	completeState.highscore = highscore
	self:setProgress(completeState)
end

local function getTooltip(self)
	local modId = self.mod_id
	local achievementId = self.id
	local currentDiff = GetRealDifficulty()
	local tooltip = self:getTooltip_orig()
	local textDiffStatus = {}

	for diff = DIFF_EASY, DIFF_HARD do
		local progressOnDifficulty = self:getProgressOnDifficulty(diff)
		local completeOnDifficulty = self:isCompleteOnDifficulty(diff)
		local textComplete = self:getTextDiffComplete(diff, progressOnDifficulty)
		local textIncomplete = self:getTextDiffIncomplete(diff, progressOnDifficulty)
		textDiffStatus[diff] = completeOnDifficulty and textComplete or textIncomplete
	end

	local textStatus = ""
	local canBeToasted = false
		or self.retoastHighscore == true
		or self:isComplete() == false

	if canBeToasted then
		if self:isFailed() then
			textStatus = "\n\nFailed: "..self:getTextFailed()
		else
			local textProgress = self:getTextProgress()
			if textProgress ~= nil then
				textStatus = "\n\nProgress: "..textProgress
			end
		end
	end

	tooltip = tooltip
		..textStatus
		.."\n"
		.."\nEasy: "..textDiffStatus[DIFF_EASY]
		.."\nNormal: "..textDiffStatus[DIFF_NORMAL]
		.."\nHard: "..textDiffStatus[DIFF_HARD]

	return tooltip
end

local function getTextDiffComplete(self, difficultyId, difficultyProgress)
	local text = self.textDiffComplete

	if text == nil then
		return "Complete"
	end

	text = text:gsub("$highscore", difficultyProgress.highscore or "-")

	return text
end

local function getTextDiffIncomplete(self, difficultyId, difficultyProgress)
	return self.textDiffIncomplete or "Incomplete"
end

local function getTextFailed(self)
	return self.textFailed or "Objective failed"
end

local function getTextProgress(self)
	return nil
end

local function addAchievement(self, def)
	Assert.Equals('table', type(def), "Argument #1")

	if def.objective == nil then
		def.objective = { complete = true }
	elseif type(def.objective) ~= 'table' then
		def.objective = { complete = def.objective }
	end

	local achievement = modApi.achievements:add(def)
	achievement.trackByDifficulty = true
	achievement.retoastHighscore = def.retoastHighscore
	achievement.textDiffComplete = def.textDiffComplete
	achievement.textDiffIncomplete = def.textDiffIncomplete
	achievement.textFailed = def.textFailed

	achievement.setProgress_orig = achievement.setProgress
	achievement.getTooltip_orig = achievement.getTooltip
	achievement.isComplete_orig = achievement.isComplete

	achievement.getTooltip = getTooltip
	achievement.getHighscore = getHighscore
	achievement.setProgress = setProgress
	achievement.isComplete = isComplete
	achievement.isFailed = isFailed
	achievement.isNotFailed = isNotFailed
	achievement.completeWithHighscore = completeWithHighscore
	achievement.isCompleteOnDifficulty = isCompleteOnDifficulty
	achievement.getHighscoreOnDifficulty = getHighscoreOnDifficulty
	achievement.getProgressOnDifficulty = getProgressOnDifficulty
	achievement.getTextDiffComplete = getTextDiffComplete
	achievement.getTextDiffIncomplete = getTextDiffIncomplete
	achievement.getTextFailed = getTextFailed
	achievement.getTextProgress = getTextProgress

	return achievement
end


local function onRealDifficultyChanged()
	updateCache()

	if sdlext.isHangar() then
		-- Hack to update squad ui
		local squadId = HangarGetSelectedSquad()
		modApi.events.onHangarSquadSelected:dispatch(squadId)
	end
end

local achievement_mt = {
	__index = function(self, key)
		return self.__source[key]
	end,
	__newindex = function(self, key, value)
		self.__source[key] = value
	end,
}

local __pairs = function(self)
	return function(self, key)
		local value
		repeat
			key, value = next(self, key)
		until key == nil or tostring(key):sub(1,1) ~= "__"
		return key, value
	end, self.__source, nil
end

local function finalizeInit(self)
	-- The achievement system closes the ability to add
	-- achievements when mods have initialized, so we
	-- must force add them.
	local canBeAdded_orig = modApi.achievements.canBeAdded
	local achievements = {}

	modApi.achievements.canBeAdded = function() return true end
	modApi.achievements.addExt = addAchievement

	-- Create achievements of all the achievement defs.
	for i, def in ipairs(self.achievementDefs) do
		local achievement = modApi.achievements:addExt(def)

		for i, v in pairs(def) do
			if v ~= achievement[i] then
				achievement[i] = v
			end

			def[i] = nil
		end

		-- Assign metatable that refers to the actual achievement.
		def.__source = achievement
		def.__pairs = __pairs
		setmetatable(def, achievement_mt)

		achievements[i] = achievement
	end

	self.achievementDefs = nil
	modApi.achievements.canBeAdded = canBeAdded_orig

	-- The achievement system triggers achievement rewards
	-- when it closes ability to add new achievements, so
	-- we must manually trigger any rewards from the newly
	-- added achievements.
	for _, achievement in ipairs(achievements) do
		if achievement:isComplete() then
			achievement:addReward()
		end
	end

	modApi.events.onProfileChanged:subscribe(updateCache)
	modApi.events.onRealDifficultyChanged:subscribe(onRealDifficultyChanged)
end

local function onModsInitialized()
	local isHighestVersion = true
		and AchievementsExt.initialized ~= true
		and AchievementsExt.version == VERSION

	if isHighestVersion then
		AchievementsExt:finalizeInit()
		AchievementsExt.initialized = true
	end
end


local isNewerVersion = false
	or AchievementsExt == nil
	or VERSION > AchievementsExt.version

if isNewerVersion then
	AchievementsExt = AchievementsExt or {}
	AchievementsExt.version = VERSION
	AchievementsExt.finalizeInit = finalizeInit

	-- Prepare a list of achievement definitions.
	-- When calling addExt, defs will be stored
	-- so they can be added as proper achievements
	-- once every mod has been initialized and
	-- allowed their chance to update this module.
	if AchievementsExt.achievementDefs == nil then
		AchievementsExt.achievementDefs = {}

		function modApi.achievements:addExt(def)
			if def.mod_id == nil then
				def.mod_id = modApi.currentMod
			end
			table.insert(AchievementsExt.achievementDefs, def)
			return def
		end
	end

	modApi.events.onModsInitialized:subscribe(onModsInitialized)
end

return AchievementsExt
