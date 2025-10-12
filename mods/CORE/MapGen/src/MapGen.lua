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
-- --- End of default noises ---


---@class MapGen
---@field layersByName             table
---@field layersList               table
---@field biomesList               table
---@field biomesDiagram            table
---@field isMultinoiseInitialized  boolean  Is the fractal noise of the regions initialized? This is necessary for a one-time noise initialization.
---@field isRunning                boolean  A static field that guarantees that only one instance of the `MapGen` class will work.
---@field nodeIDs                  table<string, number>
local MapGen = {
	layersByName            = {},
	layersList              = {},
	biomesList              = {},
	biomesDiagram           = {},
	isMultinoiseInitialized = false,
	isRunning               = false,
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

function MapGen:getLayerByHeight(yPos)
	for _, layer in ipairs(self.layersList) do
		if yPos >= layer.minY and yPos <= layer.maxY then
			return layer
		end
	end
	return nil
end

---Mark the world area between two heights as a `MapGen.Layer`.
---
---Note: layers must not overlap.
---@param name  string
---@param minY  number
---@param maxY  number
function MapGen:RegisterLayer(name, minY, maxY)
	---Checking if layers overlap
	if self:getLayerByHeight(minY) ~= nil or self:getLayerByHeight(maxY) ~= nil then
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
	-- Generate rocks noise once
	rocksNoise = core.get_value_noise(rocksNoiseParams)
	
	for _, layer in ipairs(self.layersList) do
		print("INIT DEFAULT NOISES")
		layer.defaultRegion:initMultinoise()
		
		for _, region in ipairs(layer.regionsList) do
			region:initMultinoise()
		end
	end
	self.isMultinoiseInitialized = true
end

-- Precompute noise for entire chunk
local function precomputeNoiseForChunk(noise, minPos, maxPos)
	local noiseMap = {}
	local index = 1
	for z = minPos.z, maxPos.z do
		for y = minPos.y, maxPos.y do
			for x = minPos.x, maxPos.x do
				noiseMap[index] = mathRound(noise:get_3d(vector.new(x, y, z)))
				index = index + 1
			end
		end
	end
	return noiseMap
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

function MapGen:precomputeNodeIDs()
	for _, biome in ipairs(self.biomesList) do
		biome.groundNodes.turf = self.nodeIDs[biome.groundNodes.turf] or biome.groundNodes.turf
		biome.groundNodes.soil = self.nodeIDs[biome.groundNodes.soil] or biome.groundNodes.soil
	end
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

local function generateSoil(biome, data, index, pos)
	data[index] = biome.groundNodes.turf
end

local function generateRock(ids, data, index, pos)

	if rocksNoise == nil then
		rocksNoise = core.get_value_noise(rocksNoiseParams)
	end

	local noiseRocksValue = mathRound(rocksNoise:get_3d(pos))
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

function MapGen:generateNode(self, hight, temp, humidity, data, index, pos)
	local ids =  self.nodeIDs

	local biome = self.biomesDiagram[temp][humidity]

	if pos.y > hight and pos.y > 0 then
		data[index] = ids.air
	elseif pos.y == hight and pos.y > 0 then
		generateSoil(biome, data, index, pos)
	elseif pos.y < hight then
		generateRock(ids, data, index, pos)
	else
		data[index] = ids.water
	end
end


-- КАРОЧИ. Надо оптимизировать вот это говно. Оно срабатывает для каждого блока и поэтому все так лагаетю
function MapGen:generateVoxelOptimized(data, index, pos, layer, rocksNoiseMap, area, minPos, maxPos)
	-- Fast region lookup with spatial partitioning
	local region = layer:getRegionByPos(pos)
	
	-- Get base values from default region
	local defaultRegion = layer:getDefaultRegion()
	local defaultNoises = defaultRegion:getMultinoise()
	
	local baseHeight = defaultNoises.landscapeNoise:get_3d(pos)
	local baseTemp = defaultNoises.tempNoise:get_3d(pos)
	local baseHumidity = defaultNoises.humidityNoise:get_3d(pos)
	
	local finalHeight = baseHeight
	local finalTemp = baseTemp
	local finalHumidity = baseHumidity
	
	-- Apply region-specific noises if needed
	if region ~= defaultRegion then
		local polyhedron = region:getPolyhedron()
		local distance = polyhedron:distanceToSurface(pos)
		local bufferZone = region:getBufferZone()
		
		if distance <= bufferZone.thickness then
			local regionNoises = region:getMultinoise()
			local blendFactor = InterpolationPresets[region:getInterpolationPreset()](distance, bufferZone.thickness)
			
			if regionNoises.landscapeNoise then
				local regionHeight = regionNoises.landscapeNoise:get_3d(pos)
				finalHeight = baseHeight + (regionHeight - baseHeight) * blendFactor
			end
			
			if regionNoises.tempNoise then
				local regionTemp = regionNoises.tempNoise:get_3d(pos)
				finalTemp = baseTemp + (regionTemp - baseTemp) * blendFactor
			end
			
			if regionNoises.humidityNoise then
				local regionHumidity = regionNoises.humidityNoise:get_3d(pos)
				finalHumidity = baseHumidity + (regionHumidity - baseHumidity) * blendFactor
			end
		end
	end
	
	-- Generate the actual node
	self:generateNodeOptimized(mathRound(finalHeight), mathRound(finalTemp),
							  mathRound(finalHumidity), data, index, pos, rocksNoiseMap, minPos, maxPos)
end

function MapGen:generateNodeOptimized(height, temp, humidity, data, index, pos, rocksNoiseMap, minPos, maxPos)
	local ids = self.nodeIDs
	local biome = self.biomesDiagram[temp][humidity]
	
	if pos.y > height and pos.y > 0 then
		data[index] = ids.air
	elseif pos.y == height and pos.y > 0 then
		data[index] = biome.groundNodes.turf
	elseif pos.y < height then
		-- Calculate index without creating vectors
		local noiseIndex = ((pos.z - minPos.z) * (maxPos.y - minPos.y + 1) * (maxPos.x - minPos.x + 1) +
						   (pos.y - minPos.y) * (maxPos.x - minPos.x + 1) +
						   (pos.x - minPos.x)) + 1
		local noiseValue = rocksNoiseMap[noiseIndex]
		
		-- Use lookup table for rock types
		local rockTypes = {
			[1] = ids.malachite, [2] = ids.hapcoryte, [3] = ids.iyellite,
			[4] = ids.sylite, [5] = ids.tauitite, [6] = ids.falmyte,
			[7] = ids.burcite, [8] = ids.felhor
		}
		
		data[index] = rockTypes[noiseValue] or ids.stone
	else
		data[index] = ids.water
	end
end

---@param minPos      table
---@param maxPos      table
---@param blockseed   number
function MapGen:onMapGenerated(minPos, maxPos, blockseed)
	print("Stage 1: entering loop")

	local voxelManip, eMin, eMax = core.get_mapgen_object("voxelmanip")
	local data = voxelManip:get_data()
	-- local param2_data = voxelManip:get_param2_data()	
	local area = VoxelArea:new({MinEdge = eMin, MaxEdge = eMax})

	
	print("Stage 2: generating initial landscape")

	-- Cache frequently accessed values
	local nodeIDs = self.nodeIDs
	local biomesDiagram = self.biomesDiagram

	-- Precompute rocks noise for entire chunk
	local rocksNoiseMap = precomputeNoiseForChunk(rocksNoise, minPos, maxPos)

	local vec = vector.zero()
	local areaIndex = area.index

	-- Process by layers to minimize context switching
	local a, b, c, d = 0, 0, 0, 0
	for _, layer in ipairs(self.layersList) do
		a = a+1
		b, c, d = 0, 0, 0
		local layerMinY = math.max(minPos.y, layer.minY)
		local layerMaxY = math.min(maxPos.y, layer.maxY)
		
		if layerMinY <= layerMaxY then
			for z = minPos.z, maxPos.z do
				b = b+1
				c, d = 0, 0
				vec.z = z
				for y = layerMinY, layerMaxY do
					c = c+1
					d = 0
					vec.y = y
					local index = areaIndex(area, minPos.x, y, z)
					
					for x = minPos.x, maxPos.x do
						d = d+1
						vec.x = x
						self:generateVoxelOptimized(data, index, vec, layer, rocksNoiseMap, area, minPos, maxPos)
						index = index + 1
						print(a..":"..b..":"..c..":"..d)
					end
				end
			end
		end
	end

	print("Stage 3: applying changes")
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

	-- Initialize default systems
	self:precomputeNodeIDs()
	self:initBiomesDiagram()

	core.register_on_generated(function(...)
		if not self.isMultinoiseInitialized then
			self:initRegionsMultinoise()
		end

		self:onMapGenerated(...)
	end)

	MapGen.isRunning = true
end

return MapGen
