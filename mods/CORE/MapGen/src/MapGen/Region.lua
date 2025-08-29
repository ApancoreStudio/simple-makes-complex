local Region = {}
Region.__index = Region

local pairs, setmetatable = pairs, setmetatable

function Region:new(params)
	local instance = setmetatable({}, self)
	for k, v in pairs(params) do
		instance[k] = v
	end
	instance:initNoises()
	return instance
end

return Region
