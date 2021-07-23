
local path = mod_loader.mods[modApi.currentMod].resourcePath
local achvApi = require(path .."scripts/achievements/api")

local bosses = {
	"swarmer",
	"roach",
	"spitter",
	"wyrm",
	"crusher"
}

local chievo_writepath = "img/achievements/lmn_"
local toast_writepath = "img/achievements/toasts/lmn_"
local chievo_readpath = path .. "img/achievements/"
local toast_readpath = path .. "img/achievements/toasts/"

for _, boss in ipairs(bosses) do
	local Boss = boss:gsub("^.", string.upper) -- capitalize first letter
	
	modApi:appendAsset(
		chievo_writepath .. boss ..".png",
		chievo_readpath .. boss ..".png"
	)
	modApi:appendAsset(
		chievo_writepath .. boss .."_gray.png",
		chievo_readpath .. boss .."_gray.png"
	)
	modApi:appendAsset(
		toast_writepath .. boss ..".png",
		toast_readpath .. boss ..".png"
	)
	
	achvApi:AddChievo{
		id = boss,
		name = Boss ..' Leader',
		tip = 'Destroy the '.. Boss ..' Leader\n\nReward: '.. Boss ..' Mech\nin Random Squad.\nAvailable in Custom Squad if Secret Squad is unlocked',
		img = 'img/achievements/lmn_'.. boss ..'.png',
	}
end

local swarmer = achvApi:GetChievo("swarmer")
swarmer.name = 'Swarmer Leaders'
swarmer.tip = 'Destroy the Swarmer Leaders\n\nReward: Swarmer Mech in Random Squad.\nAvailable in Custom Squad if Secret Squad is unlocked'
