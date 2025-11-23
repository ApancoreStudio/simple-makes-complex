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
	offset = -20,
	scale = 5,
	spread = {x = 10, y = 10, z = 10},
	seed = 47,
	octaves = 3,
	persistence = 0.4,
	lacunarity = 2,
}

local land2 = {
	offset = 20,
	scale = 5,
	spread = {x = 10, y = 10, z = 10},
	seed = 47,
	octaves = 3,
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

local v = vector.new

mapGenerator:register2DPeaks("world",
{
	landscapeNoise = land1,
	tempNoise      = climat2,
	humidityNoise  = climat2,
},{
	v(500, 0, 500),
	v(-500, 0, -500),
	v(-500, 0, 500),
	v(500, 0, -500),
})

mapGenerator:register2DPeaks("world",
{
	landscapeNoise = land2,
	tempNoise      = climat1,
	humidityNoise  = climat1,
},{
	v(-300, 0, 300),
	v(200, 0, -400),
})

mapGenerator:register2DPeaks("world",
{
	landscapeNoise = land2,
	tempNoise      = climat2,
	humidityNoise  = climat2,
},{
	v(200, 0, 100),
	v(-300, 0, -200),
})

mapGenerator:registerCavern('world', 'cavern1', -100, -10, 20, {
	offset = 0,
	scale = 1,
	spread = {x = 25, y = 25, z = 25},
	seed = 5934,
	octaves = 3,
	persistence = 0.5,
	lacunarity = 2.0
})

mapGenerator:registerBiome('world', "biome1", 0, 0, {
	soil = "soils:clay_soil_baren",
	turf = "soils:clay_soil_baren",
}, 1)

mapGenerator:registerBiome('world', "biome2", 100, 100, {
	soil = "soils:rocky_soil_baren",
	turf = "soils:rocky_soil_baren",
}, 1)

mapGenerator:run()

minetest.register_ore({
	ore_type        = "blob",
	ore             = "soils:clay_soil_baren",
	wherein         = {"rocks:iyellite", "rocks:falmyte"},
	clust_scarcity  = 16 * 16 * 16,
	clust_size      = 5,
	y_max           = 0,
	y_min           = -3100,
	noise_threshold = 0.0,
	noise_params    = {
		offset = 1,
		scale = 0.5,
		spread = {x = 5, y = 5, z = 5},
		seed = 2316,
		octaves = 1,
		persist = 0.0
	},
})