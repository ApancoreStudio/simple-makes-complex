local mathCeil,  mathAbs,  mathRound,  mathMin
	= math.ceil, math.abs, math.round, math.min

local BUFFER_ZONE_WIDTH = 30

-- --- MapGen default moises ---
---@type ValueNoise
local oceanNoise

---@type NoiseParams
local oceanNoiseParams = {
	offset = -30,
	scale = 10,
	spread = vector.new(100, 100, 100),
	seed = 47,
	octaves = 8,
	persistence = 0.4,
	lacunarity = 2,
}

---@type ValueNoise
local rocksNoise

---@type NoiseParams
local rocksNoiseParams ={
	offset = 4,
	scale = 2,
	spread = {x = 30, y = 30, z = 30},
	seed = 47,
	octaves = 3,
	persistence = 0.5,
	lacunarity = 4,
}

-- --- End default noises ---

local modInfo = Mod.getInfo()
local require = modInfo.require

---@type MapGen.Layer
local Layer = require("MapGen.Layer")

---@type MapGen.Cell
local Cell = require("MapGen.Cell")

---@type MapGen.Biome
local Biome = require("MapGen.Biome")

---@class MapGen
---@field layersByName           table
---@field layersList             table
---@field biomesList             table
---@field biomesDiagram           table
---@field multinoiseInitialized  boolean  Is the fractal noise of the cells initialized? This is necessary for a one-time noise initialization.
---@field isRunning              boolean  A static field that guarantees that only one instance of the `MapGen` class will work.
---@field nodeIDs                table<string, number>
local MapGen = {
	layersByName          = {},
	layersList            = {},
	biomesList            = {},
	biomesDiagram            = {},
	multinoiseInitialized = false,
	isRunning             = false,
}

---@param nodeIDs  table<string, string>
---@return MapGen
function MapGen:new(nodeIDs)
	---@type MapGen
	local instance = setmetatable({
		nodeIDs = nodeIDs,
	}, {__index = self})

	return instance
end

---Determines which layer a node belongs to based on its height coordinate.
---@param yPos  number
---@return      MapGen.Layer?
function MapGen:getLayerByHeight(yPos)
	--- TODO: возможно здесь получится сделать более оптимизированный алгоритм
	--- учитывая тот факт, что эта функция вызывается для каждой ноды в on_generated
	--- и может быть даже не один раз
	--- Можно подумать над тем, чтобы использовать сортированный список

	---@param layer  MapGen.Layer
	for _, layer in  ipairs(self.layersList) do

		if yPos >= layer.minY and yPos <= layer.maxY then
			return layer
		end

	end
end

---Mark the world area between two heights as a `MapGen.Layer`.
---
---Note: layers must not overlap.
---@param name  string
---@param minY  number
---@param maxY  number
function MapGen:RegisterLayer(name, minY, maxY)
	---Checking if layers overlap
	if self:getLayerByHeight(minY) ~= nil and self:getLayerByHeight(maxY) ~= nil then
		error('Registered layers must not overlap!')
	end

	---@type MapGen.Layer
	local layer = Layer:new(name, minY, maxY)

	self.layersByName[name] = layer
	table.insert(self.layersList, layer)

	-- Sort layers by maxY descending for processing priority
	table.sort(self.layersList, function(a, b)
		return a.maxY > b.maxY
	end)
end

