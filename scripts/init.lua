
-- initialize easyEdit
local function scriptPath()
	return debug.getinfo(2, "S").source:sub(2):match("(.*[/\\])")
end
require(scriptPath().."easyEdit/easyEdit")


-- initialize modpack
local mod =  {
	id = "lmn_mods",
	name = "Lemonymous' Mods",
	version = "0.8.0",
	modApiVersion = "2.7.0",
	gameVersion = "1.2.75",
	icon = "scripts/icon.png",
	description = "A Collection of mods made by Lemonymous",
	submodFolders = {"mods/"}
}

function mod:metadata()
end

function mod:init(options)
	require(self.scriptPath.."LApi/LApi")
	require(self.scriptPath.."ITB-ModUtils/modApiExt/modApiExt"):init()
	require(self.scriptPath.."libs/eventifyModApiExtHooks")
	require(self.scriptPath.."libs/modloaderfixes")
	require(self.scriptPath.."libs/artilleryArc")
	require(self.scriptPath.."libs/detectDeployment")
	require(self.scriptPath.."libs/blockDeathByDeployment")
	require(self.scriptPath.."libs/squadEvents")
	require(self.scriptPath.."libs/attackEvents")
	require(self.scriptPath.."libs/difficultyEvents")
	require(self.scriptPath.."libs/personalSavedata")
	require(self.scriptPath.."libs/achievementExt")
end

function mod:load(options, version)
	require(self.scriptPath.."ITB-ModUtils/modApiExt/modApiExt"):load(options, version)
end

return mod
