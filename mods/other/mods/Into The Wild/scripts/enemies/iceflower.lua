
-- requires sunflower

local path = mod_loader.mods[modApi.currentMod].resourcePath
local utils = require(path .."scripts/utils")
local tutorialTips = require(path .."scripts/tutorialTips")
local teamTurn = require(path .."scripts/teamTurn")
local pawnSpace = require(path .."scripts/pawnSpace")
local trait = require(path .."scripts/trait")
local getModUtils = require(path .."scripts/getModUtils")

local this = {}

local function isIceFlower(pawnType)
	return
		pawnType == "lmn_Iceflower1"	or
		pawnType == "lmn_Iceflower2"
end

function this:init(mod)
	WeakPawns.lmn_Iceflower = false
	Spawner.max_pawns.lmn_Iceflower = 4
	Spawner.max_level.lmn_Iceflower = 1
	
	local writePath = "img/units/aliens/"
	local readPath = path .. "img/units/aliens/"
	local imagePath = writePath:sub(5,-1)
	utils.appendAssets{
		writePath = writePath,
		readPath = readPath,
		{"lmn_iceflower1.png", "iceflower1.png"},
		{"lmn_iceflower1a.png", "iceflower1a.png"},
		{"lmn_iceflower1_emerge.png", "iceflower1e.png"},
		{"lmn_iceflower1_death.png", "iceflower1.png"},
		{"lmn_iceflower1w.png", "iceflower1.png"},
		
		{"lmn_iceflower2.png", "iceflower1.png"},
		{"lmn_iceflower2a.png", "iceflower1a.png"},
		{"lmn_iceflower2_emerge.png", "iceflower1e.png"},
		{"lmn_iceflower2_death.png", "iceflower1.png"},
		{"lmn_iceflower2w.png", "iceflower1.png"},
	}
	
	local a = ANIMS
	local base = a.BaseUnit:new{Image = imagePath .."lmn_iceflower1.png", PosX = -20, PosY = -10}
	local alpha = a.BaseUnit:new{Image = imagePath .."lmn_iceflower2.png", PosX = -23, PosY = -9}
	local baseEmerge = a.BaseEmerge:new{Image = imagePath .."lmn_iceflower1_emerge.png", PosX = -23, PosY = -9, Height = 1}
	local alphaEmerge = a.BaseEmerge:new{Image = imagePath .."lmn_iceflower2_emerge.png", PosX = -23, PosY = -9, Height = 1}
	
	a.lmn_Iceflower1 = base
	a.lmn_Iceflower1a = base:new{Image = imagePath .."lmn_iceflower1a.png", NumFrames = 4}
	a.lmn_Iceflower1e = baseEmerge
	a.lmn_Iceflower1d = base:new{Image = imagePath .."lmn_iceflower1_death.png", Loop = false}
	a.lmn_Iceflower1w = base:new{Image = imagePath .."lmn_iceflower1w.png"}
	
	a.lmn_Iceflower2 = alpha
	a.lmn_Iceflower2a = alpha:new{Image = imagePath .."lmn_iceflower2a.png", NumFrames = 4}
	a.lmn_Iceflower2e = alphaEmerge
	a.lmn_Iceflower2d = alpha:new{Image = imagePath .."lmn_iceflower2_death.png", Loop = false}
	a.lmn_Iceflower2w = alpha:new{Image = imagePath .."lmn_iceflower2w.png"}
	
	trait:Add(
		"lmn_iceflower_walk",
		"lmn_Iceflower1",
		"img/combat/evolve.png",
		"img/empty.png",
		{"Icy Touch", "Freezes the ground it walks on."},
		{"Icy Touch", "This unit is so cold it freezes the ground it walks on."}
	)
	
	lmn_Iceflower1 = lmn_Sunflower1:new{
		Name = "Iceflower",
		Image = "lmn_Iceflower1",
		lmn_PetalsOnDeath = "lmn_Emitter_Iceflower1d",
		SkillList = { "lmn_IceflowerAtk1", "lmn_IceflowerAtkRepeat1" },
		IsPortrait = false,
		--Portrait = "enemy/lmn_Iceflower1", -- TODO: add portrait
	}
	
	--[[lmn_Iceflower2 = lmn_Sunflower2:new{
		Name = "Alpha Iceflower",
		Image = "lmn_Iceflower2",
		lmn_PetalsOnDeath = "lmn_Emitter_Iceflower2d",
		SkillList = { "lmn_IceflowerAtk2", "lmn_IceflowerAtkRepeat2" },
		--Portrait = "enemy/lmn_Iceflower2", -- TODO: add portrait
	}]]
	
	lmn_IceflowerAtk1 = lmn_SunflowerAtk1:new{
		Name = "Icy Seeds",
		--Icon = "weapons/lmn_IceflowerAtk1.png", -- TODO
		Description = "Launch a couple of icy seeds. Last one freezes target.",
		Self = "lmn_IceflowerAtk1",
		Freeze = true,
		Anim_Impact = "ExplIce1",
		Art_Projectile = "effects/shot_lmn_iceflower",
		Sound_Launch = "/enemy/firefly_soldier_1/attack",
		Sound_Impact = "/impact/dynamic/enemy_projectile",
		CustomTipImage = "lmn_IceflowerAtk1_Tip",
		TipImage = {
			Unit = Point(2,3),
			Building = Point(2,2),
			Enemy = Point(2,1),
			Target = Point(2,2),
			CustomPawn = "lmn_Iceflower1"
		}
	}
	
	--[[lmn_IceflowerAtk2 = lmn_IceflowerAtk1:new{
		Description = "Launch a trio of icy seeds. Last one freezes target.",
		Self = "lmn_IceflowerAtk2",
		Damage = 1,
		Attacks = 3,
		Freeze = true,
		--Icon = "weapons/lmn_IceflowerAtk2.png", -- TODO
		Anim_Impact = "ExplIce1",
		Art_Projectile = "effects/shot_lmn_iceflower",
		CustomTipImage = "lmn_IceflowerAtk2_Tip",
		TipImage = {
			Unit = Point(2,3),
			Building = Point(2,2),
			Enemy = Point(2,1),
			Target = Point(2,2),
			CustomPawn = "lmn_Iceflower2"
		}
	}]]
	
	lmn_IceflowerAtkRepeat1 = lmn_SunflowerAtkRepeat1:new{Description = "Launch an icy seed.", Freeze = true, CustomTipImage = ""}
	--lmn_IceflowerAtkRepeat2 = lmn_SunflowerAtkRepeat2:new{Description = "Launch an icy seed.", Freeze = true, CustomTipImage = ""}
	
	lmn_IceflowerAtk1_Tip = lmn_SunflowerAtk1_Tip:new{Freeze = true, TipImage = lmn_IceflowerAtk1.TipImage}
	--lmn_IceflowerAtk2_Tip = lmn_SunflowerAtk2_Tip:new{Freeze = true, TipImage = lmn_IceflowerAtk2.TipImage}
	
	modApi:appendAsset("img/effects/emitters/lmn_petal_iceflower1.png", path .."img/effects/emitters/petal_iceflower1.png")
	--modApi:appendAsset("img/effects/emitters/lmn_petal_iceflower2.png", path .."img/effects/emitters/petal_iceflower2.png")
	lmn_Emitter_Iceflower1d = lmn_Emitter_Sunflower1d:new{image = "effects/emitters/lmn_petal_iceflower1.png"}
	--lmn_Emitter_Iceflower2d = lmn_Emitter_Sunflower2d:new{image = "effects/emitters/lmn_petal_iceflower2.png"}
