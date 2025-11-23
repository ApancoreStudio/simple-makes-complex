---@class MapGen.Layer.Biome
---@field name           string
---@field tempPoint      number
---@field humidityPoint  number
---@field groundNodes    MapGen.Biome.GroundNodes
---@field soilHeight     number
local Biome = {}

---@class MapGen.Layer.BiomeDef
---@field tempPoint      number
---@field humidityPoint  number
---@field groundNodes    MapGen.Biome.GroundNodes
---@field soilHeight     number

---@param name  string
---@param def   MapGen.Layer.BiomeDef
---@return      MapGen.Layer.Biome
function Biome:new(name, def)
	---@type MapGen.Layer.Biome
	local instance = setmetatable({
		name          = name,
		tempPoint     = def.tempPoint,
		humidityPoint = def.humidityPoint,
		groundNodes   = def.groundNodes,
		soilHeight    = def.soilHeight,
	}, {__index = self})

	return instance
end

return Biome