-- TODO: переписать описание функции
---Mark a cell of the world as a cubic cell by two opposite vertices.
---
---Cells must be included in layers and may overlap each other.
---@param layerName     string  The name of the layer in which the new cell will be included.
---@param cellPos        vector
---@param multinoise    MapGen.Cell.MultinoiseParams     Noise that will be assigned to the cell and that will influence map generation
---@param cellIs2D    boolean?  If true, the transmitted Y coordinate will be overwritten by the layer boundaries.
---@param weightFactor  number?   The coefficient by which the reduction in the impact of cellal noise on generation will be calculated. If 0, there will be no reduction.
function MapGen:RegisterCell(layerName, cellPos, multinoise, cellIs2D, weightFactor)
	---@type MapGen.Layer
	local layer = self.layersByName[layerName]

	if not layer then
		error("Invalid layer: " .. layerName)
	end

	-- TODO: вероятно стоит убрать 2D ячейки
	if cellIs2D then
		cellPos.y = 0
	end

	--TODO: добавить проверку, что координата ячейки не совпадают
	--TODO: Добавить проверку, что координата ячейки не выходит за границы слоя

	-- TODO: вероятно стоит убрать вес
	if weightFactor == nil then
		weightFactor = 1
	end

	---@type MapGen.Cell
	local cell = Cell:new(cellPos, multinoise, weightFactor)

	layer:addCell(cell)
end

---Initialize cell noise. This should be called after the map object is loaded.
function MapGen:initCellsMultinoise()
	---@param layer  MapGen.Layer
	for _, layer in ipairs(self.layersList) do

		---@param cell MapGen.Cell
		for _, cell in ipairs(layer.cellsList) do
			cell:initMultinoise()
		end

	end

	self.multinoiseInitialized = true
end

---@param name           string
---@param tempPoint      number
---@param humidityPoint  number
---@param groundNodes    MapGen.Biome.GroundNodes
---@param soilHeight     number
function MapGen:RegisterBiome(name, tempPoint, humidityPoint, groundNodes, soilHeight)
	local biome = Biome:new(name, tempPoint, humidityPoint, groundNodes, soilHeight)

	table.insert(self.biomesList, biome)
end

function MapGen:initBiomesDiagram()
	local diagram = self.biomesDiagram

	for temp = 0, 100 do
		diagram[temp] = {}

		for humidity = 0, 100 do
			local minDistance = math.huge
			local closestBiome = nil

			---@param biome MapGen.Biome
			for _, biome in ipairs(self.biomesList) do
				local distance = (temp - biome.tempPoint)^2 + (humidity - biome.humidityPoint)^2

				if distance < minDistance then
					minDistance = distance
					closestBiome = biome
				end
			end

			diagram[temp][humidity] = closestBiome
		end
	end
end

---Calculate the weight for noise based on
---the distance of the point from the center of the cell.
---
---If the `weightFactor` is `0`, then the cell's
---weight is not calculated and is always equal to `1`.
---@param minPos        vector
---@param maxPos        vector
---@param x             number
---@param z             number
---@param weightFactor  number
---@return              number
local function calculateWeight2D(minPos, maxPos, x, z, weightFactor)
	if weightFactor == 0 then
		return 1
	end

	local centerX = (minPos.x + maxPos.x) / 2
	local centerZ = (minPos.z + maxPos.z) / 2

	local distX = 1 - (mathAbs(x - centerX) / (mathAbs((maxPos.x - minPos.x)) / 2))^weightFactor
	local distZ = 1 - (mathAbs(z - centerZ) / (mathAbs((maxPos.z - minPos.z)) / 2))^weightFactor

	---@type number
	local weight = distX * distZ -- mathMin(distX, distZ)

	return weight
end

local function generateSoil(biome, data, index, x, y, z)
	data[index] = core.get_content_id(biome.groundNodes.turf)  -- TODO: убрать тут get_content_id(), переместить его куда-то "выше"
end

---@param ids           table<string, number>
---@param data          number[]
---@param index         number
---@param x             number
---@param y             number
---@param z             number
local function generateRock(ids, data, index, x, y, z)

	if rocksNoise == nil then
		rocksNoise = core.get_value_noise(rocksNoiseParams)
	end

	local noiseRocksValue = mathRound(rocksNoise:get_3d({x = x, y = y, z = z}))
	if     noiseRocksValue == 1 then
		data[index] = ids.malachite
	elseif noiseRocksValue == 2 then
		data[index] = ids.hapcoryte
	elseif noiseRocksValue == 3 then
		data[index] = ids.iyellite
	elseif noiseRocksValue == 4 then
		data[index] = ids.sylite
	elseif noiseRocksValue == 5 then
		data[index] = ids.tauitite
	elseif noiseRocksValue == 6 then
		data[index] = ids.falmyte
	elseif noiseRocksValue == 7 then
		data[index] = ids.burcite
	elseif noiseRocksValue == 8 then
		data[index] = ids.felhor
	end
