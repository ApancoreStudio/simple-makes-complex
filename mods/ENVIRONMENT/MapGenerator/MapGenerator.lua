-- MAPGEN ENVIROMENT ONLY
-- https://api.luanti.org/core-namespace-reference/#mapgen-environment

-- This environment is isolated from the main environment,
-- so global tables need to be preloaded manually.

-- --- Global APIs load --
-- Ensure
dofile(core.get_modpath('smc__api__ensure')..'/init.lua')

-- Math
dofile(core.get_modpath('smc__api__math')..'/init.lua')

-- Require
dofile(core.get_modpath('smc__api__require')..'/init.lua')

-- Mod
dofile(core.get_modpath('smc__api__mod')..'/init.lua')

-- String
dofile(core.get_modpath('smc__api__string')..'/init.lua')

-- Table
dofile(core.get_modpath('smc__api__table')..'/init.lua')



-- --- MapGen definiton ---
local id = core.get_content_id

local mapGenRequire = Mod.getInfo('smc__core__map_gen').require

---@type MapGen
local MapGen = mapGenRequire('MapGen')

---@type MapGen
local mapGenerator = MapGen:new({
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

mapGenerator:registerCavern('world', 'cavern1', {
	minY = -100,
	maxY = -10,
	smoothDistance = 20,
	noiseParams ={
		offset = 0,
		scale = 1,
		spread = {x = 25, y = 25, z = 25},
		seed = 5934,
		octaves = 3,
		persistence = 0.5,
		lacunarity = 2.0
	},
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