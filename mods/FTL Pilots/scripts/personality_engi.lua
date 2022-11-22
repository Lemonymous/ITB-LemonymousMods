-- Adds a personality without the use of a csv file.

-- Unique identifier for personality.
local personality_id = "lmn_Engi"
local personality = CreatePilotPersonality(personality_id)
local dialogTable = {}

Personality[personality_id] = personality

-- Table of responses to various triggers.
local tbl = {
	-- Game States
	Gamestart = {},
	FTL_Found = {},
	FTL_Start = {},
	Gamestart_PostVictory = {},
	Death_Revived = {},
	Death_Main = {},
	Death_Response = {},
	Death_Response_AI = {},
	TimeTravel_Win = {},
	Gameover_Start = {},
	Gameover_Response = {},

	-- UI Barks
	Upgrade_PowerWeapon = {},
	Upgrade_NoWeapon = {},
	Upgrade_PowerGeneric = {},

	-- Mid-Battle
	MissionStart = {},
	Mission_ResetTurn = {},
	MissionEnd_Dead = {},
	MissionEnd_Retreat = {},

	MissionFinal_Start = {},
	MissionFinal_StartResponse = {},
	MissionFinal_FallStart = {},
	MissionFinal_FallResponse = {},
	MissionFinal_Pylons = {},
	MissionFinal_Bomb = {},
	MissionFinal_BombResponse = {},
	MissionFinal_CaveStart = {},
	MissionFinal_BombDestroyed = {},
	MissionFinal_BombArmed = {},

	PodIncoming = {},
	PodResponse = {},
	PodCollected_Self = {},
	PodDestroyed_Obs = {},
	Secret_DeviceSeen_Mountain = {},
	Secret_DeviceSeen_Ice = {},
	Secret_DeviceUsed = {},
	Secret_Arriving = {},
	Emerge_Detected = {},
	Emerge_Success = {},
	Emerge_FailedMech = {},
	Emerge_FailedVek = {},

	-- Mech State
	Mech_LowHealth = {},
	Mech_Webbed = {},
	Mech_Shielded = {},
	Mech_Repaired = {},
	Pilot_Level_Self = {},
	Pilot_Level_Obs = {},
	Mech_ShieldDown = {},

	-- Damage Done
	Vek_Drown = {},
	Vek_Fall = {},
	Vek_Smoke = {},
	Vek_Frozen = {},
	VekKilled_Self = {},
	VekKilled_Obs = {},
	VekKilled_Vek = {},

	DoubleVekKill_Self = {},
	DoubleVekKill_Obs = {},
	DoubleVekKill_Vek = {},

	MntDestroyed_Self = {},
	MntDestroyed_Obs = {},
	MntDestroyed_Vek = {},

	PowerCritical = {},
	Bldg_Destroyed_Self = {},
	Bldg_Destroyed_Obs = {},
	Bldg_Destroyed_Vek = {},
	Bldg_Resisted = {},


	-- Shared Missions
	Mission_Train_TrainStopped = {},
	Mission_Train_TrainDestroyed = {},
	Mission_Block_Reminder = {},

	-- Archive
	Mission_Airstrike_Incoming = {},
	Mission_Tanks_Activated = {},
	Mission_Tanks_PartialActivated = {},
	Mission_Dam_Reminder = {},
	Mission_Dam_Destroyed = {},
	Mission_Satellite_Destroyed = {},
	Mission_Satellite_Imminent = {},
	Mission_Satellite_Launch = {},
	Mission_Mines_Vek = {},

	-- RST
	Mission_Terraform_Destroyed = {},
	Mission_Terraform_Attacks = {},
	Mission_Cataclysm_Falling = {},
	Mission_Lightning_Strike_Vek = {},
	Mission_Solar_Destroyed = {},
	Mission_Force_Reminder = {},

	-- Pinnacle
	Mission_Freeze_Mines_Vek = {},
	Mission_Factory_Destroyed = {},
	Mission_Factory_Spawning = {},
	Mission_Reactivation_Thawed = {},
	Mission_SnowStorm_FrozenVek = {},
	Mission_SnowStorm_FrozenMech = {},
	BotKilled_Self = {},
	BotKilled_Obs = {},

	-- Detritus
	Mission_Disposal_Destroyed = {},
	Mission_Disposal_Activated = {},
	Mission_Barrels_Destroyed = {},
	Mission_Power_Destroyed = {},
	Mission_Teleporter_Mech = {},
	Mission_Belt_Mech = {},
}

-- scrambles a string.
local function scramble(text)
	local ret = ""
	for i = text:len(), 2, -1 do
		local j = math.random(1, i)
		ret = ret .. text:sub(j, j)

		-- swap i with j.
		text = text:sub(1, j - 1) .. text:sub(i, i) .. text:sub(j + 1, i - 1) .. text:sub(j, j)
	end

	ret = ret .. text:sub(1, 1)
	return ret
end

local function getEncodeTable(raw)
	local scrambled = scramble(raw)
	local ret = {}
	for i = 1, raw:len() do
	   local e, d = raw:sub(i,i), scrambled:sub(i,i)
	   ret[e] = d
	end

	return ret
end

local code = {
	"0123456789",
	"aeiouy",
	"bcdfghjklmnpqrstvwxz",
	"AEIOUY",
	"BCDFGHJKLMNPQRSTVWXZ"
}

for i, v in ipairs(code) do
	code[i] = getEncodeTable(v)
end

for i, v in pairs(tbl) do
	local text = tostring(i)
	for _, enc in ipairs(code) do
		text = text:gsub('.', enc)
	end
	text = text:gsub('_', ' ')
	text = text:sub(1,1):upper()..text:sub(2,-1):lower()
	table.insert(v, text)
end

for trigger, texts in pairs(tbl) do
	if
		type(texts) == 'string' and
		type(texts) ~= 'table'
	then
		texts = {texts}
	end

	assert(type(texts) == 'table')
	dialogTable[trigger] = texts
end

personality:AddDialogTable(dialogTable)
