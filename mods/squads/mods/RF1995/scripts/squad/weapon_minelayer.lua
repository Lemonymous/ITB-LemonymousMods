
-- Remaining issues:
-- Move to mine on unbroken ice -> mine breaks ice -> undo move -> ice remains broken

lmn_Minelayer_Mine = Skill:new{
	Name = "Proximity Mines",
	Class = "Ranged",
	Icon = "weapons/rf_mine.png",
	Description = "Passive Effect\n\nLeave a mine after moving.",
	Damage = 3,
	PowerCost = 0,
	Upgrades = 1,
	MineImmunity = false,
	UpgradeCost = {1},
	UpgradeList = {"Minesweeper"},
	GetTargetArea = function () return PointList() end,
	CustomTipImage = "lmn_Minelayer_Mine_Tip",
	TipImage = {
		CustomPawn = "lmn_MinelayerMech",
		Unit = Point(2,3),
		Target = Point(2,1),
	}
}

lmn_Minelayer_Mine_A = lmn_Minelayer_Mine:new{
	UpgradeDescription = "All allies gain immunity to mines.",
	MineImmunity = true,
	CustomTipImage = "lmn_Minelayer_Mine_Tip_A",
}

local function IsMinelayer(pawn)
	return pawn:IsWeaponPowered("lmn_Minelayer_Mine")
end

local function HasMinesweeper(pawn)
	if pawn:IsEnemy() or not pawn:IsMech() then
		return false
	end

	for _, id in ipairs(extract_table(Board:GetPawns(TEAM_MECH))) do
		if Board:GetPawn(id):IsWeaponPowered("lmn_Minelayer_Mine_A") then
			return true
		end
	end

	return false
end

-----------------------
-- move skill override
-----------------------
local oldMoveGetSkillEffect = Move.GetSkillEffect
function Move:GetSkillEffect(p1, p2, ...)
	origMove = extract_table(oldMoveGetSkillEffect(self, p1, p2, ...).effect)
	local ret = SkillEffect()

	if IsMinelayer(Pawn) then
		local damage = SpaceDamage(p1)
		damage.sItem = "lmn_Minelayer_Item_Mine"
		damage.sImageMark = "combat/rf_mark_mine_small.png"
		damage.sSound = "/impact/generic/grapple"
		ret:AddDamage(damage)
	end

	local item_at_destination = Board:GetItem(p2)
	if item_at_destination ~= "" then
		if HasMinesweeper(Pawn) then
			lmn_Minelayer_Item_Mine_Dummy = shallow_copy(_G[item_at_destination])
			lmn_Minelayer_Item_Mine_Dummy.Damage = SpaceDamage()

			local replace_mine = SpaceDamage(p2)
			replace_mine.sItem = "lmn_Minelayer_Item_Mine_Dummy"

			if item_at_destination == "lmn_Minelayer_Item_Mine" then
				replace_mine.sImageMark = "combat/icons/rf_icon_minesweeper_glow.png"
			else
				replace_mine.sImageMark = "combat/icons/rf_icon_strikeout.png"
			end

			ret:AddDamage(replace_mine)
		elseif item_at_destination == "lmn_Minelayer_Item_Mine" then
			local mark = SpaceDamage(p2)
			mark.sImageMark = "combat/icons/icon_mine_glow.png"

			ret:AddDamage(mark)
		end
	end

	-- reinsert all effect from original SkillEffect
	for _, v in ipairs(origMove) do
		ret.effect:push_back(v)
	end
    
    return ret
end

------------
-- TipImage
------------
lmn_Minelayer_Mine_Tip = lmn_Minelayer_Mine:new{}
lmn_Minelayer_Mine_Tip_A = lmn_Minelayer_Mine_A:new{}

function lmn_Minelayer_Mine_Tip:GetTargetArea(point)
	return Board:GetReachable(point, Pawn:GetMoveSpeed(), Pawn:GetPathProf())
end

function lmn_Minelayer_Mine_Tip:GetSkillEffect(p1, p2)
	local ret = SkillEffect()

	local damage = SpaceDamage(p1)
	damage.sItem = "lmn_Minelayer_Item_Mine"
	damage.sImageMark = "combat/rf_mark_mine_small.png"
	ret:AddDamage(damage)

	if self.MineImmunity then
		damage = SpaceDamage(p2)
		damage.sItem = "lmn_Minelayer_Item_Mine"
		damage.sImageMark = "combat/rf_mine_small.png"
		Board:DamageSpace(damage)

		damage = SpaceDamage(p2)
		damage.sImageMark = "combat/icons/rf_icon_minesweeper_glow.png"
		ret:AddDamage(damage)
	end
	ret:AddMove(Board:GetPath(p1, p2, Pawn:GetPathProf()), FULL_DELAY)

	return ret
end

lmn_Minelayer_Mine_Tip_A.GetTargetArea = lmn_Minelayer_Mine_Tip.GetTargetArea
lmn_Minelayer_Mine_Tip_A.GetSkillEffect = lmn_Minelayer_Mine_Tip.GetSkillEffect

---------
-- items
---------

lmn_Minelayer_Item_Mine = { Image = "combat/rf_mine_small.png", Damage = SpaceDamage(0), Tooltip = "old_earth_mine", Icon = "combat/icons/icon_mine_glow.png", UsedImage = ""}
lmn_Minelayer_Item_Mine_Dummy = {} -- modified dynamically

modApi:addWeaponDrop("lmn_Minelayer_Mine")

local undoPawnId_thisFrame = nil

modapiext.events.onPawnUndoMove:subscribe(function(mission, pawn)
	undoPawnId_thisFrame = pawn:GetId()
end)

BoardEvents.onItemRemoved:subscribe(function(loc, removed_item)
	if removed_item == "lmn_Minelayer_Item_Mine"  then

		local pawn = Board:GetPawn(loc)

		if pawn then
			if pawn:GetId() == undoPawnId_thisFrame then
				-- do nothing
			elseif not HasMinesweeper(pawn) then
				local mine_damage = SpaceDamage(loc, 3)
				mine_damage.sSound = "/impact/generic/explosion"
				mine_damage.sAnimation = "ExploAir1"

				Board:DamageSpace(mine_damage)
			end
		end
	end
end)

-- modApiExt's events originates from onMissionUpdate
-- BoardEvents also originates from onMissionUpdate
-- We want the order to be:
-- onPawnUndoMove -> onItemRemoved -> reset undo pawn this frame
--
-- modApiExt subscribes to onMissionUpdate on modApiExt initialized
-- BoardEvents subscribes to onMissionUpdate after all mods have initialized
-- If we subscribe to onMissionUpdate after all mods have initialized as well
-- this will order it after BoardEvents.
modApi.events.onModsInitialized:subscribe(function()
	modApi.events.onMissionUpdate:subscribe(function(mission)
		undoPawnId_thisFrame = nil
	end)
end)

BoardEvents.onTerrainChanged:subscribe(function(p, terrain, terrain_prev)
	local item = Board:GetItem(p)
	if item == "lmn_Minelayer_Item_Mine" then
		if terrain == TERRAIN_HOLE or terrain == TERRAIN_WATER then
			Board:RemoveItem(p)
		end
	end
end)
