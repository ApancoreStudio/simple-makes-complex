local table, setmetatable = table, setmetatable

---@class MapGen.Layer
---@field name       string
---@field minY       number
---@field maxY       number
---@field regions2D  MapGen.Region.Region2D[]
---@field regions3D  MapGen.Region.Region3D[]
local Layer = {
	name      = nil,
	minY      = nil,
	maxY      = nil,
	regions2D = nil,
	regions3D = nil,
}

---@return MapGen.Layer
---@param name  string
---@param minY  number
---@param maxY  number
---@return MapGen.Layer
function Layer:new(name, minY, maxY)
	---@type MapGen.Layer
	local instance = setmetatable({
		name = name,
		minY = minY,
		maxY = maxY,
		regions2D = {},
		regions3D = {}
	}, {__index = self})

	return instance
end

---@param region  MapGen.Region.Region2D
function Layer:add2DRegion(region)
	table.insert(self.regions2D, region)
end

---@param region  MapGen.Region.Region3D
function Layer:add3DRegion(region)
	table.insert(self.regions3D, region)
end

---@return boolean
function Layer:contains(x, y, z)
	if y < self.minY or y > self.maxY then
		return false
	end

	for _, region in ipairs(self.regions2D) do
		if region:contains2D(x, z) then -- TODO: ТАКОГО МЕТОДА НИГДЕ НЕТ
		return true
		end
	end

	for _, region in ipairs(self.regions3D) do
		if region:contains3D(x, y, z) then -- TODO: ТАКОГО МЕТОДА НИГДЕ НЕТ
			return true
		 end
	end

	return false
end
