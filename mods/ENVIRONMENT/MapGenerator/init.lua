local require    = Mod.getInfo("smc__core__polyhedron").require
local Polyhedron = require("Polyhedron")

require          = Mod.getInfo("smc__core__map_gen").require
local Mapgen     = require("MapGen")
local BufferZone = require("MapGen.Region.BufferZone")

local id = core.get_content_id

---@type MapGen
local mapGenerator = Mapgen:new({
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

-- Create a polyhedron for the region (cube from -150 to 150 in XZ, full layer height in Y)
local regionVertices = {
	vector.new(-150, -1000, -150),  -- Bottom southwest
	vector.new( 150, -1000, -150),  -- Bottom southeast  
	vector.new( 150, -1000,  150),  -- Bottom northeast
	vector.new(-150, -1000,  150),  -- Bottom northwest
	vector.new(-150,  500, -150),   -- Top southwest
	vector.new( 150,  500, -150),   -- Top southeast
	vector.new( 150,  500,  150),   -- Top northeast
	vector.new(-150,  500,  150)    -- Top northwest
}

local regionFaces = {
	{1, 2, 3, 4}, -- Bottom face
	{5, 6, 7, 8}, -- Top face
	{1, 2, 6, 5}, -- South face
	{2, 3, 7, 6}, -- East face
	{3, 4, 8, 7}, -- North face
	{4, 1, 5, 8}  -- West face
}

local regionPolyhedron = Polyhedron:new(regionVertices, regionFaces)

-- Define buffer zone with 50 node thickness and smoothstep interpolation
local regionBufferZone = BufferZone:new(50, "smoothstep")

-- Register the region with the new system
mapGenerator:RegisterRegion("Region Alpha", "world", regionPolyhedron, {
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
}, regionBufferZone)

-- Alternative: Register region from OBJ file (uncomment if you have an OBJ file)
-- mapGenerator:RegisterRegionFromOBJ("world", "regions/mountain_range.obj", {
-- 	landscapeNoise = {
-- 		offset = -60,
-- 		scale = 10,
-- 		spread = {x = 100, y = 100, z = 100},
-- 		seed = 41,
-- 		octaves = 3,
-- 		persistence = 0.4,
-- 		lacunarity = 2,
-- 	}
-- }, BufferZone:new(30, "linear"), "linear")

mapGenerator:RegisterBiome("biome1", 0, 0, {
	soil = "soils:clay_soil_baren",
	turf = "soils:clay_soil_baren",
}, 1)

mapGenerator:RegisterBiome("biome2", 100, 100, {
	soil = "soils:rocky_soil_baren",
	turf = "soils:rocky_soil_baren",
}, 1)

mapGenerator:run()