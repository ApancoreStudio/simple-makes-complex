local mathAbs,  mathRound,  mathMin,  mathMax
	= math.abs, math.round, math.min, math.max

-- --- MapGen default noises ---

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


local pastNoise2DCalc = {
	---@type MapGen.Triangle?
	triangle = nil,
	---@type number?
	x        = nil,
	---@type number?
	y        = nil,
	noiseValues = {
		---@type number?
		height   = nil,
		---@type number?
		humidity = nil,
		---@type number?
		temp     = nil,
	}
}

local modInfo = Mod.getInfo('smc__core__map_gen')
local require = modInfo.require

---@type MapGen.Layer
local Layer = require('MapGen.Layer')

---@type MapGen.Peak
local Peak = require('MapGen.Peak')

---@type MapGen.Layer.Biome
local Biome = require('MapGen.Layer.Biome')

---@type MapGen.Triangulation
local Triangulation = require('MapGen.Triangulation')

---@type MapGen.Layer.Cavern
local Cavern = require('MapGen.Layer.Cavern')

---@class MapGen
---@field layersByName                table<string, MapGen.Layer>
---@field layersList                  MapGen.Layer[]
---@field peaksMultinoiseInitialized  boolean  Is the fractal noise of the peaks initialized? This is necessary for a one-time noise initialization.
---@field cavernsNoiseInitialized     boolean  TODO: описание
---@field isRunning                   boolean  A static field that guarantees that only one instance of the `MapGen` class will work.
---@field nodeIDs                     table<string, number>
local MapGen = {
	layersByName          = {},
	layersList            = {},
	peaksMultinoiseInitialized = false,
	cavernsNoiseInitialized = false,
	isRunning             = false,
}

---@param nodeIDs  table<string, number>
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



-- --- REGISTRATION METHODS ---

---Mark the world area between two heights as a `MapGen.Layer`.
---
---Note: layers must not overlap.
---@param name  string
---@param minY  number
---@param maxY  number
function MapGen:RegisterLayer(name, minY, maxY)
	-- Layers with the same name cannot exist.
	assert(self.layersByName[name] == nil, ('A layer named `%s` is already registered.'):format(name))

	-- Layers cannot overlap.
	assert(self:getLayerByHeight(minY) == nil and self:getLayerByHeight(maxY) == nil, 'Registered layers must not overlap!')

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
---Mark a peak of the world as a cubic peak by two opposite vertices.
---
---Peaks must be included in layers and may overlap each other.
---@param layerName   string  The name of the layer in which the new peak will be included.
---@param peakPos     vector
---@param multinoise  MapGen.Peak.MultinoiseParams     Noise that will be assigned to the peak and that will influence map generation
---@param groups      table<string, number>?  TODO: описание
function MapGen:registerPeak(layerName, peakPos, multinoise, groups)
	---@type MapGen.Layer
	local layer = self.layersByName[layerName]

	assert(layer ~= nil, ('There is no layer named `%s` registered.'):format(layerName))

	if not layer then
		error('Invalid layer: ' .. layerName)
	end

	--TODO: добавить проверку, что координата ячейки не совпадают
	--TODO: Добавить проверку, что координата ячейки не выходит за границы слоя

	---@type MapGen.Peak
	local peak = Peak:new(peakPos, multinoise, groups)

	layer:addPeak(peak)

	return peak --TODO: временно?
end

---TODO: описание
---@param layerName   string  The name of the layer in which the new peak will be included.
---@param peakPos     vector
---@param multinoise  MapGen.Peak.MultinoiseParams     Noise that will be assigned to the peak and that will influence map generation
---@param groups      table<string, number>?  TODO: описание
function MapGen:register2DPeak(layerName, peakPos, multinoise, groups)
	local _peakPos = table.copy_with_metatables(peakPos)
	_peakPos.y = 0

	if groups == nil then
		groups = {is2d = 1}
	else
		groups.is2d = 1
	end

	self:registerPeak(layerName, _peakPos, multinoise, groups)
end

