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

function Layer:contains(x, y, z)
    if y < self.minY or y > self.maxY then
        return false
    end

    for _, region in ipairs(self.regions2D) do
        if region:contains2D(x, z) then
            return true
        end
    end

    for _, region in ipairs(self.regions3D) do
        if region:contains3D(x, y, z) then
            return true
        end
    end

    return false
end
