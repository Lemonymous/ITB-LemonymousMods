
-- create island
local island = modApi.island:add("Meridia")

island:appendAssets("img/island/")

island.shift = Point(14,13)
island.magic = Point(145,102)

island.regionData = {
	RegionInfo(Point(13,105), Point(10,-45), 100),
	RegionInfo(Point(100,12), Point(0,-20), 300),
	RegionInfo(Point(98,78), Point(0,-20), 100),
	RegionInfo(Point(64,172), Point(10,-30), 100),
	RegionInfo(Point(172,92), Point(-10,-20), 100),
	RegionInfo(Point(172,172), Point(-10,-80), 100),
	RegionInfo(Point(263,138), Point(0,0), 300),
	RegionInfo(Point(277,209), Point(-20,-30), 300)
}

island.network = {
	{2,3},
	{2,4},
	{0,1,3,4},
	{0,2,5},
	{1,2,5,6},
	{3,4,6,7},
	{4,5,7},
	{5,6}
}
