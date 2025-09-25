local MapGen = Mod:new()

MapGen.Class = MapGen.require('MapGen')

Api.addModToGlobalSpace(MapGen, 'Core.MapGen')

-- DEBUG MAPGEN

---@type MapGen
local mapGenerator = MapGen.Class:new()

mapGenerator:RegisterLayer("world", -1000, 500)

mapGenerator:RegisterRegion("world",
	{x = -1000, y = 0, z = -1000},
	{x = 1000, y = 0, z = 1000},
	{
		landscapeNoise = {
			offset = 0,
			scale = 10,
			spread = {x = 10, y = 10, z = 10},
			seed = 47,
			octaves = 4,
			persistence = 0.3,
			lacunarity = 3,
		}
	},
	true)

mapGenerator:run()