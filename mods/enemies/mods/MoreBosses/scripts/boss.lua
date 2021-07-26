
local path = mod_loader.mods[modApi.currentMod].scriptPath
local getModUtils = require(path .."getModUtils")
local this = {
	bosses = {}
}

function this:Add(boss)
	assert(type(boss) == 'table')
	assert(type(boss.islandLock) == 'number')
	assert(type(boss.sMission) == 'string')
	assert(_G[boss.sMission])
	assert(type(_G[boss.sMission].BossPawn) == 'string')
	assert(_G[_G[boss.sMission].BossPawn])
	
	boss.option = boss.option or "option_".. boss.sMission
	boss.name = boss.name or _G[_G[boss.sMission].BossPawn].Name or ""
	boss.desc = boss.desc or _G[boss.sMission].BossText or ""
	boss.default = boss.default or {enabled = true}
	
	table.insert(self.bosses, boss)
	modApi:addGenerationOption(
		boss.option,
		boss.name,
		boss.desc,
		boss.default
	)
end

function this:ResetSpawnsWhenKilled(boss)
	assert(type(boss.sMission) == 'string')
	assert(_G[boss.sMission])
	assert(modApiExt_internal)
	
	local modUtils = getModUtils()
	modUtils:addPawnKilledHook(function(mission, pawn)
		if
			mission.ID ~= boss.sMission    or
			pawn:GetId() ~= mission.BossID
		then
			return
		end
		
		mission.SpawnMod = Mission.SpawnMod
		mission.MaxEnemy = Mission.MaxEnemy
	end)
end

function this:SetSpawnsForDifficulty(boss, ...)
	assert(type(boss.sMission) == 'string')
	assert(_G[boss.sMission])
	
	for _, list in ipairs(arg) do
		assert(type(list) == 'table')
		assert(type(list.difficulty) == type(DIFF_EASY))
		
		list.SpawnStartMod = list.SpawnStartMod or _G[boss.sMission].SpawnStartMod
		list.SpawnMod = list.SpawnMod or _G[boss.sMission].SpawnMod
		list.MaxEnemy = list.MaxEnemy or _G[boss.sMission].MaxEnemy
		
		modApi:addPreMissionAvailableHook(function(mission)
			if mission.ID ~= boss.sMission then
				return
			end
			
			if GetDifficulty() == list.difficulty then
				mission.SpawnStartMod = list.SpawnStartMod
				mission.SpawnMod = list.SpawnMod
				mission.MaxEnemy = list.MaxEnemy
			end
		end)
	end
end

function this:load(options)
	for _, boss in ipairs(self.bosses) do
		if options[boss.option].enabled then
			IslandLocks[boss.sMission] = boss.islandLock
			
			if not list_contains(Corp_Default.Bosses, boss.sMission) then
				table.insert(Corp_Default.Bosses, boss.sMission)
			end
		else
			IslandLocks[boss.sMission] = nil
			remove_element(boss.sMission, Corp_Default.Bosses)
		end
	end
end

return this