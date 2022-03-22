
-- create corporation
local corporation = modApi.corporation:add("Meridia")
corporation.Name = "Meridia Institute"
corporation.Bark_Name = "Meridia"
corporation.Description = "The environment on this island is unrelenting. Meridia set up to study these rare conditions."
corporation.Color = GL_Color(57,87,38)
corporation.Map = { "/music/grass/map" }
corporation.Music = {
	"/music/grass/combat_delta",
	"/music/grass/combat_gamma",
	"/music/sand/combat_guitar",
}
corporation.Pilot = "Pilot_Meridia"
