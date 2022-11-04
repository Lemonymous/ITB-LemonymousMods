
local function addSquad()
	modApi:addSquad(
		{
			id = "lmn_secret_plants",
			"Secret Plants",
			"lmn_Chomper",
			"lmn_Chili",
			"lmn_Puffer"
		},
		"Secret Plants",
		Global_Texts.TipText_Secret,
		lmn_Chomper.Icon
	)
end

local function getToast()
	return {
		title = "Squad Unlocked!",
		name = "Secret Plants",
		tooltip = "Secret Plants unlocked.",
		image = "img/achievements/lmn_leaders2.png"
	}
end

return {
	addSquad = addSquad,
	getToast = getToast
}
