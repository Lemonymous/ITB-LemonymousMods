
---------------------------------------------------
-- Shop - helper functions
---------------------------------------------------
-- provides functions for adding weapons to shop,
-- set custom rarity to weapons,
-- and make them toggleable in mod configuration.
---------------------------------------------------

local this = {
	weapons = {},
	weapons_enabled = {},
}

local oldInitializeDecks = initializeDecks
function initializeDecks(...)
	oldInitializeDecks(...)
	
	for _, weapon in ipairs(this.weapons_enabled) do
		table.insert(GAME.WeaponDeck, weapon)
	end
end

function this:addWeapon(weapon)
	assert(type(weapon) == 'table')
	assert(type(weapon.id) == 'string')
	assert(_G[weapon.id])
	
	weapon.opt = "opt_".. weapon.id
	weapon.name = weapon.name or _G[weapon.id].Name or ""
	weapon.desc = weapon.desc or _G[weapon.id].Description or ""
	weapon.default = weapon.default or {enabled = true}
	
	table.insert(self.weapons, weapon)
	modApi:addGenerationOption(
		weapon.opt,
		weapon.name,
		weapon.desc,
		weapon.default
	)
end

function this:load(options)
	for _, weapon in ipairs(self.weapons) do
		if options[weapon.opt].enabled then
			if not list_contains(self.weapons_enabled, weapon.id) then
				table.insert(self.weapons_enabled, weapon.id)
			end
		else
			remove_element(weapon.id, self.weapons_enabled)
		end
	end
end

return this