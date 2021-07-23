
-- excluded functions execute very frequently.
local exclude = {
	"UpdateMission",
	"BaseUpdate",
	"OnSerializationStart",
	"OnSerializationEnd",
	"GetCustomTile",
	"GetAmbience",
	"GetBonusStatus",
	"GetTurnLimit",
	"BaseObjectives",
	"UpdateObjectives",
	"GetDiffMod",
}

for i, v in pairs(Mission) do
	if type(v) == 'function' then
		if not list_contains(exclude, i) then
			local orig = Mission[i]
			Mission[i] = function(...)
				LOG("fn=".. i)
				return orig(...)
			end
		end
	end
end