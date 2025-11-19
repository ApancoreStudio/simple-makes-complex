local mathSqrt = math.sqrt

---@class MapGen.Layer
---@field name               string
---@field minY               number
---@field maxY               number
---@field peaksList          MapGen.Peak[]
---@field cavernsByName      table<string, MapGen.Layer.Cavern>
---@field cavernsList        MapGen.Layer.Cavern[]
---@field trianglesList      MapGen.Triangle[]
---@field tetrahedronsList   MapGen.Tetrahedron[]
local Layer = {
	peaksList     = {},
	cavernsByName = {},
	cavernsList   = {},
	trianglesList = {},
	tetrahedronsList = {},
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

---@param peak  MapGen.Peak
function Layer:addPeak(peak)
	table.insert(self.peaksList, peak)
end

---Returns a list of tables of the form `{peak, weight}`.
---
---Maybe return an empty table.
---@param xPos  number
---@param yPos  number
---@param zPos  number
---@return      {peak : MapGen.Peak, weight : number}[] | table, number
function Layer:getPeaksByPos(xPos, yPos, zPos, radius)
	---@type MapGen.Peak[]
	local peaks = {}
	--- @type vector
	local peakPos
	---@type number
	local distance
	---@type number
	local weight
	---@type number
	local totalWeight = 0

	---@param peak  MapGen.Peak
	for _, peak in  ipairs(self.peaksList) do
		peakPos = peak.getPeakPos()
		distance = mathSqrt((xPos - peakPos.x)^2 + (yPos - peakPos.y)^2 + (zPos - peakPos.z)^2)

		if distance <= radius then
			weight = 1 / distance --/ radius

			table.insert(peaks, {peak = peak, weight = weight})

			totalWeight = totalWeight + weight
		end
	end

	return peaks, totalWeight
end

return Layer
