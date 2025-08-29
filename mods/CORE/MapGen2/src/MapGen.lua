local MapGen = {}
MapGen.__index = MapGen

function MapGen:new()
	local instance = setmetatable({}, self)
	instance.layers = {}
	return instance
end

function MapGen:RegisterLayer(layer)
	Ensure.argNotNil(layer, 1, "MapGen:RegisterLayer")
	Ensure.argType(layer.minHeight, "number", 1, "MapGen:RegisterLayer")
	Ensure.argType(layer.maxHeight, "number", 2, "MapGen:RegisterLayer")
	assert(layer.minHeight < layer.maxHeight, "minHeight must be less than maxHeight")

	table.insert(self.layers, layer)
end

function MapGen:GenerateMap()
	for _, layer in ipairs(self.layers) do
		self:GenerateLayer(layer)
	end
end

function MapGen:GenerateLayer(layer)
	-- Implement layer generation logic here
	-- This will include processing 2D and 3D regions
end

function MapGen:RegisterRegion2D(region)
	Ensure.argNotNil(region, 1, "MapGen:RegisterRegion2D")
	-- Additional validation and registration logic for 2D regions
end

function MapGen:RegisterRegion3D(region)
	Ensure.argNotNil(region, 1, "MapGen:RegisterRegion3D")
	-- Additional validation and registration logic for 3D regions
end

return MapGen