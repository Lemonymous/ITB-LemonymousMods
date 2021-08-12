
local path = GetParentPath(...)

local missions = {
	"convoy",
	"volcanic_vents",
	"greenhouse",
	"geothermal",
	"flashflood",
	"wind",
	"bugs",
	"meadow",
	"geyser",
	"plants",
	"flooded",
	"runway",
	"hotel",
	"agroforest",
}

for _, mission in ipairs(missions) do
	require(path..mission)
end

require(path.."voice_units")
require(path.."voice_structures")
require(path.."bonusSpecimen")

local bonusSpecimen = require(path.."bonusSpecimen_dialog")
local extraDialog = require(path.."extra_dialog")

for personalityId, dialogTable in pairs(bonusSpecimen) do
	Personality[personalityId]:AddMissionDialogTable("Mission_lmn_Specimen", dialogTable)
end

for personalityId, dialogTable in pairs(extraDialog) do
	Personality[personalityId]:AddDialogTable(dialogTable)
end
