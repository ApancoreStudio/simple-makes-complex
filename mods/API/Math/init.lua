local math = math

---Limiting the value by minimum and maximum value.
---@param value  number  The value to be limited.
---@param min    number  Minimum limit.
---@param max    number  Maximum limit.
math.clamp = function(value, min, max)
	return math.min(math.max(value, min), max)
end

---Linear interpolation.
---@param a  number  Minimum value.
---@param b  number  Maximum value.
---@param t  number  Number in range [0, 1].
math.lerp = function (a, b, t)
	t = math.clamp(t, 0, 1)

	return a + (b - a) * t
end