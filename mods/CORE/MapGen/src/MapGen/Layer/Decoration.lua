---@class MapGen.Layer.Decoration
local Decoration = {}

---@return  MapGen.Layer.Decoration
function Decoration:new(tempPoint, humidityPoint, groundNodes, soilHeight)
	---@type MapGen.Layer.Decoration
	local instance = setmetatable({

	}, {__index = self})

	return instance
end

return Decoration