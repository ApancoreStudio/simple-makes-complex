local Utils = {}

function Utils.Clamp(value, min, max)
	if value < min then
		return min
	elseif value > max then
		return max
	else
		return value
	end
end

function Utils.Lerp(a, b, t)
	return a + (b - a) * t
end

function Utils.GenerateNoise(seed, x, y, scale)
	local noise = core.get_perlin(seed, scale, 1, 0)
	return noise:get2d({x, y})
end

function Utils.ValidateBiome(biome, allowedBiomes)
	for _, allowedBiome in ipairs(allowedBiomes) do
		if biome == allowedBiome then
			return true
		end
	end
	return false
end

return Utils