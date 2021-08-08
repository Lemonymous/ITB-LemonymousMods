
---------------------------------------------------
-- Shop v2.0 - helper functions
--
-- by Lemonymous
---------------------------------------------------
-- provides functions for adding weapons to shop,
-- set custom rarity to weapons,
-- and make them toggleable in mod configuration.
---------------------------------------------------

local shop = {
	weapons_enabled = {},
	mods = {},
}

local oldInitializeDecks = initializeDecks
function initializeDecks(...)
	oldInitializeDecks(...)

	for _, weapon in ipairs(shop.weapons_enabled) do
		table.insert(GAME.WeaponDeck, weapon)
	end
end

function shop:addWeapon(weapon)
	Assert.ModInitializingOrLoading()
	Assert.Equals('table', type(weapon), "Argument #1")
	Assert.Equals('string', type(weapon.id))
	Assert.NotEquals('nil', type(_G[weapon.id]))

	weapon.opt = "opt_".. weapon.id
	weapon.name = weapon.name or _G[weapon.id].Name or ""
	weapon.desc = weapon.desc or _G[weapon.id].Description or ""
	weapon.default = weapon.default or {enabled = true}

	modApi:addGenerationOption(
		weapon.opt,
		weapon.name,
		weapon.desc,
		weapon.default
	)

	local mod_id = modApi.currentMod
	local weapons = self.mods[mod_id]

	if weapons == nil then
		weapons = {}
		self.mods[mod_id] = weapons
	end

	weapons[weapon.opt] = weapon
end

local function onModsLoaded()
	local mod_options = mod_loader.mod_options
	for mod_id, weapons in pairs(shop.mods) do
		local options = mod_options[mod_id].options
		for _, option in ipairs(options) do
			local weapon = weapons[option.id]
			if weapon then
				if option.enabled then
					if not list_contains(shop.weapons_enabled, weapon.id) then
						table.insert(shop.weapons_enabled, weapon.id)
					end
				else
					remove_element(weapon.id, shop.weapons_enabled)
				end
			end
		end
	end
end

modApi.events.onModsLoaded:subscribe(onModsLoaded)

return shop
