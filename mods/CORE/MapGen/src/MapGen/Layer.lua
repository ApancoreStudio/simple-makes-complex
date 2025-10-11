---@class MapGen.Layer
---@field name string
---@field minY number
---@field maxY number
---@field regionsList table<integer, MapGen.Region>
---@field defaultRegion MapGen.Region
local Layer = {
	regionsList = {}
}

local require = Mod.getInfo().require
local BufferZone = require("MapGen.Region.BufferZone")
local Region = require("MapGen.Region")

require = Mod.getInfo("smc__core__polyhedron").require
local Polyhedron = require("Polyhedron")


---Creates a new Layer instance
---@param name string The name of the layer
---@param minY number Minimum Y coordinate of the layer
---@param maxY number Maximum Y coordinate of the layer
---@return MapGen.Layer
function Layer:new(name, minY, maxY)
	---@type MapGen.Layer
	local instance = setmetatable({
		name = name,
		minY = minY,
		maxY = maxY,
		regionsList = {}
	}, {__index = self})

	-- Create default region that covers the entire layer
	instance:createDefaultRegion()
	
	return instance
end

---Creates the default region that covers the entire layer
function Layer:createDefaultRegion()
	local polyhedron = self:createLayerPolyhedron()
	---@type MapGen.Region.MultinoiseParams
	local multinoiseParams = {
		landscapeNoise = self:getDefaultLandscapeNoiseParams(),
		tempNoise = self:getDefaultTempNoiseParams(),
		humidityNoise = self:getDefaultHumidityNoiseParams(),
	}
	local bufferZone = BufferZone:new(0, "linear") -- No buffer for default region
	
	self.defaultRegion = Region:new(polyhedron, multinoiseParams, bufferZone)
end

---Creates a polyhedron that covers the entire layer
---@return Polyhedron
function Layer:createLayerPolyhedron()
	-- Create a very large polyhedron that covers the entire layer in Y and extends far in XZ
	local vertices = {
		vector.new(-30000, self.minY, -30000),
		vector.new( 30000, self.minY, -30000),
		vector.new( 30000, self.minY,  30000),
		vector.new(-30000, self.minY,  30000),
		vector.new(-30000, self.maxY, -30000),
		vector.new( 30000, self.maxY, -30000),
		vector.new( 30000, self.maxY,  30000),
		vector.new(-30000, self.maxY,  30000),
	}
	
	local faces = {
		{1, 2, 3, 4}, -- Bottom face
		{5, 6, 7, 8}, -- Top face
		{1, 2, 6, 5}, -- South face
		{2, 3, 7, 6}, -- East face  
		{3, 4, 8, 7}, -- North face
		{4, 1, 5, 8}, -- West face
	}
	
	return Polyhedron:new(vertices, faces)
end

---Gets default landscape noise parameters
---@return NoiseParams
function Layer:getDefaultLandscapeNoiseParams()
	return {
		offset = -30,
		scale = 10,
		spread = {x = 100, y = 100, z = 100},
		seed = 47,
		octaves = 8,
		persistence = 0.4,
		lacunarity = 2,
	}
end

---Gets default temperature noise parameters
---@return NoiseParams
function Layer:getDefaultTempNoiseParams()
	return {
		offset = 50,
		scale = 25,
		spread = {x = 10, y = 10, z = 10},
		seed = 12,
		octaves = 2,
		persistence = 0.6,
		lacunarity = 2,
	}
end

---Gets default humidity noise parameters
---@return NoiseParams  
function Layer:getDefaultHumidityNoiseParams()
	return {
		offset = 50,
		scale = 25,
		spread = {x = 10, y = 10, z = 10},
		seed = 12,
		octaves = 2,
		persistence = 0.6,
		lacunarity = 2,
	}
end

---Adds a region to this layer
---@param region MapGen.Region The region to add
function Layer:addRegion(region)
	table.insert(self.regionsList, region)
end

---Gets the region for a specific position, returns default region if no specific region found
---@param xPos number X coordinate
---@param yPos number Y coordinate  
---@param zPos number Z coordinate
---@return MapGen.Region
function Layer:getRegionByPos(xPos, yPos, zPos)
	local point = vector.new(xPos, yPos, zPos)

	for _, region in ipairs(self.regionsList) do
		local polyhedron = region:getPolyhedron()
		local distance = polyhedron:distanceToSurface(point)
		local bufferZone = region:getBufferZone()
		
		-- Include region if point is inside OR within buffer zone
		if polyhedron:containsPoint(point) or distance <= bufferZone.thickness then
			return region
		end
	end

	-- Fall back to default region
	return self.defaultRegion
end

---Returns the default region for this layer
---@return MapGen.Region
function Layer:getDefaultRegion()
	return self.defaultRegion
end

return Layer
