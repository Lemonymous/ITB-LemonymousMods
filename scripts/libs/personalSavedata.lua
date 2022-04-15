
local VERSION = "1.0.0"

local function GetCurrentGame()
	if Game then
		return GAME
	end
end

local savetable_mt = {
	__getsavetable = function(self)
		local saveobject = getmetatable(self).__getsaveobject()
		if saveobject then
			for i = 1, #self.__queue do
				local queuer = self.__queue[i]
				local subtable = saveobject[queuer]
				if subtable == nil then
					subtable = {}
					saveobject[queuer] = subtable
				end
				saveobject = subtable
			end
		end
		return saveobject
	end,
	__index = function(self, key)
		local savetable = getmetatable(self).__getsavetable(self)
		if savetable then
			return savetable[key] or self.__default[key]
		else
			return self.__default[key]
		end
	end,
	__newindex = function(self, key, value)
		Assert.NotEquals('table', type(value), "Cannot store tables")
		local savetable = getmetatable(self).__getsavetable(self)
		if savetable then
			savetable[key] = value
		else
			self.__default[key] = value
		end
	end,
}

local __pairs = function(self)
	local default = self.__default
	local savetable = getmetatable(self).__getsavetable(self) or default
	local traversed = {}

	return function(self, key)
		local value

		if savetable ~= default then
			repeat
				key, value = next(self, key)
			until false
				or key == nil
				or tostring(key):sub(1,2) ~= "__"

			if key ~= nil then
				traversed[key] = true
			else
				savetable = default
			end
		end

		if savetable == default then
			repeat
				key, value = next(default, key)
			until false
				or key == nil
				or (tostring(key):sub(1,2) ~= "__" and not traversed[key])
		end

		return key, value
	end, savetable, nil
end

local game_savetable_mt = {
	__getsaveobject = GetCurrentGame,
	__getsavetable = savetable_mt.__getsavetable,
	__index = savetable_mt.__index,
	__newindex = savetable_mt.__newindex,
}

local mission_savetable_mt = {
	__getsaveobject = GetCurrentMission,
	__getsavetable = savetable_mt.__getsavetable,
	__index = savetable_mt.__index,
	__newindex = savetable_mt.__newindex,
}

local create_game_savetable_mt = {
	__call = function(self, ...)
		local args = {...}
		local savetable = {
			__queue = args,
			__default = {},
			__pairs = __pairs,
		}

		Assert.NotEquals(0, #args, "No arguments")
		setmetatable(savetable, game_savetable_mt)

		return savetable
	end,
}

local create_mission_savetable_mt = {
	__call = function(self, ...)
		local args = {...}
		local savetable = {
			__queue = args,
			__default = {},
			__pairs = __pairs,
		}

		Assert.NotEquals(0, #args, "No arguments")
		setmetatable(savetable, mission_savetable_mt)

		return savetable
	end,
}


local function finalizeInit(self)
end

local function onModsInitialized()
	local isHighestVersion = true
		and PersonalSavedata.initialized ~= true
		and PersonalSavedata.version == VERSION

	if isHighestVersion then
		PersonalSavedata:finalizeInit()
		PersonalSavedata.initialized = true
	end
end


local isNewerVersion = false
	or PersonalSavedata == nil
	or VERSION > PersonalSavedata.version

if isNewerVersion then
	PersonalSavedata = PersonalSavedata or {}
	PersonalSavedata.version = VERSION
	PersonalSavedata.finalizeInit = finalizeInit

	if GAME_savedata == nil then
		GAME_savedata = {}
	end
	if Mission_savedata == nil then
		Mission_savedata = {}
	end

	setmetatable(GAME_savedata, create_game_savetable_mt)
	setmetatable(Mission_savedata, create_mission_savetable_mt)

	modApi.events.onModsInitialized:subscribe(onModsInitialized)
end

return PersonalSavedata
