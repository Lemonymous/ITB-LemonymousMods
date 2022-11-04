
local mod = mod_loader.mods[modApi.currentMod]
local path = mod.scriptPath
local tips = mod.libs.tutorialTips

tips:Add{
	id = "Garden",
	title = "Vines",
	text = "Garden Psion plants and spreads Vines which damages your units, and heals the Vek."
}

tips:Add{
	id = "Vines",
	title = "Vines",
	text = "Vines does not spread to blocked (non-Vek) tiles, and they cannot damage Fire Immune units."
}

tips:Add{
	id = "VinesOnFire",
	title = "Burning Vines",
	text = "Vines light on fire when damaged."
}

tips:Add{
	id = "Blobberling",
	title = "Volatile",
	text = "Blobberlings will always explode when killed; and counts as a minor unit for spawning purposes, like spiderlings."
}

tips:Add{
	id = "Blobberling_Atk",
	title = "Volatile",
	text = "This Blobberling will explode even if killed. Push it somewhere safe, or use smoke on it to cancel its attack!"
}

tips:Add{
	id = "Roach_Boss_Atk",
	title = "Ranged Roach",
	text = "This attack has a range of 2. If the target in front of it relocates, the target behind may be in danger."
}

tips:Add{
	id = "Wyrm_Atk",
	title = "Wyrm's Dynamic Attack",
	text = "This attack bounces to adjacent objects, favoring units over buildings.\n\nMove a unit nearby to see how the attack changes."
}

tips:Add{
	id = "Spitter_Atk",
	title = "Spitter's Dynamic Attack",
	text = "This attack is much more dangerous in melee.\n\nMove a unit in front of it to see how the damage changes."
}

tips:Add{
	id = "Crusher",
	title = "Massive Crusher",
	text = "The Crusher is so massive, it won't drown when pushed into water like other Vek."
}

tips:Add{
	id = "Swarmer",
	title = "Swarmer",
	text = "Swarmers always spawn in pairs if possible; each counting as half a unit for spawning purposes."
}

tips:Add{
	id = "Swarmer_Webbed",
	title = "Webbed Swarmer",
	text = "Using the Swarm attack now will produce no additional swarmers, because they are webbed as well."
}

tips:Add{
	id = "Swarmer_Frozen",
	title = "Frozen Swarmer",
	text = "A Swarmer was frozen before it could carry out its attack."
}

tips:Add{
	id = "Swarmer_Dead",
	title = "Dead Swarmer",
	text = "A Swarmer was killed before it could carry out its attack."
}

tips:Add{
	id = "Creep",
	title = "Creep",
	text = "This tile effect does no harm in itself. Colonies can only attack through creep."
}

tips:Add{
	id = "Creep_Death",
	title = "Receding Creep",
	text = "When a colony dies, its creep dies with it unless supported by another colony."
}

tips:Add{
	id = "Colony_Atk",
	title = "Colony Impaler",
	text = "Colonies change their targets dynamically. They will always target Mechs before buildings.\n\nMove a unit on creep to see how the attack changes."
}
