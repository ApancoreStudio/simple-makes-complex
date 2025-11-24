---@class MapGen.Layer.Biome
---@field name            string
---@field tempPoint       number
---@field humidityPoint   number
---@field minY            number
---@field maxY            number
---@field groundNodes     MapGen.Biome.GroundNodes
---@field soilHeight      number
---@field generateRock    fun(mapGenerator:MapGen, biome:MapGen.Layer.Biome, data:number[], index:number, x:number, y:number, z:number)
---@field generateSoil    fun(mapGenerator:MapGen, biome:MapGen.Layer.Biome, data:number[], index:number, x:number, y:number, z:number)
---@field generateBottom  fun(mapGenerator:MapGen, biome:MapGen.Layer.Biome, data:number[], index:number, x:number, y:number, z:number)
local Biome = {}

---@class MapGen.Layer.BiomeDef
---@field tempPoint       number
---@field humidityPoint   number
---@field minY            number
---@field maxY            number
---@field groundNodes     MapGen.Biome.GroundNodes
---@field soilHeight      number
---@field generateRock    fun(mapGenerator:MapGen, biome:MapGen.Layer.Biome, data:number[], index:number, x:number, y:number, z:number)?
---@field generateSoil    fun(mapGenerator:MapGen, biome:MapGen.Layer.Biome, data:number[], index:number, x:number, y:number, z:number)?
---@field generateBottom  fun(mapGenerator:MapGen, biome:MapGen.Layer.Biome, data:number[], index:number, x:number, y:number, z:number)?


-- Default generate functions

---@param mapGenerator  MapGen
---@param biome         MapGen.Layer.Biome
---@param data          number[]
---@param index         number
---@param x             number
---@param y             number
---@param z             number
local defaultGenerateRock = function(mapGenerator, biome, data, index, x, y, z)
	--TODO: минимальную логику генерации прописать
end

---@param mapGenerator  MapGen
---@param biome         MapGen.Layer.Biome
---@param data          number[]
---@param index         number
---@param x             number
---@param y             number
---@param z             number
local defaultGenerateSoil = function(mapGenerator, biome, data, index, x, y, z)
	--TODO: минимальную логику генерации прописать
end

---@param mapGenerator  MapGen
---@param biome         MapGen.Layer.Biome
---@param data          number[]
---@param index         number
---@param x             number
---@param y             number
---@param z             number
local defaultGenerateBottom = function(mapGenerator, biome, data, index, x, y, z)
	--TODO: минимальную логику генерации прописать
end


---@param name  string
---@param def   MapGen.Layer.BiomeDef
---@return      MapGen.Layer.Biome
function Biome:new(name, def)
	if def.generateRock == nil then
		Logger.warningLog('MapGen.Layer.Biome: The `%s` biome does not have a specified `generateRock()` function. The default function is used.', name)
		def.generateRock = defaultGenerateRock
	end

	if def.generateSoil == nil then
		Logger.warningLog('MapGen.Layer.Biome: The `%s` biome does not have a specified `generateSoil()` function. The default function is used.', name)
		def.generateSoil = defaultGenerateSoil
	end

	if def.generateBottom == nil then
		Logger.warningLog('MapGen.Layer.Biome: The `%s` biome does not have a specified `generateBottom()` function. The default function is used.', name)
		def.generateBottom = defaultGenerateBottom
	end

	---@type MapGen.Layer.Biome
	local instance = setmetatable({
		name           = name,
		tempPoint      = def.tempPoint,
		humidityPoint  = def.humidityPoint,
		minY           = def.minY,
		maxY           = def.maxY,
		groundNodes    = def.groundNodes,
		soilHeight     = def.soilHeight,
		generateRock   = def.generateRock or defaultGenerateRock,
		generateSoil   = def.generateSoil or defaultGenerateSoil,
		generateBottom = def.generateBottom or defaultGenerateBottom,
	}, {__index = self})

	return instance
end

return Biome