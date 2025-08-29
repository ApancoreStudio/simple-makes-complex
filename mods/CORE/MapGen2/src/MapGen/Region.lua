local Region = {}
Region.__index = Region

function Region:new(name, layer, allowedBiomes)
	Ensure.stringArgNotEmpty(name, 1, "Region:new")
	Ensure.argNotNil(layer, 2, "Region:new")
	Ensure.argNotNil(allowedBiomes, 3, "Region:new")

	local instance = setmetatable({}, self)
	instance.name = name
	instance.layer = layer
	instance.allowedBiomes = allowedBiomes

	return instance
end

function Region:GetName()
	return self.name
end

function Region:GetLayer()
	return self.layer
end

function Region:GetAllowedBiomes()
	return self.allowedBiomes
end

function Region:IsBiomeAllowed(biome)
	Ensure.stringArgNotEmpty(biome, 1, "Region:IsBiomeAllowed")
	return self.allowedBiomes[biome] == true
end

return Region