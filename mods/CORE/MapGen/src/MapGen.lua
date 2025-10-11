local modInfo = Mod.getInfo()
local require = modInfo.require

local InterpolationPresets = require("MapGen.InterpolationPresets")
local Layer = require("MapGen.Layer")
local Region = require("MapGen.Region")
local Biome = require("MapGen.Biome")

local mathRound, mathHuge
	= math.round, math.huge

-- --- MapGen default noises ---
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

---DEBUG NOISES
--- TODO удалить, после реализации климата от регионов
---@type ValueNoise
local humidityNoise

---@type NoiseParams
humidityNoiseParams = {
	offset = 50,
	scale = 25,
	spread = {x = 10, y = 10, z = 10},
	seed = 47,
	octaves = 2,
	persistence = 0.6,
	lacunarity = 2,
}

---@type ValueNoise
local tempNoise

---@type NoiseParams
tempNoiseParams = {
	offset = 50,
	scale = 25,
	spread = {x = 10, y = 10, z = 10},
	seed = 12,
	octaves = 2,
	persistence = 0.6,
	lacunarity = 2,
}

-- --- End of default noises ---


---@class MapGen
---@field layersByName           table
---@field layersList             table
---@field biomesList             table
---@field biomesDiagram           table
---@field multinoiseInitialized  boolean  Is the fractal noise of the regions initialized? This is necessary for a one-time noise initialization.
---@field isRunning              boolean  A static field that guarantees that only one instance of the `MapGen` class will work.
---@field nodeIDs                table<string, string>
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

---Mark a region of the world as a cubic region by two opposite vertices.
---
---Regions must be included in layers and may overlap each other.
---@param regionName           string
---@param layerName            string                          Name of the layer in which the new region will be contained.
---@param polyhedron           Polyhedron
---@param multinoiseParams     MapGen.Region.MultinoiseParams  Noise that will be assigned to the region and that will influence map generation
---@param bufferZone           MapGen.Region.BufferZone                          
function MapGen:RegisterRegion(regionName, layerName, polyhedron, multinoiseParams, bufferZone)
	local interpolationPreset = bufferZone.preset or "linear"
	local layer = self.layersByName[layerName]
	if not layer then error("Invalid layer: " .. layerName) end

	-- Check for intersections with existing regions
	for _, existingRegion in ipairs(layer.regionsList) do
		if polyhedron:intersects(existingRegion:getPolyhedron()) then
			error("Regions cannot intersect! Region '" .. regionName .. "' intersects with existing region.")
		end
	end

	local region = Region:new(polyhedron, multinoiseParams, bufferZone)
	layer:addRegion(region)
end

---Initialize region noise. This should be called after the map object is loaded.
function MapGen:initRegionsMultinoise()
	---@param layer  MapGen.Layer
	for _, layer in ipairs(self.layersList) do

		---@param region MapGen.Region
		for _, region in ipairs(layer.regionsList) do
			region:initMultinoise()
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
			local minDistance = mathHuge
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

local function generateSoil(biome, data, index, x, y, z)
	data[index] = core.get_content_id(biome.groundNodes.turf)  -- TODO: убрать тут get_content_id(), переместить его куда-то "выше"
end

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
local function generatorHandler3D(mapGenerator, data, index, x, y, z)
	local layer = mapGenerator:getLayerByHeight(y)
	if layer == nil then
		data[index] = mapGenerator.nodeIDs.air
		return
	end

	-- Initialize base noises if needed
	if oceanNoise == nil then oceanNoise = core.get_value_noise(oceanNoiseParams) end
	if tempNoise == nil then tempNoise = core.get_value_noise(tempNoiseParams) end
	if humidityNoise == nil then humidityNoise = core.get_value_noise(humidityNoiseParams) end

	-- Base values (outside any region)
	local baseHeight = oceanNoise:get_3d({x = x, y = y, z = z})
	local baseTemp = tempNoise:get_3d({x = x, y = y, z = z})
	local baseHumidity = humidityNoise:get_3d({x = x, y = y, z = z})

	local finalHeight = baseHeight
	local finalTemp = baseTemp
	local finalHumidity = baseHumidity

	local region = layer:getRegionByPos(x, y, z)
	local polyhedron = region:getPolyhedron()
	local distance = polyhedron:distanceToSurface(vector.new(x, y, z))
	local bufferZone = region:getBufferZone()
	
	if distance <= bufferZone.thickness then
		local regionNoises = region:getMultinoise()
		local blendFactor = InterpolationPresets[region:getInterpolationPreset()](distance, bufferZone.thickness)
		
		-- 3D noise interpolation
		if regionNoises.landscapeNoise then
			local regionHeight = regionNoises.landscapeNoise:get_3d({x = x, y = y, z = z})
			finalHeight = baseHeight + (regionHeight - baseHeight) * blendFactor
		end
		
		if regionNoises.tempNoise then
			local regionTemp = regionNoises.tempNoise:get_3d({x = x, y = y, z = z})
			finalTemp = baseTemp + (regionTemp - baseTemp) * blendFactor
		end
		
		if regionNoises.humidityNoise then
			local regionHumidity = regionNoises.humidityNoise:get_3d({x = x, y = y, z = z})
			finalHumidity = baseHumidity + (regionHumidity - baseHumidity) * blendFactor
		end
	end

	generateNode(mapGenerator, mathRound(finalHeight), mathRound(finalTemp), 
				 mathRound(finalHumidity), data, index, x, y, z)
end

---@param minPos      table
---@param maxPos      table
---@param blockseed   number
function MapGen:onMapGenerated(minPos, maxPos, blockseed)
	-- We obtain a generation area for further manipulations
	local voxelManip, eMin, eMax = core.get_mapgen_object("voxelmanip")

	if not self.multinoiseInitialized then
		self:initRegionsMultinoise()
	end

	local data = voxelManip:get_data()
	-- local param2_data = voxelManip:get_param2_data()
	local area = VoxelArea:new({MinEdge = eMin, MaxEdge = eMax})

	-- Initial generation: landscape
	for z = minPos.z, maxPos.z do
	for y = minPos.y, maxPos.y do
		local index = area:index(minPos.x, y, z)

		for x = minPos.x, maxPos.x do
			generatorHandler3D(self, data, index, x, y, z)

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