end

---@param mapGenerator  MapGen
---@param hight         number
---@param temp          number
---@param humidity      number
---@param data          number[]
---@param index         number
---@param x             number
---@param y             number
---@param z             number
local function generateNode(mapGenerator, hight, temp, humidity, data, index, x, y, z)
	local ids =  mapGenerator.nodeIDs

	local biome = mapGenerator.biomesDiagram[temp][humidity]

	if y > hight and y > 0 then
		data[index] = ids.air
	elseif y == hight and y > 0 then
		generateSoil(biome, data, index, x, y, z)
	elseif y < hight then
		generateRock(ids, data, index, x, y, z)
	else
		data[index] = ids.water
	end
end

---@param mapGenerator  MapGen
---@param cell          MapGen.Cell
---@param data          number[]
---@param index         number
---@param x             number
---@param y             number
---@param z             number
local function oneCellGeneratorHandler(mapGenerator, cell, data, index, x, y, z)
	---@type ValueNoise?
	local heightNoise   = cell:getMultinoise().landscapeNoise
	---@type ValueNoise?
	local tempNoise     = cell:getMultinoise().tempNoise
	---@type ValueNoise?
	local humidityNoise = cell:getMultinoise().humidityNoise

	-- Default noise's values.
	local noiseHeightValue   = oceanNoise:get_2d({x = x, y = z})
	local noiseTempValue     = 0.0
	local noiseHumidityValue = 0.0

	if heightNoise ~= nil then
		noiseHeightValue = mathRound(heightNoise:get_2d({x = x, y = z}))
	end

	if tempNoise ~= nil then
		noiseTempValue = mathRound(tempNoise:get_2d({x = x, y = z}))
	end

	if humidityNoise ~= nil then
		noiseHumidityValue = mathRound(humidityNoise:get_2d({x = x, y = z}))
	end

	generateNode(mapGenerator, noiseHeightValue, noiseTempValue, noiseHumidityValue, data, index, x, y, z)
end

---@return number
local function smootherstep2(valueA, valueB, x)
	x = x + (BUFFER_ZONE_WIDTH / 2)
	-- Clamp x to the range [edge0, edge1] and normalize to [0, 1]
	---@type number
	local t = math.max(0, math.min(1, x / BUFFER_ZONE_WIDTH ))
	-- Quintic polynomial: 6t^5 - 15t^4 + 10t^3
	local new_t = t * t * t * (t * (t * 6 - 15) + 10)

	return valueB + (valueA - valueB) * t--new_t
end

---@param mapGenerator  MapGen
---@param cellA         MapGen.Cell
---@param cellB         MapGen.Cell
---@param distance      number
---@param data          number[]
---@param index         number
---@param x             number
---@param y             number
---@param z             number
local function twoCellsGeneratorHanler(mapGenerator, cellA, cellB, distance, data, index, x, y, z)
	---@type ValueNoise?
	local heightNoiseA   = cellA:getMultinoise().landscapeNoise
	---@type ValueNoise?
	local tempNoiseA     = cellA:getMultinoise().tempNoise
	---@type ValueNoise?
	local humidityNoiseA = cellA:getMultinoise().humidityNoise

	---@type ValueNoise?
	local heightNoiseB   = cellB:getMultinoise().landscapeNoise
	---@type ValueNoise?
	local tempNoiseB     = cellB:getMultinoise().tempNoise
	---@type ValueNoise?
	local humidityNoiseB = cellB:getMultinoise().humidityNoise

	-- Default noise's values.
	local noiseHeightValue   = oceanNoise:get_2d({x = x, y = z})
	local noiseTempValue     = 0.0
	local noiseHumidityValue = 0.0

	if heightNoiseA ~= nil and heightNoiseB ~= nil then
		noiseHeightValue = mathRound(smootherstep2(
			heightNoiseA:get_2d({x = x, y = z}),
			heightNoiseB:get_2d({x = x, y = z}),
			distance))
	end

	if tempNoiseA ~= nil and tempNoiseB ~= nil then
		noiseTempValue = mathRound(tempNoiseA:get_2d({x = x, y = z}))  --TODO интерполяция
	end

	if humidityNoiseA ~= nil and humidityNoiseB ~= nil then
		noiseHumidityValue = mathRound(humidityNoiseA:get_2d({x = x, y = z}))  --TODO интерполяция
	end

	generateNode(mapGenerator, noiseHeightValue, noiseTempValue, noiseHumidityValue, data, index, x, y, z)
