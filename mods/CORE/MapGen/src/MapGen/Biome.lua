local id = core.get_content_id

---@class MapGen.Biome
---@field name               string
---@field tempPoint          number
---@field humidityPoint      number
---@field minY               number
---@field maxY               number
---@field groundNodes        MapGen.Biome.GroundNodes
---@field groundNodesIDs     MapGen.Biome.GroundNodesIDs
---@field soilHeight         number
---@field generateAir        generateFunc
---@field generateCavernAir  generateFunc
---@field generateWater      generateFunc
---@field generateRock       generateFunc
---@field generateTurf       generateFunc
---@field generateSoil       generateFunc
---@field generateBottom     generateFunc
local Biome = {}

---@alias generateFunc  fun(mapGenerator:MapGen, biome:MapGen.Biome, data:number[], index:number, x:number, y:number, z:number)

---Definition table for the `MapGen.Biome`.
---
---**Only for EmmyLua.**
---@class MapGen.BiomeDef
---@field tempPoint          number
---@field humidityPoint      number
---@field minY               number
---@field maxY               number
---@field groundNodes        MapGen.Biome.GroundNodes
---@field soilHeight         number
---@field generateAir        generateFunc?
---@field generateCavernAir  generateFunc?
---@field generateWater      generateFunc?
---@field generateRock       generateFunc?
---@field generateTurf       generateFunc?
---@field generateSoil       generateFunc?
---@field generateBottom     generateFunc?


-- Default generate functions

---@param mapGenerator  MapGen
---@param biome         MapGen.Biome
---@param data          number[]
---@param index         number
---@param x             number
---@param y             number
---@param z             number
local defaultGenerateAir = function(mapGenerator, biome, data, index, x, y, z)
	data[index] = mapGenerator.nodeIDs.air
end

---@param mapGenerator  MapGen
---@param biome         MapGen.Biome
---@param data          number[]
---@param index         number
---@param x             number
---@param y             number
---@param z             number
local defaultGenerateCavernAir = function(mapGenerator, biome, data, index, x, y, z)
	biome.generateAir(mapGenerator, biome, data, index, x, y, z)
end

---@param mapGenerator  MapGen
---@param biome         MapGen.Biome
---@param data          number[]
---@param index         number
---@param x             number
---@param y             number
---@param z             number
local defaultGenerateWater = function(mapGenerator, biome, data, index, x, y, z)
	data[index] = mapGenerator.nodeIDs.water
end

---@param mapGenerator  MapGen
---@param biome         MapGen.Biome
---@param data          number[]
---@param index         number
---@param x             number
---@param y             number
---@param z             number
local defaultGenerateRock = function(mapGenerator, biome, data, index, x, y, z)
	data[index] = biome.groundNodesIDs.rock
end

---@param mapGenerator  MapGen
---@param biome         MapGen.Biome
---@param data          number[]
---@param index         number
---@param x             number
---@param y             number
---@param z             number
local defaultGenerateTurf = function(mapGenerator, biome, data, index, x, y, z)
	data[index] = biome.groundNodesIDs.turf
end

---@param mapGenerator  MapGen
---@param biome         MapGen.Biome
---@param data          number[]
---@param index         number
---@param x             number
---@param y             number
---@param z             number
local defaultGenerateSoil = function(mapGenerator, biome, data, index, x, y, z)
	data[index] = biome.groundNodesIDs.soil
end

---@param mapGenerator  MapGen
---@param biome         MapGen.Biome
---@param data          number[]
---@param index         number
---@param x             number
---@param y             number
---@param z             number
local defaultGenerateBottom = function(mapGenerator, biome, data, index, x, y, z)
	data[index] = biome.groundNodesIDs.bottom
end


---@param name  string
---@param def   MapGen.BiomeDef
---@return      MapGen.Biome
function Biome:new(name, def)
	if def.generateAir == nil then
		Logger.infoLog('MapGen.Biome: The `%s` biome does not have a specified `generateAir()` function. The default function is used.', name)
		def.generateAir = defaultGenerateAir
	end

	if def.generateCavernAir == nil then
		Logger.infoLog('MapGen.Biome: The `%s` biome does not have a specified `generateCavernAir()` function. The default function is used.', name)
		def.generateCavernAir = defaultGenerateCavernAir
	end

	if def.generateWater == nil then
		Logger.infoLog('MapGen.Biome: The `%s` biome does not have a specified `generateWater()` function. The default function is used.', name)
		def.generateWater = defaultGenerateWater
	end

	if def.generateRock == nil then
		Logger.infoLog('MapGen.Biome: The `%s` biome does not have a specified `generateRock()` function. The default function is used.', name)
		def.generateRock = defaultGenerateRock
	end

	if def.generateTurf == nil then
		Logger.infoLog('MapGen.Biome: The `%s` biome does not have a specified `generateTurf()` function. The default function is used.', name)
		def.generateTurf = defaultGenerateTurf
	end

	if def.generateSoil == nil then
		Logger.infoLog('MapGen.Biome: The `%s` biome does not have a specified `generateSoil()` function. The default function is used.', name)
		def.generateSoil = defaultGenerateSoil
	end

	if def.generateBottom == nil then
		Logger.infoLog('MapGen.Biome: The `%s` biome does not have a specified `generateBottom()` function. The default function is used.', name)
		def.generateBottom = defaultGenerateBottom
	end

	local groundNodesIDs = {}
	-- Converting node names to IDs
	for k, v in pairs(def.groundNodes) do
		groundNodesIDs[k] = id(v)
	end

	---@type MapGen.Biome
	local instance = setmetatable({
		name                 = name,
		tempPoint            = def.tempPoint,
		humidityPoint        = def.humidityPoint,
		minY                 = def.minY,
		maxY                 = def.maxY,
		groundNodes          = def.groundNodes,
		groundNodesIDs       = groundNodesIDs,
		soilHeight           = def.soilHeight,
		generateAir          = def.generateAir,
		generateCavernAir    = def.generateCavernAir,
		generateWater        = def.generateWater,
		generateRock         = def.generateRock,
		generateSoil         = def.generateSoil,
		generateTurf         = def.generateTurf,
		generateBottom       = def.generateBottom,
	}, {__index = self})

	return instance
end

return Biome
