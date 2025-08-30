local core, table, math = core, table, math
local ipairs = pairs, ipairs

local modInfo     = Mod.getInfo()
local require     = modInfo.require

---@type MapGen.Utils
local MapGenUtils = require("MapGen.Utils")

---@type MapGen.Layer
local Layer       = require("MapGen.Layer")

---@type MapGen.Region.Region2D
local Region2D    = require("MapGen.Region.Region2D")

---@type MapGen.Region.Region3D
local Region3D    = require("MapGen.Region.Region3D")

---@class MapGen
---@field layersByName         table
---@field layersList           table
---@field registeredRegions    table
---@field material             table<string, number>
local MapGen = {}

---@return MapGen
function MapGen:new()
	local instance = setmetatable({
		layersByName = {},
		layersList = {},
		registeredRegions = {},
		materials = {
			impassableWater = core.get_content_id("impassable_water:water"),
			impassableSeabed = core.get_content_id("impassable_water:seabed"),
			air = core.get_content_id("air")
		},
	}, {__index = self})

	return instance
end

---@param name  string
---@param minY  number
---@param maxY  number
---@return      MapGen.Layer
function MapGen:registerLayer(name, minY, maxY)
	---@type MapGen.Layer
	local layer = Layer:new(name, minY, maxY)

	self.layersByName[name] = layer
	table.insert(self.layersList, layer)

	return layer
end

---@param params  table
function MapGen:register2DRegion(params)
	---@type MapGen.Region.Region2D
	local region = Region2D:new(params)

	---@type MapGen.Layer
	local layer = self.layersByName[params.layerName]

	if not layer then
		error("Invalid layer: " .. params.layerName)
	end

	layer:add2DRegion(region)

	-- TODO: тут не надо возвращать регион?
end

---@param params  table
function MapGen:register3DRegion(params)
	---@type MapGen.Region.Region3D
	local region = Region3D:new(params)

	---@type MapGen.Layer
	local layer = self.layersByName[params.layerName]

	if not layer then
		error("Invalid layer: " .. params.layerName)
	end

	layer:add3DRegion(region)

	-- TODO: тут не надо возвращать регион?
end

function MapGen:enable()
	core.register_on_generated(function(...)
		self:onMapGenerated(...)
	end)
end

--- Main generation logic
---@param minp  table TODO: заменить тип на класс/вектор координат
---@param maxp  table TODO: заменить тип на класс/вектор координат
---@param seed  number
function MapGen:onMapGenerated(minp, maxp, seed)
	local vm, emin, emax = core.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	local data = vm:get_data()

	-- Sort layers by maxY descending for processing priority
	table.sort(self.layersList, function(a, b)
		return a.maxY > b.maxY
	end)

	local terrainCache = self:process2DRegions(minp, maxp)
	self:process3DRegions(minp, maxp, data, area, terrainCache)

	vm:set_data(data)
	vm:calc_lighting()
	vm:write_to_map()
end

