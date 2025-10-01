local mathCeil,  id
	= math.ceil, core.get_content_id

-- --- Node's IDs for generation ---
-- Specials
local id_air = id("air")

-- Stones

-- Liquids

-- --- End Node's IDs

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
local MapGen = {
	multinoiseInitialized = false,
	isRunning = false,
}

---@return MapGen
function MapGen:new()
	local instance = setmetatable({
		layersByName = {},
		layersList = {},
		--registeredRegions = {},
	}, {__index = self})

	return instance
end

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

---@param layerName     string
---@param minPos        table
---@param maxPos        table
---@param multinoise        table
---@param regionIs2D    boolean?
function MapGen:RegisterRegion(layerName, minPos, maxPos, multinoise, regionIs2D)
	---@type MapGen.Layer
	local layer = self.layersByName[layerName]

	if not layer then
		error("Invalid layer: " .. layerName)
	end

	if regionIs2D then
		minPos.y = layer.minY
		maxPos.y = layer.maxY
	end

	---@type MapGen.Region
	local region = Region:new(minPos, maxPos, multinoise)

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


---@return  number
local function calculateWeight(minPos, maxPos, x, z)
	--TODO: написать поддержку коэффициента, чтобы функция была не линейной и отключение учитывание веса
	local centerX = (minPos.x + maxPos.x) / 2
	local centerZ = (minPos.z + maxPos.z) / 2

	local distX = 1 - math.abs(x - centerX) / (math.abs((maxPos.x - minPos.x)) / 2)
	local distZ = 1 - math.abs(z - centerZ) / (math.abs((maxPos.z - minPos.z)) / 2)

	local weight = math.min(distX, distZ)

	return weight
end

local function landscapeGeneration(mapGenerator, data, index, x, y, z)

	-- If generation occurs outside the layers, then a void is generated
	local layer = mapGenerator:getLayerByHeight(y)
	if layer == nil then
		data[index] = id_air

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
		local weight = calculateWeight(region:getMinPos(), region:getMaxPos(), x, z)

		noiseHeightValue = noiseHeightValue + ( noise:get_2d({x = x, y = z}) * weight )
	end

	if y > noiseHeightValue and y >= 0 then
		data[index] = id_air
	elseif y < noiseHeightValue then
		data[index] = core.get_content_id("rocks:falmyte")  -- TODO: сделать генерацию разных камней
	else
		data[index] = core.get_content_id("liquids:water_source")
end

end

local function postprocessGeneration(mapGenerator, data, area, x, y, z)
	local index = area:index(x, y, z)

	-- TODO: генерация покрытия

	-- TODO: генерация растительности
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
			landscapeGeneration(self, data, index, x, y, z)

			index = index + 1
		end
	end
	end

	-- Post-processing: adding cover and vegetation
	--[[for z = minPos.z, maxPos.z do
	for y = minPos.y, maxPos.y do
	for x = minPos.x, maxPos.x do
		postprocessGeneration(mapGenerator, data, area, x, y, z)
	end
	end
	end --]]

	-- We make changes back to LVM and recalculate light & liquids
	voxelManip:set_data(data)
	-- voxelManip:set_param2_data(param2_data)
	voxelManip:update_liquids()
	voxelManip:calc_lighting()

	voxelManip:write_to_map()
end

function MapGen:run()
	if MapGen.isRunning then
		error('Only one instance of a `MapGen` class can be used.')
	end

	core.register_on_generated(function(...)
		self:onMapGenerated(...)
	end)

	MapGen.isRunning = true
end

return MapGen