---TODO: описание
---@param layerName   string  The name of the layer in which the new peak will be included.
---@param multinoise  MapGen.Peak.MultinoiseParams     Noise that will be assigned to the peak and that will influence map generation
---@param peakPoses   vector[]
---@param groups      table<string, number>?  TODO: описание
function MapGen:register2DPeaks(layerName, multinoise, peakPoses, groups)
	for _, peakPos in ipairs(peakPoses) do
		self:register2DPeak(layerName, peakPos, multinoise, groups)
	end
end

---TODO: описание
---@param layerName  string
---@param biomeName  string
---@param def        MapGen.Layer.BiomeDef
function MapGen:registerBiome(layerName, biomeName, def)
	local layer = self.layersByName[layerName]
	assert(layer ~= nil, ('There is no layer named `%s` registered.'):format(layerName))
	assert(layer.biomesByName[biomeName] == nil, ('A biome named `%s` already exists in the `%s` layer.'):format(biomeName, layerName))

	local biome = Biome:new(biomeName, def)

	layer.biomesByName[biomeName] = biome
	table.insert(layer.biomesList, biome)
end

---TODO: описание
---@param layerName       string
---@param cavernName      string
---@param def             MapGen.Layer.CavernDef
function MapGen:registerCavern(layerName, cavernName, def)
	local layer = self.layersByName[layerName]
	assert(layer ~= nil, ('There is no layer named `%s` registered.'):format(layerName))
	assert(layer.cavernsByName[cavernName] == nil, ('A cavern named `%s` already exists in the `%s` layer.'):format(cavernName, layerName))

	local cavern = Cavern:new(cavernName, def)

	layer.cavernsByName[cavernName] = cavern
	table.insert(layer.cavernsList, cavern)
end



-- --- INITIALIZATION METHODS ---

---Initializing layer triangulation.
function MapGen:initLayersTriangultaion()
	---@param layer  MapGen.Layer
	for _, layer in ipairs(self.layersList) do
		layer.trianglesList = Triangulation.triangulate(layer.peaksList)
		-- layer.tetrahedronsList  = Triangulation.tetrahedralize(layer.peaksList)
	end
end

---Initialize peak's noises. This should be called after the map object is loaded.
function MapGen:initPeaksMultinoise()
	---@param layer  MapGen.Layer
	for _, layer in ipairs(self.layersList) do

		---@param peak MapGen.Peak
		for _, peak in ipairs(layer.peaksList) do
			peak:initMultinoise()
		end

	end

	self.peaksMultinoiseInitialized = true
end

---TODO: описаение
function MapGen:initCavernsNoise()
	---@param layer  MapGen.Layer
	for _, layer in ipairs(self.layersList) do

		---@param peak MapGen.Peak
		for _, cavern in ipairs(layer.cavernsList) do
			cavern:initNoise()
		end

	end

	self.cavernsNoiseInitialized = true
end

---Initialization of the biome diagram using the Voronoi method.
function MapGen:initBiomesDiagram()
	---@param layer  MapGen.Layer
	for _, layer in ipairs(self.layersList) do
		layer:initBiomesDiagram()
	end
end



-- --- GENERATION METHODS ---

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

---@param layer  MapGen.Layer
---@param x      number
---@param y      number
---@param z      number
---@return       boolean
local function isCavern(layer, x, y, z)
	for _, cavern in ipairs(layer.cavernsList) do
		if cavern:isCavern(x, y, z) then
			return true
		end
	end

	return false
end

---@param mapGenerator  MapGen
---@param layer         MapGen.Layer
---@param height         number
---@param temp          number
---@param humidity      number
---@param data          number[]
---@param index         number
---@param x             number
---@param y             number
---@param z             number
local function generateNode(mapGenerator, layer, height, temp, humidity, data, index, x, y, z)
	local ids =  mapGenerator.nodeIDs

	local m = math.random(-5, 5)

	temp     = mathMin(100, mathMax(0, temp     + m))
	humidity = mathMin(100, mathMax(0, humidity + m))
	--height   = mathMin(layer.maxY, mathMax(layer.minY, y + m))

	local biome = layer.biomesDiagram[y][mathRound(temp)][mathRound(humidity)]

	if y > height and y > 0 then
		data[index] = ids.air
	elseif y > height and y <= 0 then
		data[index] = ids.water
	elseif y <= height then
		if isCavern(layer, x, y, z) then
			data[index] = ids.air
		elseif y == height then
			generateSoil(biome, data, index, x, y, z)
		else
			generateRock(ids, data, index, x, y, z)
		end
	else
		data[index] = ids.air
		-- TODO: добавить error
	end
