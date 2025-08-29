local modInfo = Mod.getInfo()
local require = modInfo.require
local Ensure  = require("MapGen.Utils.Ensure")

local Region2D = {}
Region2D.__index = Region2D

function Region2D:new(name, layer, allowedBiomes, heightNoise, temperatureNoise, humidityNoise, heightVariance, temperatureVariance, humidityVariance)
	Ensure.stringArgNotEmpty(name, 1, "Region2D:new")
	Ensure.argNotNil(layer, 2, "Region2D:new")
	Ensure.argType(allowedBiomes, "table", 3, "Region2D:new")
	Ensure.argType(heightNoise, "table", 4, "Region2D:new")
	Ensure.argType(temperatureNoise, "table", 5, "Region2D:new")
	Ensure.argType(humidityNoise, "table", 6, "Region2D:new")
	Ensure.argType(heightVariance, "table", 7, "Region2D:new")
	Ensure.argType(temperatureVariance, "table", 8, "Region2D:new")
	Ensure.argType(humidityVariance, "table", 9, "Region2D:new")

	local instance = setmetatable({}, self)
	instance.name = name
	instance.layer = layer
	instance.allowedBiomes = allowedBiomes
	instance.heightNoise = heightNoise
	instance.temperatureNoise = temperatureNoise
	instance.humidityNoise = humidityNoise
	instance.heightVariance = heightVariance
	instance.temperatureVariance = temperatureVariance
	instance.humidityVariance = humidityVariance

	return instance
end

function Region2D:GenerateTerrain(x, z)
	-- Implement terrain generation logic based on noise and variances
end

function Region2D:CheckBounds(y)
	-- Implement boundary checking logic for the layer
end

return Region2D