end

---@return number
local function smootherstep3(valueA, valueB, valueC, x, y)
	x = x + (BUFFER_ZONE_WIDTH / 2)
	y = y + (BUFFER_ZONE_WIDTH / 2)
	-- Clamp x to the range [edge0, edge1] and normalize to [0, 1]
	---@type number
	local tx = math.max(0, math.min(1, x / BUFFER_ZONE_WIDTH ))
	-- Quintic polynomial: 6t^5 - 15t^4 + 10t^3
	--local new_t = t * t * t * (t * (t * 6 - 15) + 10)

	local valueAB = valueB + (valueA - valueB) * tx--new_t

	local ty = math.max(0, math.min(1, y / BUFFER_ZONE_WIDTH ))
	--new_t = t * t * t * (t * (t * 6 - 15) + 10)

	local T = 1 + tx + ty

	local valueAC = valueC + (valueA - valueC) * ty--new_t
	return (valueA * math.min(tx, ty) + valueB * (1-tx) + valueC * (1-ty))/(math.min(tx, ty) + (1-tx) + (1-tx))-- + valueC * (ty/T)) --(valueAC + valueAB)/2--valueA + (valueB - valueA) * tx + (valueC - valueA) * ty
end

---@param mapGenerator  MapGen
---@param cellA         MapGen.Cell
---@param cellB         MapGen.Cell
---@param cellC         MapGen.Cell
---@param distanceAB     number
---@param distanceAC     number
---@param data          number[]
---@param index         number
---@param x             number
---@param y             number
---@param z             number
local function threeCellsGeneratorHanler(mapGenerator, cellA, cellB, cellC, distanceAB, distanceAC, data, index, x, y, z)
	---@type ValueNoise?
	local heightNoiseA   = cellA:getMultinoise().landscapeNoise
	---@type ValueNoise?
	local tempNoiseA     = cellA:getMultinoise().tempNoise
	---@type ValueNoise?
	local humidityNoiseA = cellA:getMultinoise().humidityNoise

	---@type ValueNoise?
	local heightNoiseB   = cellB:getMultinoise().landscapeNoise
	---@type ValueNoise?
	local tempNoiseB     = cellB:getMultinoise().tempNoise
	---@type ValueNoise?
	local humidityNoiseB = cellB:getMultinoise().humidityNoise

	---@type ValueNoise?
	local heightNoiseC   = cellC:getMultinoise().landscapeNoise
	---@type ValueNoise?
	local tempNoiseC     = cellC:getMultinoise().tempNoise
	---@type ValueNoise?
	local humidityNoiseC = cellC:getMultinoise().humidityNoise

	-- Default noise's values.
	local noiseHeightValue   = oceanNoise:get_2d({x = x, y = z})
	local noiseTempValue     = 0.0
	local noiseHumidityValue = 0.0

	local cellPos = (cellC.getCellPos() + cellB.getCellPos())/2
	local distanceBC =  (x - cellPos.x)^2 + (y - cellPos.y)^2 + (z - cellPos.z)^2

	if heightNoiseA ~= nil and heightNoiseB ~= nil and heightNoiseC ~=nil then
		noiseHeightValue = mathRound(smootherstep3(
			heightNoiseA:get_2d({x = x, y = z}),
			heightNoiseB:get_2d({x = x, y = z}),
			heightNoiseC:get_2d({x = x, y = z}),
			distanceAB,
			distanceAC))
	end

	if tempNoiseA ~= nil and tempNoiseB ~= nil then
		noiseTempValue = mathRound(tempNoiseA:get_2d({x = x, y = z}))  --TODO интерполяция
	end

	if humidityNoiseA ~= nil and humidityNoiseB ~= nil then
		noiseHumidityValue = mathRound(humidityNoiseA:get_2d({x = x, y = z}))  --TODO интерполяция
	end

	generateNode(mapGenerator, noiseHeightValue, noiseTempValue, noiseHumidityValue, data, index, x, y, z)