end

---@param height  MapGen.Triangulation.Edge
---@param x       number
---@param y       number
---@param z       number
---@return        number
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

---@param px        number
---@param pz        number
---@param triangle  MapGen.Triangle
local function pointInTriangle(px, pz, triangle)
	local posP = vector.new(px, 0, pz)
	local pos1 = triangle.p1.getPeakPos()
	local pos2 = triangle.p2.getPeakPos()
	local pos3 = triangle.p3.getPeakPos()

	local v0 = pos3 - pos1
	local v1 = pos2 - pos1
	local v2 = posP - pos1

	local dot00 = vector.dot(v0, v0)
	local dot01 = vector.dot(v0, v1)
	local dot02 = vector.dot(v0, v2)
	local dot11 = vector.dot(v1, v1)
	local dot12 = vector.dot(v1, v2)

	local invDenom = 1 / (dot00 * dot11 - dot01 * dot01)
	local u = (dot11 * dot02 - dot01 * dot12) * invDenom
	local v = (dot00 * dot12 - dot01 * dot02) * invDenom

	return (u >= 0) and (v >= 0) and (u + v <= 1)
end

---@param triangle  MapGen.Triangle
---@param x         number
---@param y         number
---@param z         number
---@return          number, number, number
local function calcNoises2dValues(triangle, x, y, z)
	local peak1 = triangle.p1
	local peak2 = triangle.p2
	local peak3 = triangle.p3

	local noiseHeightValue   = 0.0
	local noiseTempValue     = 0.0
	local noiseHumidityValue = 0.0

	local totalWeight = 0.0

	-- We calculate the noise value using the smoothing formula:
	-- ( peak1 * weight1 + peak2 * weight2 + peak3 * weight3) / totalWeight, when
	-- totalWeight = weight1 + weight2 + weight3
	local weight = calcWeight(triangle.h1, x, y, z)
	noiseHeightValue   = noiseHeightValue   + peak1:getMultinoise().landscapeNoise:get_2d({x = x, y = z}) * weight
	noiseTempValue     = noiseTempValue     + peak1:getMultinoise().tempNoise:get_2d({x = x, y = z})      * weight
	noiseHumidityValue = noiseHumidityValue + peak1:getMultinoise().humidityNoise:get_2d({x = x, y = z})  * weight
	totalWeight = totalWeight + weight

	weight = calcWeight(triangle.h2, x, y, z)
	noiseHeightValue   = noiseHeightValue   + peak2:getMultinoise().landscapeNoise:get_2d({x = x, y = z}) * weight
	noiseTempValue     = noiseTempValue     + peak2:getMultinoise().tempNoise:get_2d({x = x, y = z})      * weight
	noiseHumidityValue = noiseHumidityValue + peak2:getMultinoise().humidityNoise:get_2d({x = x, y = z})  * weight
	totalWeight = totalWeight + weight

	weight = calcWeight(triangle.h3, x, y, z)
	noiseHeightValue   = noiseHeightValue   + peak3:getMultinoise().landscapeNoise:get_2d({x = x, y = z}) * weight
	noiseTempValue     = noiseTempValue     + peak3:getMultinoise().tempNoise:get_2d({x = x, y = z})      * weight
	noiseHumidityValue = noiseHumidityValue + peak3:getMultinoise().humidityNoise:get_2d({x = x, y = z})  * weight
	totalWeight = totalWeight + weight

	return mathRound(noiseHeightValue / totalWeight), mathRound(noiseTempValue / totalWeight), mathRound(noiseHumidityValue / totalWeight)
end

