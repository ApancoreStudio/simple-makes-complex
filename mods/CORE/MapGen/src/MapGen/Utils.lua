local math = math

--- Utility class with static methods
---@class MapGen.Utils
local Utils = {}

---@static
---@param value  number
---@param min    number
---@param max    number
---@return       number
function Utils.calculateWeight(value, min, max)
	local center = (min + max) / 2
	local span = (max - min) / 2

	return 1 - math.abs((value - center) / span)
end

---@static
---@param value  number
---@param range  number
---@return       boolean
function Utils.isInRange(value, range)
	if value >= range.min and value <= range.max then
		return true
	end

	return false
end

return Utils
