
-- defs
local HIGH_THREAT = true
local LOW_THREAT = false


-- create mission list
local missionList = easyEdit.missionList:add("Meridia")

missionList:addMission("Mission_lmn_Runway", HIGH_THREAT)
missionList:addMission("Mission_lmn_Convoy", HIGH_THREAT)
missionList:addMission("Mission_lmn_Hotel", HIGH_THREAT)
missionList:addMission("Mission_lmn_Agroforest", HIGH_THREAT)
missionList:addMission("Mission_lmn_Greenhouse", HIGH_THREAT)

missionList:addMission("Mission_lmn_Wind", LOW_THREAT)
missionList:addMission("Mission_lmn_Geyser", LOW_THREAT)
missionList:addMission("Mission_lmn_FlashFlood", LOW_THREAT)
missionList:addMission("Mission_lmn_Volcanic_Vents", LOW_THREAT)
missionList:addMission("Mission_lmn_Geothermal_Plant", LOW_THREAT)
missionList:addMission("Mission_lmn_Bugs", LOW_THREAT)
missionList:addMission("Mission_lmn_Meadow", LOW_THREAT)
missionList:addMission("Mission_lmn_Flooded", LOW_THREAT)
