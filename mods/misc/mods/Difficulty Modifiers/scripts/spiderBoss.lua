
local function SpawnSpiderlings(id)
	local eggCount = GetDifficulty() == DIFF_EASY and 2 or 3
	
	local proj_info = { image = "effects/shotup_spider.png", launch = "/enemy/spider_boss_1/attack_egg_launch", impact = "/enemy/spider_boss_1/attack_egg_land" }
	return Mission:FlyingSpawns(Board:GetPawnSpace(id), eggCount, "SpiderlingEgg1", proj_info)
end

local oldMissionUpdateSpawning = Mission.UpdateSpawning
function Mission:UpdateSpawning()
	oldMissionUpdateSpawning(self) -- spawn first so the spiderlings know where not to spawn
	
	local ids = extract_table(Board:GetPawns(TEAM_ENEMY))
	for _, id in ipairs(ids) do
		local pawn = Board:GetPawn(id)
		if	pawn:GetType() == "SpiderBoss"	and
			id ~= self.BossID				and
			not pawn:IsFrozen()
			
		then
			SpawnSpiderlings(id)
		end
	end
end