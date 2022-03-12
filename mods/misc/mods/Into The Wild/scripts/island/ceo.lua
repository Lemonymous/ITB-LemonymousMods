
local path = GetParentPath(...)
local dialog = require(path.."ceo_dialog")
local dialog_missions = require(path.."ceo_dialog_missions")

-- create personality
local personality = CreatePilotPersonality("Meridia", "Amelie Lacroix")
personality:AddDialogTable(dialog)
personality:AddDialogTable(dialog_missions)

-- create ceo
local ceo = modApi.ceo:add("Meridia")
ceo:setPersonality(personality)
ceo:setPortrait("img/ceo/portrait.png")
ceo:setOffice("img/ceo/office.png", "img/ceo/office_small.png")
