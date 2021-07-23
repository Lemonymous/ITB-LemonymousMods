
-- this file does a full override of Mission:NextRobot in order to globalize the table used to spawn bots.

-- if you are making a mod featuring a snowbot,
-- you can copy this file and the mods should be compatible.
-- you can then add/remove your bots seamlessly to the table EnemyLists.Bots.
-- the table Spawner.max_pawns controls how many of your bot can spawn in a single mission.

--------------------------------------------------------------
-- initialize the file in your init function in init.lua with:

-- require(self.scriptPath .."globalize_bot_table")
--------------------------------------------------------------


------------------- Example of use : --------------------
---------------------------------------------------------
-- add the bot named "snowbot_example":

-- table.insert(EnemyLists.Bots, "snowbot_example")
---------------------------------------------------------

---------------------------------------------------------
-- remove the bot named "snowbot_example":

-- remove_element("snowbot_example", EnemyLists.Bots)
---------------------------------------------------------

---------------------------------------------------------
-- cap the bot named "snowbot_example" to 2 per mission:

-- Spawner.max_pawns["snowbot_example"] = 2
--------------------------------------------------------------------------
--------------------------------------------------------------------------
EnemyLists.Bots = EnemyLists.Bots or {"Snowtank", "Snowlaser", "Snowart"}

function Mission:NextRobot(name_only)
	name_only = name_only or false
	return self:NextPawn( EnemyLists.Bots, name_only )
end

-- Mission_Stasis has hard coded its bot table.
-- Doing a full override to use our new bot table.
function Mission_Stasis:StartMission()
	local choices = {}
	self.Bots = {}
	
	for i = 3, 6 do
		for j = 1, 6 do
			if 	not Board:IsBlocked(Point(i,j),PATH_GROUND) then
				choices[#choices+1] = Point(i,j)
			end
		end
	end
	
	if #choices < 2 then
		LOG("Didn't find locations for stasis bots")
		return
	end
	
	local levels = {"1", "2"}
	if GetSector() > 2 then
		levels = {"2", "2"}
	end
	
	for i = 1, 2 do
		local pawn = PAWN_FACTORY:CreatePawn(random_element(EnemyLists.Bots)..levels[i])
		local choice = random_removal(choices)
		self.Bots[i] = pawn:GetId()
		Board:AddPawn(pawn,choice)
		--pawn:SetPowered(false)
		pawn:SetFrozen(true)
		pawn:SetMissionCritical(true)
	end
end