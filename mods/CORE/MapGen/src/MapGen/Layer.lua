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
	print(dump(self.cellsList))
	-- TODO: добавить сортировку массива для оптимизации.
	-- Вероятно будет лучше в отдельной фунции и засунуть её в MapGen.run
end

---Returns the two closest cells.
---@param xPos  number
---@param yPos  number
---@param zPos  number
---@return      MapGen.Cell, MapGen.Cell?, MapGen.Cell?
function Layer:getCellsByPos(xPos, yPos, zPos)
	-- TODO: дописать алгоритмы оптимизации:
	--     * по сортированному массиву
	--     * с помощью минимальных расстояний-гарантов

	---@type MapGen.Cell, MapGen.Cell, MapGen.Cell
	local cellA, cellB, cellC

	-- Note: to optimize the distance, the dots are always in a square.
	local pastDistanceA = math.huge
	local pastDistanceB = math.huge
	local pastDistanceC = math.huge
	local newDistance

	--- @type vector
	local cellPos

	---@param cell  MapGen.Cell
	for _, cell in  ipairs(self.cellsList) do

		if cellA == nil then
			cellA = cell
			cellPos = cell.getCellPos()
			pastDistanceA = (xPos - cellPos.x)^2 + (yPos - cellPos.y)^2 + (zPos - cellPos.z)^2

			goto continue
		end

		cellPos = cell.getCellPos()
		newDistance = (xPos - cellPos.x)^2 + (yPos - cellPos.y)^2 + (zPos - cellPos.z)^2

		if newDistance < pastDistanceA then
			cellC = cellB
			cellB = cellA
			cellA = cell

			pastDistanceC = pastDistanceB
			pastDistanceB = pastDistanceA
			pastDistanceA = newDistance

			goto continue
		end

		if newDistance < pastDistanceB then
			cellC = cellB
			cellB = cell

			pastDistanceC = pastDistanceB
			pastDistanceB = newDistance

			goto continue
		end

		if newDistance < pastDistanceC then
			cellC = cell

			pastDistanceC = newDistance

			goto continue
		end

		::continue::
	end

	return cellA, cellB, cellC
end

return Layer
