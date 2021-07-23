
---------------------------------------------------------------------
-- Tutorial Tips v1.0 - code library
---------------------------------------------------------------------
-- small helper lib to manage tutorial tips that will only display once per profile.
-- can be reset, and would likely be done via a mod option.
--
-- id of the tip should preferably be somewhat unique to avoid collision with other mods,
-- since we will write data to Global_Texts along with everyone else.

local this = {tips = {}}

function this:Add(id, tip)
	assert(type(id) == 'string')
	assert(type(tip) == 'table')
	assert(type(tip.title) == 'string')
	assert(type(tip.text) == 'string')
	
	self.tips[id] = true
	Global_Texts[id .."_Title"] = tip.title
	Global_Texts[id .."_Text"] = tip.text
end

function this:Trigger(id, loc)
	if not modApi:readProfileData(id) then
		Game:AddTip(id, loc)
		modApi:writeProfileData(id, true)
	end
end

function this:Reset(id)
	if not id then
		for id, _ in pairs(self.tips) do
			modApi:writeProfileData(id, false)
		end
	end
	
	if self.tips[id] then
		modApi:writeProfileData(id, false)
	end
end

return this