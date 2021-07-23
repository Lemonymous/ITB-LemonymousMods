
-- adds numbers 19 to 29 to the game
-- to allow for higher damage
-- and higher numbers of enemies
-- on the board without going out of bounds.

-- requires png files damage_19.png through damage.29.png

local path = mod_loader.mods[modApi.currentMod].scriptPath
local readPath = path .."damageNumbers/img/"

for n = 19, 29 do
	modApi:appendAsset("img/combat/icons/damage_".. n ..".png", readPath .. "damage_".. n ..".png")
end