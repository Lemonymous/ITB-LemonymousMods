
local color_maps
local mapIndex = {}
local this = {}

-- try override color_map functions
local function Override()
	if
		this.GetColorCount == GetColorCount and
		this.GetColorMap == GetColorMap
	then
		return
	end
	
	local maps = {}
	
	for id = 1, GetColorCount() do
		table.insert(maps, GetColorMap(id))
	end
	
	color_maps = maps
	
	GetColorCount = this.GetColorCount
	GetColorMap = this.GetColorMap
end

local function UpdateAnimationColorCount(dHeight)
	Override()
	
	for n, v in pairs(ANIMS) do
		if
			type(v) == "table"				and
			v.Height						and
			v.Height == #color_maps - dHeight
		then
			if not v.IsVek then
				v.Height = #color_maps
			end
		end
	end
end

function this.GetColorCount()
	Override()
	
	return #color_maps
end

function this.GetColorMap(id)
	Override()
	
	return color_maps[id]
end

function this.Get(name)
	return mapIndex[name] or 0
end

function this.Add(name, map)
	assert(type(name) == 'string')
	assert(type(map) == 'table')
	
	Override()
	mapIndex[name] = this.GetColorCount()
	
	table.insert(color_maps, {
		GL_Color(map.lights[1],			map.lights[2],			map.lights[3]),
		GL_Color(map.main_highlight[1],	map.main_highlight[2],	map.main_highlight[3]),
		GL_Color(map.main_light[1],		map.main_light[2],		map.main_light[3]),
		GL_Color(map.main_mid[1],		map.main_mid[2],		map.main_mid[3]),
		GL_Color(map.main_dark[1],		map.main_dark[2],		map.main_dark[3]),
		GL_Color(map.metal_dark[1],		map.metal_dark[2],		map.metal_dark[3]),
		GL_Color(map.metal_mid[1],		map.metal_mid[2],		map.metal_mid[3]),
		GL_Color(map.metal_light[1],	map.metal_light[2],		map.metal_light[3])
	})
	
	UpdateAnimationColorCount(1)
end

return this