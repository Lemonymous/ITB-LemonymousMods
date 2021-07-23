
local path = mod_loader.mods[modApi.currentMod].resourcePath
local uiChievos = require(path .."scripts/achievements/uiChievos")
local toast = require(path .."scripts/achievements/toast")
local this = {
	version = "0.1.1",
	texts = {
		Button = "Achievements",
		ButtonTooltip = "Browse available achievements added by mods",
		FrameTitle = "Achievements"
	}
}

lmn_achievements = lmn_achievements or {} -- internal global
local m = lmn_achievements
assert(not m.inited, "Achievement library has not been initialized.")

-- init highest version of library.
function this:internal_init()
	local m = lmn_achievements
	
	if m.inited then return end
	m.inited = true
	m.toasts = { pending = {} }
	
	sdlext.addModContent(
		m.texts.Button,
		uiChievos,
		m.texts.ButtonTooltip
	)
	
	sdlext.addFrameDrawnHook(function(screen)
		toast:Update(screen)
	end)
	
	modApi:appendAsset("img/ui/lmn_trash.png", path .."scripts/achievements/img/trash.png")
	modApi:appendAsset("img/ui/lmn_undo.png", path .."scripts/achievements/img/undo.png")
	modApi:appendAsset("img/ui/lmn_chievo_shadowl.png", path .."scripts/achievements/img/shadowl.png")
	modApi:appendAsset("img/ui/lmn_chievo_shadowc.png", path .."scripts/achievements/img/shadowc.png")
	modApi:appendAsset("img/ui/lmn_chievo_shadowr.png", path .."scripts/achievements/img/shadowr.png")
end

if not m.modApiFinalize then
	m.modApiFinalize = modApi.finalize
	function modApi.finalize(...)
		lmn_achievements.mostRecent:internal_init()
		
		m.modApiFinalize(...)
	end
end

-- prepare init for highest version of library
if not m.version or not modApi:isVersion(this.version, m.version) then
	for i, v in pairs(this) do
		m[i] = v
	end
	
	m.chievos = m.chievos or {}
	m.mostRecent = this
end

-------- forced init regardless if highest version or not -----------------


---------------------- end of forced init ---------------------------------

return this