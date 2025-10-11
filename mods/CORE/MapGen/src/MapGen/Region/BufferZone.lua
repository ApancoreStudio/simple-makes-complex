---@class MapGen.Region.BufferZone
---@field thickness number
---@field preset string

local BufferZone = {}

function BufferZone:new(thickness, preset)
	---@type MapGen.Region.BufferZone
	local instance = setmetatable({
		thickness = thickness,
		preset = preset or "linear"
	}, {__index = self})
	return instance
end

return BufferZone
