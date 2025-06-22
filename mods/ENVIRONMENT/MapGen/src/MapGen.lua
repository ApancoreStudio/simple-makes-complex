local modInfo     = Mod.getInfo()
local require     = modInfo.require
local MapGenUtils = require("MapGenUtils")
local Layer       = require("Layer")
local Region2D    = require("Region2D")
local Region3D    = require("Region3D")

local core, table, math = core, table, math
local pairs, ipairs = pairs, ipairs


-- Main MapGenerator class
local MapGenerator = {}
MapGenerator.__index = MapGenerator

function MapGenerator:new()
	return setmetatable({
		layersByName = {},
		layersList = {},
		registeredRegions = {},
		materials = {
			impassableWater = core.get_content_id("impassable_water:water"),
			impassableSeabed = core.get_content_id("impassable_water:seabed"),
			air = core.get_content_id("air")
		}
	}, self)
end

function MapGenerator:registerLayer(name, minY, maxY)
	local layer = Layer:new(name, minY, maxY)
	self.layersByName[name] = layer
	table.insert(self.layersList, layer)
	return layer
end

function MapGenerator:register2DRegion(params)
	local region = Region2D:new(params)
	local layer = self.layersByName[params.layerName]
	if not layer then error("Invalid layer: " .. params.layerName) end
	layer:add2DRegion(region)
end

function MapGenerator:register3DRegion(params)
	local region = Region3D:new(params)
	local layer = self.layersByName[params.layerName]
	if not layer then error("Invalid layer: " .. params.layerName) end
	layer:add3DRegion(region)
end

function MapGenerator:enable()
	core.register_on_generated(function(...)
		self:onMapGenerated(...)
	end)
end

-- Main generation logic
function MapGenerator:onMapGenerated(minp, maxp, seed)
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

function MapGenerator:process2DRegions(minp, maxp)
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

function MapGenerator:process3DRegions(minp, maxp, data, area, terrainCache)
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

return MapGenerator
