---@class MapGen.Layer
---@field name         string
---@field minY         number
---@field maxY         number
---@field cellsList  table
local Layer = {
	cellsList = {}
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

---@param cell  MapGen.Cell
function Layer:addCell(cell)
	table.insert(self.cellsList, cell)
	-- TODO: добавить сортировку массива для оптимизации.
	-- Вероятно будет лучше в отдельной фунции и засунуть её в MapGen.run
end

---Returns the two closest cells.
---@param xPos  number
---@param yPos  number
---@param zPos  number
---@return      MapGen.Cell?, MapGen.Cell?
function Layer:getCellsByPos(xPos, yPos, zPos)
	-- TODO: дописать алгоритмы оптимизации:
	--     * по сортированному массиву
	--     * с помощью минимальных расстояний-гарантов

	---@type MapGen.Cell, MapGen.Cell
	local cellA, cellB

	-- Note: to optimize the distance, the dots are always in a square.
	local pastDistance = math.huge
	local newDistance  = 0.0

	--- @type vector
	local cellPos

	---@param cell  MapGen.Cell
	for _, cell in  ipairs(self.cellsList) do

		if cellA == nil then
			cellA = cell
			goto continue
		end

		cellPos = cell.getCellPos()
		newDistance = (xPos - cellPos.x)^2 + (yPos - cellPos.y)^2 + (zPos - cellPos.z)^2

		if newDistance < pastDistance then
			cellB = cellA
			cellA = cellB
			pastDistance = newDistance
		end

		::continue::
	end

	return cellA, cellB
end

return Layer
