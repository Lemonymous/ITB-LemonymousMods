
local path = mod_loader.mods[modApi.currentMod].resourcePath
local utils = require(path .."scripts/utils")
local astar = require(path .."scripts/astar")
local weaponPreview = require(path .."scripts/weaponPreview/api")

modApi:appendAsset("img/weapons/lmn_flood_generator.png", path .."img/weapons/flood_generator.png")

lmn_Flood_Generator = Skill:new{
	Name = "Flood Generator",
	Description = "Call forth a flood, raging across the map.",
	Rarity = 4,
	Class = "",
	Icon = "weapons/lmn_flood_generator.png",
	PowerCost = 2,
	Upgrades = 0,
	UpgradeCost = { },
	UpgradeList = { },
	Limited = 1,
	TipImage = {
		Unit = Point(2,3),
		Enemy = Point(2,2),
		Enemy2 = Point(3,2),
		Target = Point(0,2),
	}
}

function lmn_Flood_Generator:GetTargetArea(p)
	local ret = PointList()
	
	local size = Board:GetSize()
	for x = 1, size.x - 2 do
		for y = 0, size.y - 1, size.y - 1 do
			local curr = Point(x,y)
			if Env_lmn_FlashFlood:IsValidTarget(curr) then
				ret:push_back(curr)
			end
		end
	end
	
	for y = 1, size.y - 2 do
		for x = 0, size.x - 1, size.x - 1 do
			local curr = Point(x,y)
			if Env_lmn_FlashFlood:IsValidTarget(curr) then
				ret:push_back(curr)
			end
		end
	end
	
	return ret
end

function lmn_Flood_Generator:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local size = Board:GetSize()
	local locs = {}
	
	local across = Point(p2.x, p2.y)
	if p2.x == 0 then
		across.x = size.x - 1
	elseif p2.y == 0 then
		across.y = size.y - 1
	elseif p2.x == size.x - 1 then
		across.x = 0
	elseif p2.y == size.y - 1 then
		across.y = 0
	end
	
	targets = utils.getBoard(function(p)
		return
			Env_lmn_FlashFlood:IsValidTarget(p) and
			Board:IsEdge(p)
	end)
	table.sort(targets, function(a,b) return a:Manhattan(across) < b:Manhattan(across) end)
	
	for _, target in ipairs(targets) do
		locs = astar.GetPath(p2, target, function(p) return Env_lmn_FlashFlood:IsValidTarget(p) end)
		if #locs > 0 then
			break
		end
	end
	
	for i, p in ipairs(locs) do
		weaponPreview:SetLooping(false)
		weaponPreview:AddImage(p, Env_lmn_FlashFlood.CombatIcon, GL_Color(255,226,88,0.75))
		
		if i < #locs then
			weaponPreview:AddDelay(0.02)
			ret:AddSound("/props/tide_flood")
		else
			ret:AddSound("/props/tide_flood_last")
		end
		
		local d = SpaceDamage(p)
		d.iTerrain = TERRAIN_WATER
		
		local terrain = Board:GetTerrain(p)
		if terrain == TERRAIN_MOUNTAIN or terrain == TERRAIN_BUILDING or Board:IsDangerousItem(p)then
			d.iDamage = DAMAGE_DEATH
		end
		
		ret:AddDamage(d)
		ret:AddBounce(p, -1)
		ret:AddDelay(0.08)
	end
	
	return ret
end