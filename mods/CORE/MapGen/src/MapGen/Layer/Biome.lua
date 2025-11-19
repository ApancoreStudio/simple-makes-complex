---@class MapGen.Layer.Biome
---@field name           string
---@field tempPoint      number
---@field humidityPoint  number
---@field groundNodes    MapGen.Biome.GroundNodes
---@field soilHeight     number
local Biome = {}

---@param name           string
---@param tempPoint      number
---@param humidityPoint  number
---@param groundNodes    MapGen.Biome.GroundNodes
---@param soilHeight     number
---@return               MapGen.Layer.Biome
function Biome:new(name, tempPoint, humidityPoint, groundNodes, soilHeight)
	---@type MapGen.Layer.Biome
	local instance = setmetatable({
		name          = name,
		tempPoint     = tempPoint,
		humidityPoint = humidityPoint,
		groundNodes   = groundNodes,
		soilHeight    = soilHeight,
	}, {__index = self})

	return instance
end

return Biome