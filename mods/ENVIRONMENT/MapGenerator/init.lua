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

mapGenerator:RegisterRegion("world",
	vector.new(-150,0,-150),
	vector.new(150,0,150),
	{
		landscapeNoise = {
			offset = 50,
			scale = 10,
			spread = {x = 100, y = 100, z = 100},
			seed = 47,
			octaves = 8,
			persistence = 0.4,
			lacunarity = 2,
		},
		tempNoise = {
			offset = 50,
			scale = 25,
			spread = {x = 10, y = 10, z = 10},
			seed = 12,
			octaves = 2,
			persistence = 0.6,
			lacunarity = 2,
		},
		humidityNoise = {
			offset = 50,
			scale = 25,
			spread = {x = 10, y = 10, z = 10},
			seed = 12,
			octaves = 2,
			persistence = 0.6,
			lacunarity = 2,
		}
	},
	true, 1.5)
--[[
mapGenerator:RegisterRegion("world",
	vector.new(-50, 0, -50),
	vector.new(50, 0, 50),
	{
		landscapeNoise = {
			offset = -60,
			scale = 10,
			spread = {x = 100, y = 100, z = 100},
			seed = 41,
			octaves = 3,
			persistence = 0.4,
			lacunarity = 2,
		}
	},
	true, 1.5) --]]

mapGenerator:RegisterBiome("biome1", 0, 0, {
	soil = "soils:clay_soil_baren",
	turf = "soils:clay_soil_baren",
}, 1)

mapGenerator:RegisterBiome("biome2", 100, 100, {
	soil = "soils:rocky_soil_baren",
	turf = "soils:rocky_soil_baren",
}, 1)

mapGenerator:run()
