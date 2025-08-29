local Ensure = require("MapGen.Utils.Ensure")

local Region3D = {}
Region3D.__index = Region3D

function Region3D:new(name, layer, allowedBiomes, caveNoise, temperatureNoise, humidityNoise, temperatureVariance, humidityVariance)
	Ensure.stringArgNotEmpty(name, 1, "Region3D:new")
	Ensure.argNotNil(layer, 2, "Region3D:new")
	Ensure.argType(allowedBiomes, "table", 3, "Region3D:new")
	Ensure.argType(caveNoise, "table", 4, "Region3D:new")
	Ensure.argType(temperatureNoise, "table", 5, "Region3D:new")
	Ensure.argType(humidityNoise, "table", 6, "Region3D:new")
	Ensure.argType(temperatureVariance, "table", 7, "Region3D:new")
	Ensure.argType(humidityVariance, "table", 8, "Region3D:new")

	local instance = setmetatable({
		name = name,
		layer = layer,
		allowedBiomes = allowedBiomes,
		caveNoise = caveNoise,
		temperatureNoise = temperatureNoise,
		humidityNoise = humidityNoise,
		temperatureVariance = temperatureVariance,
		humidityVariance = humidityVariance,
	}, self)

	return instance
end

function Region3D:Register()
	-- Logic to register the 3D region within the specified layer
end

function Region3D:ValidateBounds(minHeight, maxHeight)
	-- Logic to validate that the region does not exceed the layer boundaries
end

function Region3D:GenerateCaves()
	-- Logic to generate caves based on the cave noise
end

function Region3D:GenerateContents()
	-- Logic to populate the region with contents based on temperature and humidity
end

return Region3D