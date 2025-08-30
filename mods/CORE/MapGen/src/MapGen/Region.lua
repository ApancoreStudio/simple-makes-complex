local pairs, setmetatable = pairs, setmetatable

---@class MapGen.Region
local Region = {}


---@param params  table
---@return MapGen.Region
function Region:new(params)
	---@type MapGen.Region
	local instance = setmetatable({}, {__index = self})

	for k, v in pairs(params) do
		instance[k] = v
	end

	instance:initNoises()

	return instance
end

return Region
