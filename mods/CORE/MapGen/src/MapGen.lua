local mathCeil,  id
	= math.ceil, core.get_content_id

-- --- Node's IDs for generation ---
-- Specials
local id_air = id("air")

-- Stones

-- Liquids

-- --- End Node's IDs

local modInfo = Mod.getInfo()
local require = modInfo.require

---@type MapGen.Layer
local Layer = require("MapGen.Layer")

---@type MapGen.Region
local Region = require("MapGen.Region")

---@class MapGen
---@field layersByName  table
---@field layersList    table
---@field isRunning     boolean  A static field that guarantees that only one instance of the `MapGen` class will work.
local MapGen = {
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

	--TODO: реализовать регистрацию допольнительных регионов для сглаживания шумов

	layer:addRegion(region)
end

function MapGen:landscapeGeneration(data, area, x, y, z)
	local index = area:index(x, y, z)

	-- If generation occurs outside the layers, then a void is generated
	local layer = self:getLayerByHeight(y)
	if layer == nil then
		data[index] = id_air

		return
	end

	-- If generation occurs outside the regions, then a ocean is generated
	local regions = layer:getRegionsByPos(x, y, z)
	if table.is_empty(regions) then
		-- TODO: прописать генерацию океана

		return
	end

	local noiseHeightValue = 0

	-- The height noise values ​​of all regions that a node is part of are added together...
	---@param region  MapGen.Region
	for _, region in ipairs(regions) do
		if region.multinoise.landscapeNoise ~= nil then
			local noise = core.get_value_noise(region.multinoise.landscapeNoise)
			noiseHeightValue = noiseHeightValue + noise:get_2d({x = x, y = z})

		end
	end

	-- ...And the average height is found: this provides smoothing
	noiseHeightValue = mathCeil(noiseHeightValue / #regions)

	if y > noiseHeightValue then
		data[index] = id_air
	else
		data[index] = core.get_content_id("rocks:tauitite") -- TODO: прописать заполнение камнем
	end
end

function MapGen:postprocessGeneration(data, area, x, y, z)
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
	local data = voxelManip:get_data()
	local area = VoxelArea:new({MinEdge = eMin, MaxEdge = eMax})
	-- local param2_data = voxelManip:get_param2_data()

	-- Initial generation: landscape
	for z = minPos.z, maxPos.z do
	for y = minPos.y, maxPos.y do
	for x = minPos.x, maxPos.x do
		self:landscapeGeneration(data, area, x, y, z)
		--core.handle_async(self.landscapeGeneration, callback, self, data, area, x, y, z)
		-- вероятно благодаря 2D шуму высоты генерацию ландшафта можно оптимизировать
		-- до генерации столбами (т. к. по x, z можно найти требуемый y)
	end
	end
	end

	-- Post-processing: adding cover and vegetation
	--[[for z = minPos.z, maxPos.z do
	for y = minPos.y, maxPos.y do
	for x = minPos.x, maxPos.x do
		MapGen:postprocessGeneration(data, area, x, y, z)
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
