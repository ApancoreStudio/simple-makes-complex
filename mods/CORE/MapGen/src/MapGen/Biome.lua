local id = core.get_content_id

---@class MapGen.Biome
---@field name            string
---@field tempPoint       number
---@field humidityPoint   number
---@field minY            number
---@field maxY            number
---@field groundNodes     MapGen.Biome.GroundNodes
---@field groundNodesIds  MapGen.Biome.GroundNodesIds
---@field soilHeight      number
---@field generateRock    fun(mapGenerator:MapGen, biome:MapGen.Biome, data:number[], index:number, x:number, y:number, z:number)
---@field generateTurf    fun(mapGenerator:MapGen, biome:MapGen.Biome, data:number[], index:number, x:number, y:number, z:number)
---@field generateSoil    fun(mapGenerator:MapGen, biome:MapGen.Biome, data:number[], index:number, x:number, y:number, z:number)
---@field generateBottom  fun(mapGenerator:MapGen, biome:MapGen.Biome, data:number[], index:number, x:number, y:number, z:number)
local Biome = {}

---Definition table for the `MapGen.Biome`.
---
---**Only for EmmyLua.**
---@class MapGen.BiomeDef
---@field tempPoint       number
---@field humidityPoint   number
---@field minY            number
---@field maxY            number
---@field groundNodes     MapGen.Biome.GroundNodes
---@field soilHeight      number
---@field generateRock    fun(mapGenerator:MapGen, biome:MapGen.Biome, data:number[], index:number, x:number, y:number, z:number)?
---@field generateTurf    fun(mapGenerator:MapGen, biome:MapGen.Biome, data:number[], index:number, x:number, y:number, z:number)?
---@field generateSoil    fun(mapGenerator:MapGen, biome:MapGen.Biome, data:number[], index:number, x:number, y:number, z:number)?
---@field generateBottom  fun(mapGenerator:MapGen, biome:MapGen.Biome, data:number[], index:number, x:number, y:number, z:number)?


-- Default generate functions

---@param mapGenerator  MapGen
---@param biome         MapGen.Biome
---@param data          number[]
---@param index         number
---@param x             number
---@param y             number
---@param z             number
local defaultGenerateRock = function(mapGenerator, biome, data, index, x, y, z)
	data[index] = biome.groundNodesIds.rock
end

---@param mapGenerator  MapGen
---@param biome         MapGen.Biome
---@param data          number[]
---@param index         number
---@param x             number
---@param y             number
---@param z             number
local defaultGenerateTurf = function(mapGenerator, biome, data, index, x, y, z)
	data[index] = biome.groundNodesIds.turf
end

---@param mapGenerator  MapGen
---@param biome         MapGen.Biome
---@param data          number[]
---@param index         number
---@param x             number
---@param y             number
---@param z             number
local defaultGenerateSoil = function(mapGenerator, biome, data, index, x, y, z)
	data[index] = biome.groundNodesIds.soil
end

---@param mapGenerator  MapGen
---@param biome         MapGen.Biome
---@param data          number[]
---@param index         number
---@param x             number
---@param y             number
---@param z             number
local defaultGenerateBottom = function(mapGenerator, biome, data, index, x, y, z)
	data[index] = biome.groundNodesIds.bottom
end


---@param name  string
---@param def   MapGen.BiomeDef
---@return      MapGen.Biome
function Biome:new(name, def)
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

	local groundNodesIds = {}
	-- Converting node names to IDs
	for k, v in pairs(def.groundNodes) do
		groundNodesIds[k] = id(v)
	end

	---@type MapGen.Biome
	local instance = setmetatable({
		name           = name,
		tempPoint      = def.tempPoint,
		humidityPoint  = def.humidityPoint,
		minY           = def.minY,
		maxY           = def.maxY,
		groundNodes    = def.groundNodes,
		groundNodesIds = groundNodesIds,
		soilHeight     = def.soilHeight,
		generateRock   = def.generateRock,
		generateSoil   = def.generateSoil,
		generateTurf   = def.generateTurf,
		generateBottom = def.generateBottom,
	}, {__index = self})

	return instance
end

return Biome
