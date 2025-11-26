---**NOT IMPLEMENTED**
---@class MapGen.Decoration
local Decoration = {}

---@return  MapGen.Decoration
function Decoration:new()
	---@type MapGen.Decoration
	local instance = setmetatable({

	}, {__index = self})

	return instance
end

return Decoration
