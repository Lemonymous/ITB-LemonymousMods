--using modApiExt

local this = {
	modApiExt,
	pawnTypes = {}
}
Location["combat/icons/icon_aggro.png"] = Point(0,8)
--Location["combat/icons/icon_aggro_glow.png"] = Point(0,8)

local oldGetStatusTooltip = GetStatusTooltip
function GetStatusTooltip(id)
	if id == "aggro" then
		return {"Counter Attack", "If this unit survives damage, it will turn it's attack towards the attacker."}
	end
	return oldGetStatusTooltip(id)
end

local function IsRetaliatory(pawn)
	return this.pawnTypes[pawn:GetType()]
end

local function SetIcon(point, flag)
	Board:SetTerrainIcon(point, flag and "aggro" or "")
end

-- returns true if Board is in tipImage.
-- fails if the game board is also 6x6.
local function InTipImage()
	return Board:GetSize() == Point(6, 6)
end

local function onPawnPositionChanged(mission, pawn, oldPosition)
	if not IsRetaliatory(pawn) then
		return
	end
	
	local id = pawn:GetId()
	local loc = pawn:GetSpace()
	
	GAME.lmn_Retaliatory = GAME.lmn_Retaliatory or {}
	GAME.lmn_Retaliatory[id] = GAME.lmn_Retaliatory[id] or {}
	GAME.lmn_Retaliatory[id].loc = loc
	
	if oldPosition then SetIcon(oldPosition, false) end
	SetIcon(loc, true)
	
	local hasSeenTip = modApi:readProfileData("lmn_Retaliatory")
	if not hasSeenTip then
		local type = pawn:GetType()
		if _G[type].Burrows then
			Global_Texts.lmn_Retaliatory_Text = "When the ".. pawn:GetMechName() .." survives damage, it won't burrow and hide;\nbut rather turn it's attack towards the attacker."
		else
			Global_Texts.lmn_Retaliatory_Text = "When the ".. pawn:GetMechName() .." survives damage, it will turn it's attack towards the attacker."
		end
		Global_Texts.lmn_Retaliatory_Title = "Counter Attack"
		Game:AddTip("lmn_Retaliatory", loc)
		modApi:writeProfileData("lmn_Retaliatory", true)
	end
end

local function onMissionUpdate(mission)
	local rem = {}
	
	GAME.lmn_Retaliatory = GAME.lmn_Retaliatory or {}
	for id, t in pairs(GAME.lmn_Retaliatory) do
		local pawn = Board:GetPawn(id)
		if
			not pawn      or
			pawn:IsDead()
		then
			table.insert(rem, id)
		elseif
			Board:GetBusyState() == 0 and
			not pawn:IsBusy()
		then
			local pawnLoc = pawn:GetSpace()
			local target = t.targetId and Board:GetPawn(t.targetId) or nil
			if target then
				local targetLoc = target:GetSpace()
				t.targetLoc = pawnLoc ~= targetLoc and targetLoc or t.targetLoc
			end
			if t.targetLoc then
				local dir = GetDirection(t.targetLoc - pawnLoc)
				pawn:FireWeapon(pawnLoc + DIR_VECTORS[dir], 1)
			end
			t.targetId = nil
			t.targetLoc = nil
		end
	end
	
	for _, id in ipairs(rem) do
		SetIcon(GAME.lmn_Retaliatory[id].loc, false)
		GAME.lmn_Retaliatory[id] = nil
	end
end

local function onMissionLoad(mission)
	if not Board then return end
	
	GAME.lmn_Retaliatory = GAME.lmn_Retaliatory or {}
	for id, t in pairs(GAME.lmn_Retaliatory) do
		SetIcon(t.loc, true)
	end
end

local fx = {"effect", "q_effect"}

