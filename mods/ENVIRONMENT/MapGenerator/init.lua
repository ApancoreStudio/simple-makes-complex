local id = core.get_content_id

---@type MapGen
local mapGenerator = Core.MapGen.Class:new({
	-- Special nodes
	air = id("air"),

	-- Rocks
	sylite    = id("rocks:sylite"),
	tauitite  = id("rocks:tauitite"),
	iyellite  = id("rocks:iyellite"),
	falmyte   = id("rocks:falmyte"),
	hapcoryte = id("rocks:hapcoryte"),
	burcite   = id("rocks:burcite"),
	felhor    = id("rocks:felhor"),
	malachite = id("rocks:malachite"),

	-- Liquids
	water = id("liquids:water_source"),
})

mapGenerator:RegisterLayer("world", -1000, 500)

local land1 = {
	offset = -10,
	scale = 2,
	spread = {x = 10, y = 10, z = 10},
	seed = 47,
	octaves = 8,
	persistence = 0.4,
	lacunarity = 2,
}

local land2 = {
	offset = 20,
	scale = 2,
	spread = {x = 10, y = 10, z = 10},
	seed = 47,
	octaves = 8,
	persistence = 0.4,
	lacunarity = 2,
}

local climat1 = {
	offset = 80,
	scale = 10,
	spread = {x = 10, y = 10, z = 10},
	seed = 47,
	octaves = 8,
	persistence = 0.6,
	lacunarity = 2,
}

local climat2 = {
	offset = 30,
	scale = 10,
	spread = {x = 10, y = 10, z = 10},
	seed = 47,
	octaves = 8,
	persistence = 0.6,
	lacunarity = 2,
}

local climat0 = {
	offset = 50,
	scale = 0,
	spread = {x = 10, y = 10, z = 10},
	seed = 47,
	octaves = 8,
	persistence = 0.4,
	lacunarity = 2,
}

---LAND
mapGenerator:RegisterPeak("world",
	vector.new(0,0,0),
	{
		landscapeNoise = land1,
		tempNoise = climat0,
		humidityNoise = climat0,
	},
	{is2d = 1, is3d = 1})

mapGenerator:RegisterPeak("world",
	vector.new(25,0,25),
	{
		landscapeNoise = land2,
		tempNoise = climat1,
		humidityNoise = climat1,
	},
	{is2d = 1, is3d = 1})

mapGenerator:RegisterPeak("world",
	vector.new(-25,0,-25),
	{
		landscapeNoise = land2,
		tempNoise = climat1,
		humidityNoise = climat1,
	},
	{is2d = 1, is3d = 1})

mapGenerator:RegisterPeak("world",
	vector.new(25,0, -25),
	{
		landscapeNoise = land2,
		tempNoise = climat2,
		humidityNoise = climat2,
	},
	{is2d = 1, is3d = 1})

mapGenerator:RegisterPeak("world",
	vector.new(-25,0,25),
	{
		landscapeNoise = land2,
		tempNoise = climat2,
		humidityNoise = climat2,
	},
	{is2d = 1, is3d = 1})

	mapGenerator:RegisterPeak("world",
	vector.new(25,50,25),
	{
		landscapeNoise = land1,
		tempNoise = climat1,
		humidityNoise = climat1,
	},
	{is3d = 1})

mapGenerator:RegisterPeak("world",
	vector.new(-25,50,-25),
	{
		landscapeNoise = land1,
		tempNoise = climat2,
		humidityNoise = climat2,
	},
	{is3d = 1})

mapGenerator:RegisterBiome("biome1", 0, 0, {
	soil = "soils:clay_soil_baren",
	turf = "soils:clay_soil_baren",
}, 1)

mapGenerator:RegisterBiome("biome2", 100, 100, {
	soil = "soils:rocky_soil_baren",
	turf = "soils:rocky_soil_baren",
}, 1)

mapGenerator:run()
