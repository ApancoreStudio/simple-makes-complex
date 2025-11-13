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

local a = mapGenerator:RegisterPeak("world",
	vector.new(0,0,0),
	{
		landscapeNoise = {
			offset = 30,
			scale = 2,
			spread = {x = 10, y = 10, z = 10},
			seed = 47,
			octaves = 8,
			persistence = 0.4,
			lacunarity = 2,
		},
	},
	{is3d = 1})

local b = mapGenerator:RegisterPeak("world",
	vector.new(0,50,0),
	{
		landscapeNoise = {
			offset = 30,
			scale = 2,
			spread = {x = 10, y = 10, z = 10},
			seed = 47,
			octaves = 8,
			persistence = 0.4,
			lacunarity = 2,
		},
	},
	{is3d = 1})

local c = mapGenerator:RegisterPeak("world",
	vector.new(50,0,0),
	{
		landscapeNoise = {
			offset = 30,
			scale = 2,
			spread = {x = 10, y = 10, z = 10},
			seed = 47,
			octaves = 8,
			persistence = 0.4,
			lacunarity = 2,
		},
	},
	{is3d = 1, is2d = 1})
--[[local d = mapGenerator:RegisterPeak("world",
	vector.new(50,50,0),
	{
		landscapeNoise = {
			offset = 30,
			scale = 2,
			spread = {x = 10, y = 100, z = 10},
			seed = 47,
			octaves = 8,
			persistence = 0.4,
			lacunarity = 2,
		},
	},
	{is3d = 1, is2d = 1})--]]

local e = mapGenerator:RegisterPeak("world",
	vector.new(25,25,25),
	{
		landscapeNoise = {
			offset = 10,
			scale = 2,
			spread = {x = 10, y = 10, z = 10},
			seed = 47,
			octaves = 8,
			persistence = 0.4,
			lacunarity = 2,
		},
	},
	{is3d = 1, is2d = 1})

mapGenerator:RegisterPeak("world",
	vector.new(25,25,-25),
	{
		landscapeNoise = {
			offset = 20,
			scale = 2,
			spread = {x = 10, y = 10, z = 10},
			seed = 47,
			octaves = 8,
			persistence = 0.4,
			lacunarity = 2,
		},
	},
	{is3d = 1, is2d = 1})
--[[
	local e = mapGenerator:RegisterPeak("world",
	vector.new(-50,0,50),
	{
		landscapeNoise = {
			offset = 40,
			scale = 0,
			spread = {x = 100, y = 100, z = 100},
			seed = 47,
			octaves = 8,
			persistence = 0.4,
			lacunarity = 2,
		},
	},
	true, 1.0)--]]

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