end

---@param pos0 vector
---@param pos1 vector
---@return     number
local function calcDistance(pos0, pos1, posN)
	-- We find the direction vector of line.
	local v = pos1 - pos0

	-- We find the coefficients for the parametric notation of the line equation.
	local a = pos1.x - pos0.x
	local b = pos1.y - pos0.y
	local c = pos1.z - pos0.z

	-- We find the parameter `t` based on the perpendicular
	-- from the point of the generated node to the line.
	local t = (a * (posN.x - pos0.x) + b * (posN.y - pos0.y) + c * (posN.z - pos0.z)) / (a^2 + b^2 + c^2)

	-- We find the projection point of the generated
	-- node point through the parametric equation.
	local projection = pos0 + t*v

	-- We find the distance between the generated node's point and its projection
	-- (we obtain the length of the perpendicular to line).
	return math.sqrt((pos0.x - projection.x)^2 + (pos0.y - projection.y)^2 + (pos0.z - projection.z)^2)
end

---@param mapGenerator  MapGen
---@param data          number[]
---@param index         number
---@param x             number
---@param y             number
---@param z             number
local function generatorHandler(mapGenerator, data, index, x, y, z)
	-- If generation occurs outside the layers, then a void is generated
	local layer = mapGenerator:getLayerByHeight(y)
	if layer == nil then
		data[index] = mapGenerator.nodeIDs.air

		return
	end

	-- The ocean floor height is used as the default value.
	if oceanNoise == nil then
		oceanNoise = core.get_value_noise(oceanNoiseParams)
	end

	--- We get the two nearest cells.
	---@type MapGen.Cell, MapGen.Cell?, MapGen.Cell?
	local cellA, cellB, cellC = layer:getCellsByPos(x, y, z)

	--- The second cell may not exist, so we will generate only the first one.
	if cellB == nil then
		oneCellGeneratorHandler(mapGenerator, cellA, data, index, x, y, z)
		return
	end

	--[[- We calculate the distance to the cell centers
	local cellPos = cellA.getCellPos()
	local distanceA = (x - cellPos.x)^2 + (y - cellPos.y)^2 + (z - cellPos.z)^2
	cellPos = cellB.getCellPos()
	local distanceB = (x - cellPos.x)^2 + (y - cellPos.y)^2 + (z - cellPos.z)^2



	if cellC ~= nil then
		cellPos = cellC.getCellPos()
		local distanceC = (x - cellPos.x)^2 + (y - cellPos.y)^2 + (z - cellPos.z)^2

		if  mathAbs(distanceB - distanceA) <= BUFFER_ZONE_WIDTH^2 and
			mathAbs(distanceC - distanceB) <= BUFFER_ZONE_WIDTH^2 and
			mathAbs(distanceC - distanceA) <= BUFFER_ZONE_WIDTH^2
		then
			threeCellsGeneratorHanler(mapGenerator, cellA, cellB, cellC, distanceA, distanceB, distanceC, data, index, x, y, z)
			return
		end
	end

	if x == -45 then
		print(x, math.sqrt(distanceB), math.sqrt(distanceA))
	end
	--- If the point is in the buffer zone...
	if mathAbs(math.sqrt(distanceB) - math.sqrt(distanceA)) <= BUFFER_ZONE_WIDTH^2 then
		--- ... we will smooth out the noise.
		twoCellsGeneratorHanler(mapGenerator, cellA, cellB, distanceA, distanceB, data, index, x, y, z)
		return
	else
		--- ... otherwise we will use the nearest cell.
		oneCellGeneratorHandler(mapGenerator, cellA, data, index, x, y, z)
		return
	end--]]

	--[[local pos0 = ( cellB.getCellPos() + cellA.getCellPos() ) / 2
	local posB = cellB.getCellPos()
	local a = posB.x - pos0.x
	local b = posB.y - pos0.y
	local c = posB.z - pos0.z

	local t = (a * (x - pos0.x) + b * (y - pos0.y) + c * (z - pos0.z)) / (a^2 + b^2 + c^2)

	local projection = vector.new(
		pos0.x + a * t,
		pos0.y + a * t,
		pos0.z + a * t
	)--]]

	local posA = cellA.getCellPos()
	local posB = cellB.getCellPos()
	local distanceAB = calcDistance( (posB + posA) / 2, posB, vector.new(x,y,z))

	if cellC ~= nil then
		local posC = cellC.getCellPos()
		local distanceAC = calcDistance( (posC + posA) / 2, posC, vector.new(x,y,z))
		local distanceBC = calcDistance( (posC + posB) / 2, posC, vector.new(x,y,z))

		if distanceAC <= BUFFER_ZONE_WIDTH / 2 and  distanceAB <= BUFFER_ZONE_WIDTH / 2 and distanceBC <= BUFFER_ZONE_WIDTH / 2 then
			threeCellsGeneratorHanler(mapGenerator, cellA, cellB, cellC, distanceAB, distanceAC, data, index, x, y, z)
			return
		end
	end

	--- If the point is in the buffer zone...
	if distanceAB <= BUFFER_ZONE_WIDTH / 2 then
		--- ... we will smooth out the noise.
		twoCellsGeneratorHanler(mapGenerator, cellA, cellB, distanceAB, data, index, x, y, z)
		return
	else
		--- ... otherwise we will use the nearest cell.
		oneCellGeneratorHandler(mapGenerator, cellA, data, index, x, y, z)
		return
	end

	--- The function must terminate earlier.
	--- The algorithm is based on eliminating options.
	--- If the function execution has reached this point,
	--- it means the algorithm is not taking some situation into account.
	error('If you see this error, something went wrong in the map generation.')
