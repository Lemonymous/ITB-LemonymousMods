
local path = mod_loader.mods[modApi.currentMod].resourcePath
local achvApi = require(path .."scripts/achievements/api")
local utils = require(path .."scripts/utils")

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

achvApi:AddChievo{
	id = "springseed",
	name = "Into the Drink",
	tip = "Have 3 Springseeds jump to their doom in a single battle.",
	img = "img/achievements/lmn_springseed.png",
}

achvApi:AddChievo{
	id = "sprout",
	name = "Garden Weeds",
	tip = "Kill 100 Sprouts across all games.\n\nProgress: $progress",
	img = "img/achievements/lmn_sprouts.png",
	objective = {
		progress = 100,
	}
}

achvApi:AddChievo{
	id = "chili",
	name = "Roasted Veggies",
	tip = "Have a Chili set fire to a Plant Leader.",
	img = "img/achievements/lmn_chili.png",
}

achvApi:AddChievo{
	id = "cactus",
	name = "Stay Down!",
	tip = "Block all Cactuses from emerging during a mission.",
	img = "img/achievements/lmn_cactus.png",
}

achvApi:AddChievo{
	id = "bossfight",
	name = "Boss Fight",
	tip = "Have one Vek Leader kill another.",
	img = "img/achievements/lmn_bossfight.png",
}

achvApi:AddChievo{
	id = "flytrap",
	name = "Flytrap",
	tip = "Have a Chomper kill a Hornet.",
	img = "img/achievements/lmn_flytrap.png",
}

achvApi:AddChievo{
	id = "sunflower",
	name = "Multi Kill",
	tip = "Have a Sunflower kill two friends with one attack.",
	img = "img/achievements/lmn_sunflower.png",
}

achvApi:AddChievo{
	id = "leaders",
	name = "Plant Hunt",
	img = "img/achievements/lmn_leaders.png",
	tip = "Kill every Plant Leader.\n\nChili: $chili\nChomper: $chomper\nSpringseed: $springseed\nSunflower: $sunflower\nSequoia: $sequoia\n\nReward: $reward",
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