---@param minp  table TODO: заменить тип на класс/вектор координат
---@param maxp  table TODO: заменить тип на класс/вектор координат
---@return      table
function MapGen:process2DRegions(minp, maxp)
	local cache = {}
	local width = maxp.x - minp.x + 1
	local zSize = maxp.z - minp.z + 1

	-- Precompute noise for all 2D regions
	local regionNoiseCache = {}
	for _, layer in ipairs(self.layersList) do
		for _, region in ipairs(layer.regions2D) do
			local noiseCache = {
				height = {},
				temp = {},
				humid = {},
			}
			for x = minp.x, maxp.x do
				noiseCache.temp[x] = {}
				noiseCache.humid[x] = {}
				noiseCache.height[x] = {}
				for z = minp.z, maxp.z do
					noiseCache.temp[x][z] = region.noiseTemp:get2d({x=x, y=z})
					noiseCache.humid[x][z] = region.noiseHumid:get2d({x=x, y=z})
					noiseCache.height[x][z] = region.noiseHeight:get2d({x=x, y=z})
				end
			end
			regionNoiseCache[region] = noiseCache
		end
	end

	for x = minp.x, maxp.x do
		cache[x] = {}
		for z = minp.z, maxp.z do
			cache[x][z] = {}

			for _, layer in ipairs(self.layersList) do
				local bestHeight, bestWeight = nil, 0.0

				for _, region in ipairs(layer.regions2D) do
					local noiseCache = regionNoiseCache[region]
					local temp = noiseCache.temp[x][z]
					local humid = noiseCache.humid[x][z]

					if MapGenUtils.isInRange(temp, region.tempRange) and MapGenUtils.isInRange(humid, region.humidRange) then
						local tempWeight = MapGenUtils.calculateWeight(temp, region.tempRange.min, region.tempRange.max)
						local heightWeight = MapGenUtils.calculateWeight(humid, region.humidRange.min, region.humidRange.max)
						local weight = tempWeight * heightWeight

						if weight > bestWeight then
							local heightNoise = noiseCache.height[x][z]
							bestHeight = math.lerp(
								region.heightRange.min,
								region.heightRange.max,
								heightNoise
							)
							bestWeight = weight
						end
					end
				end

				if bestHeight then
					cache[x][z][layer] = math.floor(math.clamp(bestHeight, layer.minY, layer.maxY))
				end
			end
		end
	end

	return cache
end

---@param minp          table TODO: заменить тип на класс/вектор координат
---@param maxp          table TODO: заменить тип на класс/вектор координат
---@param data          void TODO: какой тип?
---@param area          void
---@param terrainCache  void
function MapGen:process3DRegions(minp, maxp, data, area, terrainCache)
	-- Precompute 3D noise for regions
	local region3DNoise = {}
	for _, layer in ipairs(self.layersList) do
		for _, region in ipairs(layer.regions3D) do
			region3DNoise[region] = {
				temp = {},
				humid = {},
				cave = {}
			}
			for y = minp.y, maxp.y do
				region3DNoise[region].temp[y] = {}
				region3DNoise[region].humid[y] = {}
				region3DNoise[region].cave[y] = {}
				for x = minp.x, maxp.x do
					region3DNoise[region].temp[y][x] = {}
					region3DNoise[region].humid[y][x] = {}
					region3DNoise[region].cave[y][x] = {}
					for z = minp.z, maxp.z do
						region3DNoise[region].temp[y][x][z] = region.noiseTemp:get3d({x=x, y=y, z=z})
						region3DNoise[region].humid[y][x][z] = region.noiseHumid:get3d({x=x, y=y, z=z})
						region3DNoise[region].cave[y][x][z] = region.noiseCave:get3d({x=x, y=y, z=z})
					end
				end
			end
		end
	end

	for x = minp.x, maxp.x do
		for z = minp.z, maxp.z do
			local columnCache = terrainCache[x][z]
			local baseIndex = area:index(x, minp.y, z)
			local yStride = area.ystride

			for y = minp.y, maxp.y do
				local idx = baseIndex + (y - minp.y) * yStride
				local processed = false

				for _, layer in ipairs(self.layersList) do
					if y >= layer.minY and y <= layer.maxY then
						local surfaceY = columnCache[layer]

						if not surfaceY then
							data[idx] = y == layer.minY and
								self.materials.impassableSeabed or
								self.materials.impassableWater
						else
							-- Set default based on position relative to surface
							local default = (y <= surfaceY) and
								self.materials.impassableSeabed or
								self.materials.air
							data[idx] = default

							-- Apply 3D regions (caves/structures)
							for _, region in ipairs(layer.regions3D) do
								local temp = region3DNoise[region].temp[y][x][z]
								local humid = region3DNoise[region].humid[y][x][z]
								local cave = region3DNoise[region].cave[y][x][z]

								if MapGenUtils.isInRange(temp, region.tempRange) and
									MapGenUtils.isInRange(humid, region.humidRange) and cave > region.caveThreshold then
									data[idx] = self.materials.air
									break -- Only first matching region applies
								end
							end
						end

						processed = true
						break -- Only process one layer per Y position
					end
				end

				if not processed then
					data[idx] = self.materials.air
				end
			end
		end
	end
end

return MapGen
