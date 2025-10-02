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
	true, 0.3)
--[[
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
