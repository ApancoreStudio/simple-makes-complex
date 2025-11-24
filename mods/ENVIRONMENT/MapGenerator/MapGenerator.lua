-- MAPGEN ENVIROMENT ONLY
-- https://api.luanti.org/core-namespace-reference/#mapgen-environment

-- This environment is isolated from the main environment,
-- so global tables need to be preloaded manually.

-- --- Global APIs load --
-- Ensure
dofile(core.get_modpath('smc__api__ensure')..'/init.lua')

-- Logger
dofile(core.get_modpath('smc__api__logger')..'/init.lua')

-- Math
dofile(core.get_modpath('smc__api__math')..'/init.lua')

-- Require
dofile(core.get_modpath('smc__api__require')..'/init.lua')

-- Mod
dofile(core.get_modpath('smc__api__mod')..'/init.lua')

-- TODO: исправить загрузку строковых библиотек (хотя они пока что не юзаются в мапгене)
-- Они не работают из-за get_current_modname внутри utf8
-- UTF-8
-- dofile(core.get_modpath('smc__api__utf8')..'/init.lua')

-- String
-- dofile(core.get_modpath('smc__api__string')..'/init.lua')

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
	threshold = 0.3,
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

mapGenerator:registerBiome('world', "biome1", {
	tempPoint = 0,
	humidityPoint = 0,
	minY = -10000,
	maxY = 1000,
	groundNodes = {
		soil = "soils:clay_soil_baren",
		turf = "soils:clay_soil_baren",
	},
	soilHeight = 1
})

mapGenerator:registerBiome('world', "biome2", {
	tempPoint = 100,
	humidityPoint = 100,
	minY = -1000,
	maxY = 1000,
	groundNodes = {
		soil = "soils:rocky_soil_baren",
		turf = "soils:rocky_soil_baren",
	},
	soilHeight = 1
})

mapGenerator:run()