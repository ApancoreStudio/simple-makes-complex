---@class MapGen.Layer
---@field name         string
---@field minY         number
---@field maxY         number
---@field regionsList  table
local Layer = {
	regionsList = {}
}

---@param name  string
---@param minY  number
---@param maxY  number
---@return      MapGen.Layer
function Layer:new(name, minY, maxY)
	---@type MapGen.Layer
	local instance = setmetatable({
		name = name,
		minY = minY,
		maxY = maxY,
	}, {__index = self})

	return instance
end

---@param region  MapGen.Region
function Layer:addRegion(region)
	table.insert(self.regionsList, region)
end

---@param xPos  number
---@param yPos  number
---@param zPos  number
---@return      MapGen.Region[]
function Layer:getRegionsByPos(xPos, yPos, zPos)
	-- TODO: возможно здесь получится сделать более оптимизированный алгоритм
	-- учитывая тот факт, что эта функция вызывается для каждой ноды в on_generated
	-- и может быть даже не один раз
	-- Можно подумать над тем, чтобы использовать сортированный список

	---@type MapGen.Region[]
	local regions = {}

	---@param region  MapGen.Region
	for _, region in  ipairs(self.regionsList) do

		if  (
			xPos >= region:getMinPos().x and
			yPos >= region:getMinPos().y and
			zPos >= region:getMinPos().z) and
			(
			xPos <= region:getMaxPos().x and
			yPos <= region:getMaxPos().y and
			zPos <= region:getMaxPos().z
			) then
				table.insert(regions, region)
		end

	end

	return regions
end

return Layer
