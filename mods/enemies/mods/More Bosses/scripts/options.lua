
local bosses = {
	"Blobber",
	"Burrower",
	"Centipede",
	"Crab",
	"Digger",
	"Leaper",
	"Scarab",
}

local function add_element(item, list)
	if not list_contains(list, item) then
		list[#list + 1] = item
	end
end

local function initializeOptions()
	local options = {
		{
			id = "final",
			name = "Final Island",
			desc = "Adds all enabled bosses as possible final island bosses",
			enabled = false
		}
	}

	for _, boss in ipairs(bosses) do
		options[#options + 1] = {
			id = boss,
			name = boss,
			desc = string.format("Adds %s Leader as a possible island boss", boss),
			enabled = true,
		}
	end

	stablesort(
		options,
		function(a, b)
			return alphanum(a.id, b.id)
		end
	)

	for _, option in ipairs(options) do
		modApi:addGenerationOption(
			option.id,
			option.name,
			option.desc,
			{ enabled = option.enabled }
		)
	end
end

local function load(self, options)
	for _, boss in ipairs(bosses) do
		local missionId = string.format("Mission_%sBoss", boss)
		local mission = _G[missionId]

		if mission and options[boss].enabled then
			add_element(missionId, Corp_Default.Bosses)

			if options.final.enabled then
				add_element(boss, Mission_Final.BossList)
				add_element(boss, Mission_Final_Cave.BossList)
			end
		else
			remove_element(missionId, Corp_Default.Bosses)
			remove_element(boss, Mission_Final.BossList)
			remove_element(boss, Mission_Final_Cave.BossList)
		end
	end
end

initializeOptions()

return {
	load = load
}