local function onSkillEffect(mission, pawn, weaponId, p1, p2, skillEffect)
	if InTipImage() then
		return
	end
	
	GAME.lmn_Retaliatory = GAME.lmn_Retaliatory or {}
	
	local modify ={
		effect = false,
		q_effect = false,
	}
	local mod = SkillEffect()
	for _, fx in pairs(fx) do
		for _, spaceDamage in ipairs(extract_table(skillEffect[fx])) do
			mod[fx]:push_back(spaceDamage)
			if	spaceDamage.iDamage > 0							and
				Board:IsPawnSpace(spaceDamage.loc)				and
				IsRetaliatory(Board:GetPawn(spaceDamage.loc))	and
				(fx == "effect"									or
				isEnemy(pawn:GetTeam(),
				Board:GetPawn(spaceDamage.loc):GetTeam()))		then
				
				local target = Board:GetPawn(spaceDamage.loc)
				local addScript = fx == "effect" and "AddScript" or "AddQueuedScript"
				local targetId = target:GetId()
				local attackerId = pawn:GetId()
				local attackerLoc = pawn:GetSpace()
				local x = attackerLoc.x
				local y = attackerLoc.y
				
				mod[addScript](mod,
				[[
					local id = ]].. targetId ..[[;
					GAME.lmn_Retaliatory[id].targetLoc = Point(]].. x ..",".. y ..[[);
					GAME.lmn_Retaliatory[id].targetId = ]].. attackerId ..[[;
				]])
				modify[fx] = true
				
			elseif	spaceDamage.iPush >= DIR_START		and
					spaceDamage.iPush <= DIR_END		and
					Board:IsPawnSpace(spaceDamage.loc)	then
				
				local attacker = Board:GetPawn(spaceDamage.loc)
				local target = Board:GetPawn(spaceDamage.loc + DIR_VECTORS[spaceDamage.iPush])
				
				if	target						and
					IsRetaliatory(target)		and
					(fx == "effect"				or
					isEnemy(attacker:GetTeam(),
					target:GetTeam()))			then
					
					local addScript = fx == "effect" and "AddScript" or "AddQueuedScript"
					local targetId = target:GetId()
					local attackerId = attacker:GetId()
					local x = spaceDamage.loc.x
					local y = spaceDamage.loc.y
					
					mod[addScript](mod,
					[[
						local id = ]].. targetId ..[[;
						GAME.lmn_Retaliatory[id].targetLoc = Point(]].. x ..",".. y ..[[);
						GAME.lmn_Retaliatory[id].targetId = ]].. attackerId ..[[;
					]])
					modify[fx] = true
				end
			end
		end
	end
	
	skillEffect.effect = modify.effect and mod.effect or skillEffect.effect
	skillEffect.q_effect = modify.q_effect and mod.q_effect or skillEffect.q_effect
end

function this:init(mod)
	modApi:appendAsset("img/combat/icons/icon_aggro.png",mod.resourcePath.."img/combat/icons/icon_aggro.png")
	modApi:appendAsset("img/combat/icons/icon_aggro_glow.png",mod.resourcePath.."img/combat/icons/icon_aggro_glow.png")
	
	sdlext.addGameExitedHook(function()
		self.lastSelected = nil
	end)
end

function this:load(modApiExt)
	self.modApiExt = modApiExt
	modApiExt:addSkillBuildHook(onSkillEffect)
	modApiExt:addPawnTrackedHook(onPawnPositionChanged)
	modApiExt:addPawnPositionChangedHook(onPawnPositionChanged)
	modApiExt:addGameLoadedHook(onMissionLoad)
	modApiExt:addResetTurnHook(onMissionLoad)
	modApi:addMissionUpdateHook(onMissionUpdate)
	
	modApiExt:addPawnDamagedHook(function(_, pawn, damage)
		if
			IsRetaliatory(pawn) and
			not pawn:IsDead()
		then
			local id = pawn:GetId()
			GAME.lmn_Retaliatory = GAME.lmn_Retaliatory or {}
			GAME.lmn_Retaliatory[id] = GAME.lmn_Retaliatory[id] or {}
			
			if
				not GAME.lmn_Retaliatory[id].targetLoc and
				not GAME.lmn_Retaliatory[id].targetId  and
				self.lastSelected
			then
				GAME.lmn_Retaliatory[id].targetId = self.lastSelected:GetId()
			end
		end
	end)
	
	modApiExt:addPawnSelectedHook(function(_, pawn) self.lastSelected = pawn end)
end

function this:ResetTips()
	modApi:writeProfileData("lmn_Retaliatory", false)
end

function this:AddPawnType(pawnType)
	self.pawnTypes[pawnType] = true
end

return this