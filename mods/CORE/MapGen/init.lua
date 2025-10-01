local MapGen = Mod:new()

MapGen.Class = MapGen.require('MapGen')

Api.addModToGlobalSpace(MapGen, 'Core.MapGen')

-- DEBUG MAPGEN

---@type MapGen
local mapGenerator = MapGen.Class:new()

mapGenerator:RegisterLayer("world", -1000, 500)

mapGenerator:RegisterRegion("world",
	{x = -100, y = 0, z = -100},
	{x = 100, y = 0, z = 100},
	{
		landscapeNoise = {
			offset = 50,
			scale = 10,
			spread = {x = 10, y = 10, z = 10},
			seed = 47,
			octaves = 8,
			persistence = 0.4,
			lacunarity = 2,
		}
	},
	true)

mapGenerator:RegisterRegion("world",
	{x = 50, y = 0, z = -100},
	{x = 150, y = 0, z = 100},
	{
		landscapeNoise = {
			offset = 100,
			scale = 10,
			spread = {x = 100, y = 100, z = 100},
			seed = 47,
			octaves = 8,
			persistence = 0.4,
			lacunarity = 2,
		}
	},
	true)--]]

mapGenerator:run()
