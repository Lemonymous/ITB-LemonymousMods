-- Adds a personality without the use of a csv file.

-- Unique identifier for personality.
local personality = "lmn_Slug"

-- Table of responses to various triggers.
local tbl = {
	-- Game States
	Gamestart = {"o_O","O_o","O_O","o_o"},
	FTL_Found = {"?_?","O_o"},
	--FTL_Start = {},
	Gamestart_PostVictory = {"^_^"},
	Death_Revived = {"^_^"},
	Death_Main = {"+_+","x_x"},
	Death_Response = {"T_T",">_<","¨_¨"},
	Death_Response_AI = {"T_T",">_<","¨_¨"},
	TimeTravel_Win = {"^_^"},
	Gameover_Start = {"o_O","O_o","O_O","o_o"},
	Gameover_Response = {"T_T",">_<","¨_¨","-_-"},
	
	-- UI Barks
	Upgrade_PowerWeapon = {"$_$","n_n","^_^",},
	Upgrade_NoWeapon = {"¤_¤","~_~","._.","!_!","=_="},
	Upgrade_PowerGeneric = {"$_$","n_n","^_^",},
	
	-- Mid-Battle
	MissionStart = {"o_o","._.","@_@","c_c",},
	Mission_ResetTurn = {"?_?","z_z","*_*","o_O"},
	MissionEnd_Dead = {"v_v","T_T",",_,"},
	MissionEnd_Retreat = {"=_=","v_v",">_<"},

	MissionFinal_Start = {"o_o","._.","@_@","c_c",},
	MissionFinal_StartResponse = {"z_z","n_n","._.","o_o"},
	--MissionFinal_FallStart = {},
	MissionFinal_FallResponse = {"!_!","O_O","?_?"},
	--MissionFinal_Pylons = {},
	MissionFinal_Bomb = {"!_!","O_O","?_?"},
	--MissionFinal_BombResponse = {},
	MissionFinal_CaveStart = {"o_o","._.","@_@","c_c",},
	--MissionFinal_BombDestroyed = {},
	MissionFinal_BombArmed = {"!_!","n_n","c_c"},

	PodIncoming = {"?_?","!_!"},
	PodResponse = {"^_^","?_?","$_$"},
	PodCollected_Self = {"^_^","$_$"},
	PodDestroyed_Obs = {"v_v","*_*","¤_¤",",_,"},
	Secret_DeviceSeen_Mountain = {"?_?","!_!"},
	Secret_DeviceSeen_Ice = {"?_?","!_!"},
	Secret_DeviceUsed = {"^_^","$_$"},
	Secret_Arriving = {"?_?","!_!"},
	Emerge_Detected = {"b_b","O_O"},
	Emerge_Success = {"b_b","O_O"},
	Emerge_FailedMech = {"b_b","O_O"},
	Emerge_FailedVek = {"^_^","<_>"},

	-- Mech State
	Mech_LowHealth = {"<_>","*_*","o_o\\"},
	Mech_Webbed = {"/<_>\\","*_*","/o_o\\"},
	Mech_Shielded = {"^_^","-_O"},
	Mech_Repaired = {"^_^"},
	Pilot_Level_Self = {"^_^"},
	Pilot_Level_Obs = {"^_^"},
	Mech_ShieldDown = {"v_v","¤_¤","u_u"},

	-- Damage Done
	Vek_Drown = {"._.","n_n","^_^","b_b","d_d"},
	Vek_Fall = {"._.","n_n","^_^","b_b","d_d"},
	Vek_Smoke = {"._.","n_n","^_^","b_b","d_d"},
	Vek_Frozen = {"._.","n_n","^_^","b_b","d_d"},
	VekKilled_Self = {"._.","n_n","^_^","b_b","d_d"},
	VekKilled_Obs = {"._.","n_n","^_^","b_b","d_d"},
	VekKilled_Vek = {"._.","n_n","^_^","b_b","d_d"},

	DoubleVekKill_Self = {"._.","n_n","^_^","b_b","d_d"},
	DoubleVekKill_Obs = {"._.","n_n","^_^","b_b","d_d"},
	DoubleVekKill_Vek = {"._.","n_n","^_^","b_b","d_d"},

	MntDestroyed_Self = {"._.","n_n","^_^","b_b","d_d"},
	MntDestroyed_Obs = {"._.","n_n","^_^","b_b","d_d"},
	MntDestroyed_Vek = {"._.","n_n","^_^","b_b","d_d"},

	PowerCritical = {"u_u","v_v"},
	Bldg_Destroyed_Self = {"u_u","v_v"},
	Bldg_Destroyed_Obs = {"u_u","v_v","!_!"},
	Bldg_Destroyed_Vek = {"u_u","v_v","!_!"},
	Bldg_Resisted = {"n_n","^_^","!_!","._?"},


	-- Shared Missions
	--[[Mission_Train_TrainStopped = {},
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
	Mission_Belt_Mech = {},]]
}

-- inner workings. no need to modify.
local PilotPersonality = {Label = "Slug"}

function PilotPersonality:GetPilotDialog(event)
	if self[event] ~= nil then
		if type(self[event]) == "table" then
			return random_element(self[event])
		end
		
		return self[event]
	end
	
	LOG("No pilot dialog found for "..event.." event in "..self.Label)
	return ""
end

Personality[personality] = PilotPersonality
for trigger, texts in pairs(tbl) do
	if
		type(texts) == 'string' and
		type(texts) ~= 'table'
	then
		texts = {texts}
	end
	
	assert(type(texts) == 'table')
	Personality[personality][trigger] = texts
end