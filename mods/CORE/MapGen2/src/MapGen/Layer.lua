local Layer = {}
Layer.__index = Layer

function Layer:new(minHeight, maxHeight)
	Ensure.argType(minHeight, 'number', 1, 'Layer:new')
	Ensure.argType(maxHeight, 'number', 2, 'Layer:new')
	Ensure.argNotNil(minHeight, 1, 'Layer:new')
	Ensure.argNotNil(maxHeight, 2, 'Layer:new')
	assert(minHeight < maxHeight, 'minHeight must be less than maxHeight')

	local layer = {
		minHeight = minHeight,
		maxHeight = maxHeight,
		region2DList = {},
		region3DList = {}
	}

	setmetatable(layer, self)
	return layer
end

function Layer:RegisterRegion2D(region2D)
	Ensure.argNotNil(region2D, 1, 'Layer:RegisterRegion2D')
	assert(region2D.minHeight >= self.minHeight and region2D.maxHeight <= self.maxHeight, 'Region2D height must be within layer boundaries')
	table.insert(self.region2DList, region2D)
end

function Layer:RegisterRegion3D(region3D)
	Ensure.argNotNil(region3D, 1, 'Layer:RegisterRegion3D')
	assert(region3D.minHeight >= self.minHeight and region3D.maxHeight <= self.maxHeight, 'Region3D height must be within layer boundaries')
	table.insert(self.region3DList, region3D)
end

function Layer:GetRegions2D()
	return self.region2DList
end

function Layer:GetRegions3D()
	return self.region3DList
end

return Layer