
local path = mod_loader.mods[modApi.currentMod].resourcePath
local utils = require(path .."scripts/libs/utils")

local imgs = {
	"springseed",
	"sprouts",
	"cactus",
	"chili",
	"bossfight",
	"flytrap",
	"leaders",
	"leaders2",
	"sunflower",
}

for _, img in ipairs(imgs) do
	modApi:appendAsset("img/achievements/lmn_".. img ..".png", path .."img/achievements/".. img ..".png")
	modApi:appendAsset("img/achievements/lmn_".. img .."_gray.png", path .."img/achievements/".. img .."_gray.png")
end

modApi.achievements:add{
	id = "springseed",
	name = "Into the Drink",
	tooltip = "Have 3 Springseeds jump to their doom in a single battle.",
	image = "img/achievements/lmn_springseed.png",
}

modApi.achievements:add{
	id = "sprout",
	name = "Garden Weeds",
	tooltip = "Kill 100 Sprouts across all games.\n\nProgress: $progress",
	image = "img/achievements/lmn_sprouts.png",
	objective = {
		progress = 100,
	}
}

modApi.achievements:add{
	id = "chili",
	name = "Roasted Veggies",
	tooltip = "Have a Chili set fire to a Plant Leader.",
	image = "img/achievements/lmn_chili.png",
}

modApi.achievements:add{
	id = "cactus",
	name = "Stay Down!",
	tooltip = "Block all Cactuses from emerging during a mission.",
	image = "img/achievements/lmn_cactus.png",
}

modApi.achievements:add{
	id = "bossfight",
	name = "Boss Fight",
	tooltip = "Have one Vek Leader kill another.",
	image = "img/achievements/lmn_bossfight.png",
}

modApi.achievements:add{
	id = "flytrap",
	name = "Flytrap",
	tooltip = "Have a Chomper kill a Hornet.",
	image = "img/achievements/lmn_flytrap.png",
}

modApi.achievements:add{
	id = "sunflower",
	name = "Multi Kill",
	tooltip = "Have a Sunflower kill two friends with one attack.",
	image = "img/achievements/lmn_sunflower.png",
}

modApi.achievements:add{
	id = "leaders",
	name = "Plant Hunt",
	image = "img/achievements/lmn_leaders.png",
	tooltip = "Kill every Plant Leader.\n\nChili: $chili\nChomper: $chomper\nSpringseed: $springseed\nSunflower: $sunflower\nSequoia: $sequoia\n\nReward: $reward",
	objective = {
		chili = true,
		chomper = true,
		springseed = true,
		sunflower = true,
		sequoia = true,
		reward = "?|Secret Plants"
	}
	--[[tip = "Kill every Plant Leader.\n\nProgress:$chili$chomper$springseed$sunflower$sequoia",
	objective = {
		chili = "\nChili",
		chomper = "\nChomper",
		springseed = "\nSpringseed",
		sunflower = "\nSunflower",
		sequoia = "\nSequoia"
	}]]
}