---Calculates a smoothed 2D noise value based on a preliminary space partitioning.
---
---Returns `nil` if the point is not included in any triangle.
---@param layer  MapGen.Layer
---@param x      number
---@param y      number
---@param z      number
---@return       number?, number?, number?
function MapGen:getNoises2dValues(layer, x, y, z)
	if (pastNoise2DCalc.x ~= nil and pastNoise2DCalc.z ~= nil) and (x == pastNoise2DCalc.x and z == pastNoise2DCalc.z) then
		return pastNoise2DCalc.noiseValues.height, pastNoise2DCalc.noiseValues.temp, pastNoise2DCalc.noiseValues.humidity
	end

	if pastNoise2DCalc.triangle ~= nil and pointInTriangle(x, z, pastNoise2DCalc.triangle) then
		local noiseHeightValue, noiseTempValue, noiseHumidityValue = calcNoises2dValues(pastNoise2DCalc.triangle, x, y, z)

		pastNoise2DCalc.x = x
		pastNoise2DCalc.z = z
		pastNoise2DCalc.noiseValues = {
			height   = noiseHeightValue,
			temp     = noiseTempValue,
			humidity = noiseHumidityValue,
		}

		return noiseHeightValue, noiseTempValue, noiseHumidityValue
	end

	---@param triangle  MapGen.Triangle
	for _, triangle in ipairs(layer.trianglesList) do
		if pointInTriangle(x, z,triangle) then
			local noiseHeightValue, noiseTempValue, noiseHumidityValue = calcNoises2dValues(triangle, x, y, z)

			pastNoise2DCalc.triangle = triangle
			pastNoise2DCalc.x = x
			pastNoise2DCalc.z = z
			pastNoise2DCalc.noiseValues = {
				height   = noiseHeightValue,
				temp     = noiseTempValue,
				humidity = noiseHumidityValue,
			}

			return noiseHeightValue, noiseTempValue, noiseHumidityValue
		end
	end

	-- If the point does not fall within the triangle, it is impossible to calculate the height.
	-- For debugging purposes only, may slow down generation:
	--core.log('warning', string.format('The point %s %s %s does not fall within any triangle, calculating the noise value is impossible.', tostring(x), tostring(y), tostring(z)))
end

--[[
3D noise smoothing is too slow, so it was decided to stop using it.

---@param P vector
---@param A vector
---@param B vector
---@param C vector
local function pointInTetrahedron(P, A, B, C, D)
	local function det3(a, b, c)
		return a.x * (b.y * c.z - b.z * c.y)
			 - a.y * (b.x * c.z - b.z * c.x)
			 + a.z * (b.x * c.y - b.y * c.x)
	end

	local v0 = B - A
	local v1 = C - A
	local v2 = D - A
	local v3 = P - A

	local d = det3(v0, v1, v2)

	local u = det3(v3, v1, v2) / d
	local v = det3(v0, v3, v2) / d
	local w = det3(v0, v1, v3) / d

	return (u >= 0 and v >= 0 and w >= 0 and (u + v + w) <= 1)
end

---Calculates a smoothed 3D noise value based on a preliminary space partitioning.
---
---Returns `nil` if the point is not included in any tetrahedron.
---
---@param layer     MapGen.Layer
---@param x         number
---@param y         number
---@param z         number
---@return          number?
function MapGen:getNoises3dValues(layer, x, y, z)
	---@param triangle  MapGen.Tetrahedron
	for _, tetrahedron in ipairs(layer.tetrahedronsList) do
		local peak1 = tetrahedron.p1
		local peak2 = tetrahedron.p2
		local peak3 = tetrahedron.p3
		local peak4 = tetrahedron.p4

		local pos1 = peak1:getPeakPos()
		local pos2 = peak2:getPeakPos()
		local pos3 = peak3:getPeakPos()
		local pos4 = peak4:getPeakPos()

		-- If the point is in the tetrahedron defined by the `MapGen.Peak`...
		if pointInTetrahedron(
			vector.new(x, y, z),
			pos1,
			pos2,
			pos3,
			pos4
		)
		then
			local noiseValue = 0.0

			local totalWeight = 0.0

			-- ... we calculate the height for this point using smoothing.
			local weight = calcWeight(tetrahedron.h1, x, y, z)
			noiseValue = noiseValue + peak1:getMultinoise().someNoise:get_3d({x = x, y = y, z = z}) * weight
			totalWeight = totalWeight + weight

			weight = calcWeight(tetrahedron.h2, x, y, z)
			noiseValue = noiseValue + peak1:getMultinoise().someNoise:get_3d({x = x, y = y, z = z}) * weight
			totalWeight = totalWeight + weight

			weight = calcWeight(tetrahedron.h3, x, y, z)
			noiseValue = noiseValue + peak2:getMultinoise().someNoise:get_3d({x = x, y = y, z = z}) * weight
			totalWeight = totalWeight + weight

			weight = calcWeight(tetrahedron.h4, x, y, z)
			noiseValue = noiseValue + peak3:getMultinoise().someNoise:get_2d({x = x, y = y, z = z}) * weight
			totalWeight = totalWeight + weight

			return mathRound(noiseValue / totalWeight)
		end
	end

	-- If the point does not fall within the tetrahedron, it is impossible to calculate the height.
	-- For debugging purposes only, may slow down generation:
	-- core.log('warning', string.format('The point %s %s %s does not fall within any tetrahedron, calculating the noise value is impossible.', tostring(x), tostring(y), tostring(z)))
end
--]]

