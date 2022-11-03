
local mod =  {
	id = "lmn_mods",
	name = "Lemonymous' Mods",
	version = "0.8.5",
	modApiVersion = "2.7.3dev",
	gameVersion = "1.2.78",
	icon = "scripts/icon.png",
	description = "A Collection of mods made by Lemonymous",
	submodFolders = {"mods/"},
	dependencies = {"memedit", "easyedit"}
}

local libs = {
	"achievementExt",
	"artilleryArc",
	"astar",
	"attackEvents",
	"blockDeathByDeployment",
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

function mod:metadata()
end

function mod:init(options)
	local path = self.scriptPath

	self.libs = {}
	self.libs.modApiExt = require(path.."ITB-ModUtils/modApiExt/modApiExt"):init()

	for _, libId in ipairs(libs) do
		self.libs[libId] = require(path.."libs/"..libId)
	end
end

function mod:load(options, version)
	self.libs.modApiExt:load(options, version)
end

return mod
