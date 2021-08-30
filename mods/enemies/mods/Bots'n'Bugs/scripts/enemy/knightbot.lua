
local mod = mod_loader.mods[modApi.currentMod]
local path = mod.resourcePath
local worldConstants = LApi.library:fetch("worldConstants")
local ID = mod.id .."_blobberlings"
local a = ANIMS
local writepath = "img/units/snowbots/"
local readpath = path .. writepath
local imagepath = writepath:sub(5,-1)
local this = {}

modApi:appendAsset(writepath .."snowknight1.png", readpath .."knightbot1.png")
modApi:appendAsset(writepath .."snowknight1a.png", readpath .."knightbot1a.png")
modApi:appendAsset(writepath .."snowknight1_off.png", readpath .."knightbot1_off.png")
modApi:appendAsset(writepath .."snowknight1_death.png", readpath .."knightbot1_death.png")

modApi:appendAsset(writepath .."snowknight2.png", readpath .."knightbot2.png")
modApi:appendAsset(writepath .."snowknight2a.png", readpath .."knightbot2a.png")
modApi:appendAsset(writepath .."snowknight2_off.png", readpath .."knightbot2_off.png")
modApi:appendAsset(writepath .."snowknight2_death.png", readpath .."knightbot2_death.png")

modApi:appendAsset("img/portraits/enemy/lmn_knightbot1.png", mod.resourcePath.. "img/portraits/enemy/knight1.png")
modApi:appendAsset("img/portraits/enemy/lmn_knightbot2.png", mod.resourcePath.. "img/portraits/enemy/knight2.png")

-- TODO: make weapon icon.
--modApi:appendAsset("img/weapons/lmn_knightbot.png", mod.resourcePath.. "img/weapons/weapon_knight.png")

local base = 			a.BaseUnit:new{Image = imagepath .."snowknight1.png", PosX = -19, PosY = -4}

a.lmn_knightbot1 =		base
a.lmn_knightbot1a =		base:new{ Image = imagepath .."snowknight1a.png", NumFrames = 4 }
a.lmn_knightbot1off =	base:new{ Image = imagepath .."snowknight1_off.png", PosX = -15, PosY = 0 }  -- (+4,+4)
a.lmn_knightbot1d =		base:new{ Image = imagepath .."snowknight1_death.png", PosX = -20, PosY = -7, NumFrames = 11, Time = 0.12, Loop = false } -- (-1,-3)

a.lmn_knightbot2 =		a.lmn_knightbot1:new{ Image = imagepath .."snowknight2.png" }
a.lmn_knightbot2a =		a.lmn_knightbot1a:new{ Image = imagepath .."snowknight2a.png" }
a.lmn_knightbot2off =	a.lmn_knightbot1off:new{ Image = imagepath .."snowknight2_off.png" }
a.lmn_knightbot2d =		a.lmn_knightbot1d:new{ Image = imagepath .."snowknight2_death.png" }

lmn_KnightBot1 = Pawn:new{
	Name = "Knight-Bot",
	Health = 1,
	MoveSpeed = 3,
	Image = "lmn_knightbot1",
	Portrait = "enemy/lmn_knightbot1",
	SkillList = { "lmn_KnightBotAtk1" },
	SoundLocation = "/enemy/snowlaser_1/",
	DefaultTeam = TEAM_ENEMY,
	DefaultFaction = FACTION_BOTS,
	ImpactMaterial = IMPACT_METAL,
	Armor = true,
}
AddPawnName("lmn_KnightBot1")

lmn_KnightBotAtk1 = Punch:new{
	Name = "0th KPR Sword Mark I",
	Description = "Dash two tiles to damage and push the target.",
	--Icon = "weapons/lmn_knightbot.png", -- TODO: make weapon icon.
	Class = "Enemy",
	Damage = 2,
	Range = 2,
	Push = true,
	TipImage = {
		Unit = Point(2,4),
		Target = Point(2,3),
		Enemy = Point(2,1),
		CustomPawn = "lmn_KnightBot1",
	}
}

function lmn_KnightBotAtk1:GetTargetScore(p1, p2)
	this.isTargetScore = true
	local ret = Skill.GetTargetScore(self, p1, p2)
	this.isTargetScore = false
	
	return ret
end

function lmn_KnightBotAtk1:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	
	local dir = GetDirection(p2 - p1)
	local vec = DIR_VECTORS[dir]
	local target -- the point we want to eventually charge to.
	
	for k = 1, self.Range + 1 do
		target = p1 + vec * k
		
		-- step one back if off the board.
		if not Board:IsValid(target) then
			target = target - vec
			break
		end
		
		-- stop when blocked, even by water/hole.
		if Board:IsBlocked(target, PATH_GROUND) then
			break
		end
	end
	
	local distance = p1:Manhattan(target)
	local doDamage = Board:IsBlocked(target, PATH_FLYER)
	
	-- step one back if target is blocked or beyond range.
	if doDamage or distance > self.Range then
		target = target - vec
	end
	
	if this.isTargetScore then
		-- only score if not water/hole.
		if doDamage then
			-- score attack damage
			ret:AddQueuedDamage(SpaceDamage(target + vec, 1))
			
			-- score push damage
			local pawn = Board:GetPawn(target + vec)
			if pawn and not pawn:IsGuarding() then
				ret:AddQueuedDamage(SpaceDamage(target + vec * 2, 1))
			end
		end
	else

		local s = SoundEffect(target, "/enemy/snowlaser_1/move")
		s.bHide = true
		ret:AddQueuedDamage(s)
		
		local newSpeed = 1.0
		worldConstants:queuedSetSpeed(ret, newSpeed)
		ret:AddQueuedCharge(Board:GetSimplePath(p1, target), NO_DELAY)
		worldConstants:queuedResetSpeed(ret)
		
		local distance = p1:Manhattan(target)
		ret:AddQueuedDelay(distance * 0.07 * worldConstants:getDefaultSpeed() / newSpeed - 0.1)
		
		if doDamage then
			local d = SpaceDamage(target + vec)
			d.sAnimation = "explosword_".. dir
			d.sSound = "/weapons/sword"
			ret:AddQueuedDamage(d)
			ret:AddQueuedDelay(0.1)
			ret:AddQueuedMelee(target, SpaceDamage(target + vec, self.Damage, self.Push and dir or DIR_NONE), NO_DELAY)
		end
	end
	
	return ret
end

lmn_KnightBot2 = lmn_KnightBot1:new{
	Name = "Knight-Mech",
	Image = "lmn_knightbot2",
	Portrait = "enemy/lmn_knightbot2",
	SkillList = { "lmn_KnightBotAtk2" },
	SoundLocation = "/enemy/snowlaser_2/",
	Tier = TIER_ALPHA,
}
AddPawnName("lmn_KnightBot2")

lmn_KnightBotAtk2 = lmn_KnightBotAtk1:new{
	Name = "0th KPR Sword Mark II",
	Damage = 4,
	TipImage = {
		Unit = Point(2,4),
		Target = Point(2,3),
		Enemy = Point(2,1),
		CustomPawn = "lmn_KnightBot2",
	}
}

function this:load()
end

return this