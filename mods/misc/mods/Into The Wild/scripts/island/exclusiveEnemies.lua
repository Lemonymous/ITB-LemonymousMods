
local function makeExclusive(id1, id2)
	for _, list in ipairs(exclusiveElements) do
		for _, enemy in ipairs(list) do
			if enemy == id1 then
				table.insert(list, id2)
				break
			elseif enemy == id2 then
				table.insert(list, id1)
				break
			end
		end
	end

	table.insert(exclusiveElements, {id1, id2})
end

--Currently not enough different enemy types to warrant exclusion code.
--makeExclusive("lmn_Sprout", "lmn_Chomper")			-- limit slow melee.
--makeExclusive("lmn_Bud", "lmn_Puffer")				-- limit number of stable enemies.
--makeExclusive("lmn_Springseed", "lmn_Puffer")			-- limit number of very fast enemies.

makeExclusive("lmn_Puffer", "Jelly_Explode")
makeExclusive("lmn_Infuser", "lmn_Beanstalker")
