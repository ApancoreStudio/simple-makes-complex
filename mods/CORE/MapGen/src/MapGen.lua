local mathCeil,  mathAbs,  mathRound,  mathMin
	= math.ceil, math.abs, math.round, math.min

local BUFFER_ZONE_WIDTH = 3000
local MAX_DISTANCE = 3000

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

---@type MapGen.Peak
local Peak = require("MapGen.Peak")

---@type MapGen.Biome
local Biome = require("MapGen.Biome")

---@type MapGen.Triangulation
local Triangulation = require("MapGen.Triangulation")

---@class MapGen
---@field layersByName           table
---@field layersList             table
---@field biomesList             table
---@field biomesDiagram          table
---@field multinoiseInitialized  boolean  Is the fractal noise of the peaks initialized? This is necessary for a one-time noise initialization.
---@field isRunning              boolean  A static field that guarantees that only one instance of the `MapGen` class will work.
---@field nodeIDs                table<string, number>
local MapGen = {
	layersByName          = {},
	layersList            = {},
	biomesList            = {},
	biomesDiagram         = {},
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

function MapGen:initLayersTrianglesList()
	---@param layer  MapGen.Layer
	for _, layer in ipairs(self.layersList) do
		print('A: ', #layer.peaksList)
		layer.trianglesList = Triangulation.triangulate(layer.peaksList)
		print('ABOBA:', dump(layer.trianglesList))
	end
end

-- TODO: переписать описание функции
---Mark a peak of the world as a cubic peak by two opposite vertices.
---
---Peaks must be included in layers and may overlap each other.
---@param layerName     string  The name of the layer in which the new peak will be included.
---@param peakPos        vector
---@param multinoise    MapGen.Peak.MultinoiseParams     Noise that will be assigned to the peak and that will influence map generation
---@param peakIs2D    boolean?  If true, the transmitted Y coordinate will be overwritten by the layer boundaries.
---@param weightFactor  number?   The coefficient by which the reduction in the impact of peakal noise on generation will be calculated. If 0, there will be no reduction.
function MapGen:RegisterPeak(layerName, peakPos, multinoise, peakIs2D, weightFactor)
	---@type MapGen.Layer
	local layer = self.layersByName[layerName]

	if not layer then
		error("Invalid layer: " .. layerName)
	end

	-- TODO: вероятно стоит убрать 2D ячейки
	if peakIs2D then
		peakPos.y = 0
	end

	--TODO: добавить проверку, что координата ячейки не совпадают
	--TODO: Добавить проверку, что координата ячейки не выходит за границы слоя

	-- TODO: вероятно стоит убрать вес
	if weightFactor == nil then
		weightFactor = 1
	end

	---@type MapGen.Peak
	local peak = Peak:new(peakPos, multinoise, weightFactor)

	layer:addPeak(peak)

	return peak --TODO: временно?
end

---Initialize peak noise. This should be called after the map object is loaded.
function MapGen:initPeaksMultinoise()
	---@param layer  MapGen.Layer
	for _, layer in ipairs(self.layersList) do

		---@param peak MapGen.Peak
		for _, peak in ipairs(layer.peaksList) do
			peak:initMultinoise()
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
---the distance of the point from the center of the peak.
---
---If the `weightFactor` is `0`, then the peak's
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

	local biome = mapGenerator.biomesDiagram[mathRound(temp)][mathRound(humidity)]

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

---@param px         number
---@param py         number
---@param x1         number
---@param y1         number
---@param x2         number
---@param y2         number
---@param x3         number
---@param y3         number
local function pointInTriangle(px, py, x1, y1, x2, y2, x3, y3)
	-- Function for calculating the vector product
	local function crossProduct(ax, ay, bx, by)
		return ax * by - ay * bx
	end

	-- Vectors from vertices to a point and between vertices
	local d1 = crossProduct(x2 - x1, y2 - y1, px - x1, py - y1)
	local d2 = crossProduct(x3 - x2, y3 - y2, px - x2, py - y2)
	local d3 = crossProduct(x1 - x3, y1 - y3, px - x3, py - y3)

	-- Checking the signs of vector products
	local has_positive = (d1 > 0) or (d2 > 0) or (d3 > 0)
	local has_negative = (d1 < 0) or (d2 < 0) or (d3 < 0)

	-- Dot inside if all products have the same sign
	return not (has_positive and has_negative)
end

---@param height  MapGen.Triangulation.Edge
---@param x         number
---@param y         number
---@param z         number
---@return          number
local function calcWeight(height, x, y, z)
	local pos1 = vector.new(x, y, z)
	local pos2 = height.p1:getPeakPos()
	local pos3 = height.p2:getPeakPos()

	local v = pos3 - pos2
	---@type vector
	local w = pos1 - pos2

	-- Formula: (w * v) / (v * v)
	-- When * the dot product.
	local t = w:dot(v) / v:dot(v)

	local posP = pos2 + v * t

	return 1 - vector.distance(pos2, posP) / height:length()
end

---Calculates the height of the landscape based
---on a pre-triangulated plane stored in a layer.
---
---Returns `nil` if the point is not included in any triangle.
---@param layer     MapGen.Layer
---@param x         number
---@param y         number
---@param z         number
---@return          number?
function MapGen:getNoiseHeightValue(layer, x, y, z)
	---@param triangle  MapGen.Triangle
	for _, triangle in ipairs(layer.trianglesList) do
		local peak1 = triangle.p1
		local peak2 = triangle.p2
		local peak3 = triangle.p3

		local pos1 = peak1:getPeakPos()
		local pos2 = peak2:getPeakPos()
		local pos3 = peak3:getPeakPos()

		-- If the point is in the triangle defined by the `MapGen.Peak`...
		if pointInTriangle(
			x, z,
			pos1.x, pos1.z,
			pos2.x, pos2.z,
			pos3.x, pos3.z
		)
		then
			local noiseHeightValue = 0.0

			local totalWeight = 0.0
			-- ... we calculate the height for this point using smoothing.
			-- We calculate the height value using the smoothing formula:
			-- ( peak1 * weight1 + peak2 * weight2 + peak3 * weight3) / totalWeight, when
			-- totalWeight = weight1 + weight2 + weight3
			local weight = calcWeight(triangle.h1, x, y, z)
			noiseHeightValue = noiseHeightValue + peak1:getMultinoise().landscapeNoise:get_2d({x = x, y = z}) * weight
			totalWeight = totalWeight + weight

			weight = calcWeight(triangle.h2, x, y, z)
			noiseHeightValue = noiseHeightValue + peak2:getMultinoise().landscapeNoise:get_2d({x = x, y = z}) * weight
			totalWeight = totalWeight + weight

			weight = calcWeight(triangle.h3, x, y, z)
			noiseHeightValue = noiseHeightValue + peak3:getMultinoise().landscapeNoise:get_2d({x = x, y = z}) * weight
			totalWeight = totalWeight + weight

			-- The height must be an integer value
			-- because the world is made up of whole blocks.
			return mathRound(noiseHeightValue / totalWeight)
		end
	end

	-- If the point does not fall within the triangle, it is impossible to calculate the height.
	-- For debugging purposes only, may slow down generation:
	--core.log('warning', string.format('The point %s %s %s does not fall within any triangle, calculating the height of the landscape is impossible.', tostring(x), tostring(y), tostring(z)))
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

	-- Calculating landscape height
	local noiseHeightValue = mapGenerator:getNoiseHeightValue(layer, x, y, z)

	if noiseHeightValue == nil then
		noiseHeightValue = 0.0
	end

	local noiseTempValue     = 0.0
	local noiseHumidityValue = 0.0

	generateNode(mapGenerator, noiseHeightValue, noiseTempValue, noiseHumidityValue, data, index, x, y, z)
end

---@param minPos      table
---@param maxPos      table
---@param blockseed   number
function MapGen:onMapGenerated(minPos, maxPos, blockseed)
	-- We obtain a generation area for further manipulations
	local voxelManip, eMin, eMax = core.get_mapgen_object("voxelmanip")

	if not self.multinoiseInitialized then
		self:initPeaksMultinoise()
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
	self:initLayersTrianglesList()

	MapGen.isRunning = true
end

return MapGen
