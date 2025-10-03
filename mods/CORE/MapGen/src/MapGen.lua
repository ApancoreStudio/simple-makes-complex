local mathCeil,  mathAbs
	= math.ceil, math.abs

-- --- MapGen default moises ---
local oceanNoise

local oceanNoiseParams = {
	offset = -30,
	scale = 10,
	spread = {x = 100, y = 100, z = 100},
	seed = 47,
	octaves = 8,
	persistence = 0.4,
	lacunarity = 2,
}
-- --- End default noises ---

local modInfo = Mod.getInfo()
local require = modInfo.require

---@type MapGen.Layer
local Layer = require("MapGen.Layer")

---@type MapGen.Region
local Region = require("MapGen.Region")

---@class MapGen
---@field layersByName           table
---@field layersList             table
---@field multinoiseInitialized  boolean  Is the fractal noise of the regions initialized? This is necessary for a one-time noise initialization.
---@field isRunning              boolean  A static field that guarantees that only one instance of the `MapGen` class will work.
---@field nodeIDs                table<string, string>
local MapGen = {
	layersByName          = {},
	layersList            = {},
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
---@param layerName     string  The name of the layer in which the new region will be included.
---@param minPos        vector
---@param maxPos        vector
---@param multinoise    table     Noise that will be assigned to the region and that will influence map generation
---@param regionIs2D    boolean?  If true, the transmitted Y coordinate will be overwritten by the layer boundaries.
---@param weightFactor  number?   The coefficient by which the reduction in the impact of regional noise on generation will be calculated. If 0, there will be no reduction.
function MapGen:RegisterRegion(layerName, minPos, maxPos, multinoise, regionIs2D, weightFactor)
	---@type MapGen.Layer
	local layer = self.layersByName[layerName]

	if not layer then
		error("Invalid layer: " .. layerName)
	end

	if regionIs2D then
		minPos.y = layer.minY
		maxPos.y = layer.maxY
	end

	--TODO: Добавить проверку, что регион не выходит за границы слоя или/и автоматически обрубать регион до слоя

	if weightFactor == nil then
		weightFactor = 1
	end

	---@type MapGen.Region
	local region = Region:new(minPos, maxPos, multinoise, weightFactor)

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

---Calculate the weight for noise based on
---the distance of the point from the center of the region.
---
---If the `weightFactor` is `0`, then the region's
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
	local weight = math.min(distX, distZ)

	return weight
end

local function generateNode(mapGenerator, hight, data, index, x, y, z)
	local ids =  mapGenerator.nodeIDs

	if y > hight and y >= 0 then
		data[index] = ids.air
	elseif y < hight then
		data[index] = ids.sylite -- TODO: сделать генерацию разных камней
	else
		data[index] = ids.water
	end
end

---@param mapGenerator  MapGen
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

	local noiseHeightValue = oceanNoise:get_2d({x = x, y = z})

	local regions = layer:getRegionsByPos(x, y, z)

	-- The height noise values ​​of all regions that a node is part of are added together.
	---@param region  MapGen.Region
	for _, region in ipairs(regions) do
		local noise = region:getMultinoise().landscapeNoise

		-- The further a point is from the center of a region, the less noise affects it.
		local weight = calculateWeight2D(region:getMinPos(), region:getMaxPos(), x, z, region.getWeightFactor())

		noiseHeightValue = noiseHeightValue + ( noise:get_2d({x = x, y = z}) * weight )
	end

	generateNode(mapGenerator, noiseHeightValue, data, index, x, y, z)
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

	MapGen.isRunning = true
end

return MapGen