---@param mapGenerator  MapGen
---@param data          number[]
---@param index         number
---@param x             number
---@param y             number
---@param z             number
local function generatorHandler(mapGenerator, data, index, x, y, z)
	-- If generation occurs outside the layers, then a void is generated.
	local layer = mapGenerator:getLayerByHeight(y)
	if layer == nil then
		data[index] = mapGenerator.nodeIDs.air

		return
	end

	-- Calculating landscape height
	local noiseHeightValue, noiseTempValue, noiseHumidityValue = mapGenerator:getNoises2dValues(layer, x, y, z)

	-- If the height of the landscape is zero,
	-- then the point does not fall within any of the triangles.
	if noiseHeightValue == nil then
		noiseHeightValue   = 0.0
		noiseTempValue     = 0.0
		noiseHumidityValue = 0.0
	end

	---@diagnostic disable-next-line: param-type-not-match
	generateNode(mapGenerator, layer,  noiseHeightValue, noiseTempValue, noiseHumidityValue, data, index, x, y, z)
end

---@param voxelManip  VoxelManip
---@param minPos      table
---@param maxPos      table
---@param blockseed   number
function MapGen:onMapGenerated(voxelManip, minPos, maxPos, blockseed)
	-- We obtain a generation area for further manipulations
	--local voxelManip, eMin, eMax = core.get_mapgen_object('voxelmanip')

	local eMin, eMax = voxelManip:get_emerged_area()

	if not self.peaksMultinoiseInitialized then
		self:initPeaksMultinoise()
	end

	if not self.cavernsNoiseInitialized then
		self:initCavernsNoise()
	end

	local data = voxelManip:get_data()
	-- local param2_data = voxelManip:get_param2_data()
	local area = VoxelArea:new({MinEdge = eMin, MaxEdge = eMax})

	data[area:index(0,50,0)] = core.get_content_id('rocks:malachite')

	local index
	-- Initial generation: landscape
	for z = minPos.z, maxPos.z do
		for x = minPos.x, maxPos.x do
			for y = minPos.y, maxPos.y do
				index = area:index(x, y, z)

				if data[index] == core.CONTENT_AIR then
					generatorHandler(self, data, index, x, y, z)
				end
			end
		end
	end

	-- We make changes back to LVM and recalculate light & liquids
	voxelManip:set_data(data)
	--voxelManip:set_param2_data()
	voxelManip:set_lighting({ day = 14, night = 0})
	voxelManip:calc_lighting()
	voxelManip:update_liquids()

	--voxelManip:write_to_map() -- Async edit
end



-- --- OTHER ---

---Run world generation through this mapgen object
---
---Note: only one instance of a `MapGen` class can be running.
---
---**FOR MAPGEN ENVIRONMENT ONLY**
function MapGen:run()
	if MapGen.isRunning then
		error('Only one instance of a `MapGen` class can be running.')
	end

	core.register_on_generated(function(...)
		-- TODO: удалить отключение проверки после исправления issue:
		-- https://github.com/Voxrame/luanti-ide-helper/issues/6
		---@diagnostic disable-next-line: param-type-not-match
		self:onMapGenerated(...)
	end)

	self:initBiomesDiagram()
	self:initLayersTriangultaion()

	MapGen.isRunning = true
end

return MapGen