end

---@param minPos      table
---@param maxPos      table
---@param blockseed   number
function MapGen:onMapGenerated(minPos, maxPos, blockseed)
	-- We obtain a generation area for further manipulations
	local voxelManip, eMin, eMax = core.get_mapgen_object("voxelmanip")

	if not self.multinoiseInitialized then
		self:initCellsMultinoise()
	end

	local data = voxelManip:get_data()
	-- local param2_data = voxelManip:get_param2_data()
	local area = VoxelArea:new({MinEdge = eMin, MaxEdge = eMax})

	-- Initial generation: landscape
	for z = minPos.z, maxPos.z do
	for y = minPos.y, maxPos.y do
		local index = area:index(minPos.x, y, z)

		for x = minPos.x, maxPos.x do
			generatorHandler(self, data, index, x, y, z)

			index = index + 1
		end
	end
	end

	-- We make changes back to LVM and recalculate light & liquids
	voxelManip:set_data(data)
	-- voxelManip:set_param2_data(param2_data)
	voxelManip:update_liquids()
	voxelManip:calc_lighting()

	voxelManip:write_to_map()
end

---Run world generation through this mapgen object
---
---Note: only one instance of a `MapGen` class can be running.
function MapGen:run()
	if MapGen.isRunning then
		error('Only one instance of a `MapGen` class can be running.')
	end

	core.register_on_generated(function(...)
		self:onMapGenerated(...)
	end)

	self:initBiomesDiagram()

	MapGen.isRunning = true
end

return MapGen
