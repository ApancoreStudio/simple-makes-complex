local math = math

-- Utility class with static methods
local MapGenUtils = {
	calculateWeight = function(value, min, max)
		local center = (min + max) / 2
		local span = (max - min) / 2
		return 1 - math.abs((value - center) / span)
	end,

	---@return boolean
	isInRange = function(value, range)
		if value >= range.min and value <= range.max then
			return true
		end
		return false
	end
}

return MapGenUtils
