local table, setmetatable = table, setmetatable

local Layer = {}
Layer.__index = Layer

function Layer:new(name, minY, maxY)
	return setmetatable({
		name = name,
		minY = minY,
		maxY = maxY,
		regions2D = {},
		regions3D = {}
	}, self)
end

function Layer:add2DRegion(region)
	table.insert(self.regions2D, region)
end

function Layer:add3DRegion(region)
	table.insert(self.regions3D, region)
end