end

function this:load(mod, options, version)
	local modUtils = getModUtils()
	
	simpleTerrain = {
		[TERRAIN_ROAD]   = true,
		[TERRAIN_FOREST] = true,
		[TERRAIN_RUBBLE] = true
	}
	
	local function freezeSpace(pawn)
		local loc = pawn:GetSpace()
		local terrain = Board:GetTerrain(loc)
		
		if terrain == TERRAIN_WATER then
			Board:SetTerrain(loc, TERRAIN_ICE)
		elseif terrain ~= TERRAIN_HOLE then
			pawnSpace.ClearSpace(loc)
			
			local d = SpaceDamage(loc)
			d.iFrozen = 1
			
			if Board:IsPod(loc) or Board:IsSpawning(loc) then
				-- normal freeze.
			elseif simpleTerrain[terrain] then
				-- normal freeze.
			elseif Board:IsFire(loc) then
				-- remove fire.
				d.iFire = 2
			elseif terrain == TERRAIN_SAND then
				-- clear tile of sand.
				Board:ClearSpace(loc)
			end
			
			Board:DamageSpace(d)
			
			pawnSpace.Rewind()
		end
	end
	
	modUtils:addPawnPositionChangedHook(function(_, pawn)
		if isIceFlower(pawn:GetType()) then
			freezeSpace(pawn)
		end
	end)
	
	modUtils:addPawnTrackedHook(function(_, pawn)
		
		if isIceFlower(pawn:GetType()) then
			local loc = pawn:GetSpace()
			tutorialTips:Trigger("lmn_Sunflower", loc)
			
			freezeSpace(pawn)
		end
	end)
end

return this