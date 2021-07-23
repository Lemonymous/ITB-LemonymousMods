
-- helper function to set up for screenshots for release.

local this = {
	i = 1
}

local mechs = {
	"PunchMech",
	"TankMech",
	"ArtiMech",
	
	"JetMech",
	"RocketMech",
	"PulseMech",
	
	"LaserMech",
	"ChargeMech",
	"ScienceMech",
	
	"ElectricMech",
	"WallMech",
	"RockartMech",
	
	"JudoMech",
	"DStrikeMech",
	"GravMech",
	
	"FlameMech",
	"IgniteMech",
	"TeleMech",
	
	"GuardMech",
	"MirrorMech",
	"IceMech",
	
	"LeapMech",
	"UnstableTank",
	"NanoMech",
}

local exclude = {
	"DefaultTeam",
	"IsPortrait",
	"Image",
}

function this:Add(pawnType)
	assert(type(pawnType) == 'string')
	assert(_G[pawnType])
	
	local source = _G[pawnType]
	local mech = _G[mechs[self.i]]
	
	mech.Flying = false
	mech.Armor = false
	
	for i, v in pairs(source) do
		if not list_contains(exclude, i) then
			mech[i] = v
		end
	end
	
	self.i = self.i + 1
end

return this