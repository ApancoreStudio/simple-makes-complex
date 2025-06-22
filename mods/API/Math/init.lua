local math = math

math.lerp = function (a, b, t)
	return a + (b - a) * t
end

math.clamp = function(value, min, max)
	return math.min(math.max(value, min), max)
end
