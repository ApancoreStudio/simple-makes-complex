---@class MapGen.InterpolationPreset
---@field calculate fun(distance: number, thickness: number): number

local InterpolationPresets = {
	linear = function(distance, thickness)
		return math.max(0, 1 - (distance / thickness))
	end,
	
	smoothstep = function(distance, thickness)
		local t = math.max(0, 1 - (distance / thickness))
		return t * t * (3 - 2 * t)
	end,
	
	smootherstep = function(distance, thickness)
		local t = math.max(0, 1 - (distance / thickness))
		return t * t * t * (t * (t * 6 - 15) + 10)
	end,
	
	exponential = function(distance, thickness)
		local t = math.max(0, 1 - (distance / thickness))
		return t * t  -- Quadratic falloff
	end
}

return InterpolationPresets
