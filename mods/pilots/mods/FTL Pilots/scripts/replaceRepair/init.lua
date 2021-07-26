
-- internal library, not meant for outside use.
local path = mod_loader.mods[modApi.currentMod].scriptPath
local skill_repair = require(path .."replaceRepair/skill_repair")
local skill_info = require(path .."replaceRepair/skill_info")
local selected = require(path .."replaceRepair/lib/selected")
local highlighted = require(path .."replaceRepair/lib/highlighted")
local uiIcon = require(path .."replaceRepair/uiIcon")
local compatibility = require(path .."replaceRepair/compatibility")
local menu = require(path .."replaceRepair/lib/menu")

local this = {
	version = "2.2.1",
}

lmn_replaceRepair = lmn_replaceRepair or {}
local m = lmn_replaceRepair
assert(not m.inited, "Replace Repair library has not been initialized.")

-- init highest version of library.
function this.internal_init()
	local m = lmn_replaceRepair
	
	assert(modApiExt_internal)
	assert(package.loadlib(path .."replaceRepair/lib/utils.dll", "luaopen_utils"))()
	
	if m.inited then return end
	m.inited = true
	
	skill_repair:Override()
	skill_info:Override()
	uiIcon.createui()
	compatibility()
end

-- finalize is called after all mods have initialized,
-- but before they have been loaded.
if not m.modApiFinalize then
	m.modApiFinalize = modApi.finalize
	function modApi.finalize(...)
		xpcall(lmn_replaceRepair.mostRecent.internal_init, function(e) LOG(e .. " Mods using Replace Repair requires to manually init and load modApiExt.") end)
		
		m.modApiFinalize(...)
	end
end

-- prepare init for highest version of library
if not m.version or not modApi:isVersion(this.version, m.version) then
	for i, v in pairs(this) do
		m[i] = v
	end
	
	m.swaps = m.swaps or {}
	m.mostRecent = this
end

-- repairApi:load() will call this for you.
function this:load()
	selected:load()
	highlighted:load()
	menu:load()
end

return this
