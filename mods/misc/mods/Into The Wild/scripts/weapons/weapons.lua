
local path = mod_loader.mods[modApi.currentMod].scriptPath
local this = {}

local img = "weapons/lmn_PufferAtk.png"
lmn_Spore_Cannon = lmn_PufferAtk:new{ Icon = img, Class = "Brute", CustomTipImage = "lmn_Spore_Cannon_Tip" }
lmn_Spore_Cannon_A = lmn_PufferAtk_A:new{ Icon = img, Class = "Brute", CustomTipImage = "lmn_Spore_Cannon_Tip_A" }
lmn_Spore_Cannon_B = lmn_PufferAtk_B:new{ Icon = img, Class = "Brute", CustomTipImage = "lmn_Spore_Cannon_Tip_B" }
lmn_Spore_Cannon_AB = lmn_PufferAtk_AB:new{ Icon = img, Class = "Brute", CustomTipImage = "lmn_Spore_Cannon_Tip_AB" }
lmn_Spore_Cannon_Tip = lmn_PufferAtk_Tip:new{ Icon = img, Class = "Brute", TipImage = shallow_copy(lmn_PufferAtk_Tip.TipImage) }
lmn_Spore_Cannon_Tip_A = lmn_PufferAtk_Tip_A:new{ Icon = img, Class = "Brute", TipImage = shallow_copy(lmn_PufferAtk_Tip_A.TipImage) }
lmn_Spore_Cannon_Tip_B = lmn_PufferAtk_Tip_B:new{ Icon = img, Class = "Brute", TipImage = shallow_copy(lmn_PufferAtk_Tip_B.TipImage) }
lmn_Spore_Cannon_Tip_AB = lmn_PufferAtk_Tip_AB:new{ Icon = img, Class = "Brute", TipImage = shallow_copy(lmn_PufferAtk_Tip_AB.TipImage) }
lmn_Spore_Cannon_Tip.TipImage.CustomPawn = nil
lmn_Spore_Cannon_Tip_A.TipImage.CustomPawn = nil
lmn_Spore_Cannon_Tip_B.TipImage.CustomPawn = nil
lmn_Spore_Cannon_Tip_AB.TipImage.CustomPawn = nil

local img = "weapons/lmn_ChomperAtk.png"
lmn_Iron_Jaws = lmn_ChomperAtk:new{ Icon = img, Class = "Prime", TipImage = shallow_copy(lmn_ChomperAtk.TipImage) }
lmn_Iron_Jaws_A = lmn_ChomperAtk_A:new{ Icon = img, Class = "Prime", TipImage = shallow_copy(lmn_ChomperAtk_A.TipImage) }
lmn_Iron_Jaws_B = lmn_ChomperAtk_B:new{ Icon = img, Class = "Prime", TipImage = shallow_copy(lmn_ChomperAtk_B.TipImage) }
lmn_Iron_Jaws_AB = lmn_ChomperAtk_AB:new{ Icon = img, Class = "Prime", TipImage = shallow_copy(lmn_ChomperAtk_AB.TipImage) }
lmn_Iron_Jaws.TipImage.CustomPawn = nil
lmn_Iron_Jaws_A.TipImage.CustomPawn = nil
lmn_Iron_Jaws_B.TipImage.CustomPawn = nil
lmn_Iron_Jaws_AB.TipImage.CustomPawn = nil

require(path .."weapons/deploy_copter")
require(path .."weapons/bioscanner")
require(path .."weapons/confusion_strike")
require(path .."weapons/deflector_ray")
require(path .."weapons/flood_generator")
--require(path .."weapons/deploy_sprout")
--require(path .."weapons/acid_shielding")
--require(path .."weapons/particle_cannon")
--require(path .."weapons/psi_transmitter")
--require(path .."weapons/repeater_cannon")

local oldInitializeDecks = initializeDecks
function initializeDecks(...)
	oldInitializeDecks(...)
	
	for _, weapon in ipairs(this.weapons or {}) do
		table.insert(GAME.WeaponDeck, weapon)
	end
end

function this:Add()
	this.weapons = {
		"lmn_Spore_Cannon",
		"lmn_Iron_Jaws",
		"lmn_DeploySkill_Copter",
		"lmn_Bioscanner",
		"lmn_Confusion_Strike",
		"lmn_Deflector_Ray",
		"lmn_Flood_Generator",
		--"lmn_DeploySkill_Sprout",	-- a lot of work with evolve, and no fun without. cut
		--"lmn_Acid_Shielding",		-- no acid science on island. cut
		--"lmn_Particle_Cannon",	-- cool icon, so it would be nice to get this going. However, there is no explicit particle science on the island, so might as well cut
		--"lmn_Psi_Transmitter",	-- requires some more thought to make it either compatible with hi-tech weapons, override it, or decomission that mod. none are desireable. cut?
		--"lmn_Repeater_Cannon",	-- need a new twist if I am going to make another multishot weapon. cut?
	}
end

return this