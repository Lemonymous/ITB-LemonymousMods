
local mod =  {
	id = "lmn_mods",
	name = "Lemonymous' Mods",
	version = "1.0.3",
	modApiVersion = "2.8.3",
	gameVersion = "1.2.83",
	icon = "scripts/icon.png",
	description = "A Collection of mods made by Lemonymous",
	submodFolders = {"mods/"},
	dependencies = {
		modApiExt = "1.2",
		memedit = "0.1.0",
		easyEdit = "2.0.0",
	}
}

local libs = {
	"achievementExt",
	"artilleryArc",
	"astar",
	"attackEvents",
	"blockDeathByDeployment",
	"boardEvents",
	"effectBurst",
	"effectPreview",
	"globals",
	"personalSavedata",
	"switch",
	"trait",
	"tutorialTips",
	"weaponArmed",
	"weaponPreview",
	"worldConstants",
}

-- option = {id, title, text, default}
local option_resetTips = {
	"resetTips",
	"Reset Tips",
	"Reset Tutorial Tips",
	{enabled = false}
}

function mod:metadata()
	modApi:addGenerationOption(unpack(option_resetTips))
end

function mod:init(options)
	local path = self.scriptPath

	self.libs = {}
	for _, libId in ipairs(libs) do
		self.libs[libId] = require(path.."libs/"..libId)
	end

	self.libs.modApiExt = modapiext
	self.libs.replaceRepair = require(path.."replaceRepair/replaceRepair")
end

function mod:load(options, version)
	if options.resetTips.enabled then
		self.libs.tutorialTips:resetAll()
		options.resetTips.enabled = false
	end
end

return mod
