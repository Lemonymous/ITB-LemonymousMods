
local mod =  {
	id = "lmn_mods",
	name = "Lemonymous' Mods",
	version = "0.4.0",
	modApiVersion = "2.6.0",
	icon = "scripts/icon.png",
	description = "A Collection of mods made by Lemonymous",
	submodFolders = {"mods/"}
}

function mod:metadata()
end

function mod:init(options)
	require(self.scriptPath.."LApi/LApi")
	LApi.library:fetch("ITB-ModUtils/modApiExt/modApiExt"):init()
	LApi.library:fetch("modloaderfixes")
	LApi.library:fetch("artilleryArc")
end

function mod:load(options, version)
	LApi.library:fetch("ITB-ModUtils/modApiExt/modApiExt"):load(
		options,
		version
	)
end

return mod
