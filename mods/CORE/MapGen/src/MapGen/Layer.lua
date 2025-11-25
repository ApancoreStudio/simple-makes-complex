local mathSqrt = math.sqrt

---@class MapGen.Layer
---@field name               string
---@field minY               number
---@field maxY               number
---@field peaksList          MapGen.Peak[]
---@field biomesByName       table<string, MapGen.Layer.Biome>
---@field biomesList         MapGen.Layer.Biome[]
---@field biomesDiagram      table
---@field cavernsByName      table<string, MapGen.Layer.Cavern>
---@field cavernsList        MapGen.Layer.Cavern[]
---@field trianglesList      MapGen.Triangle[]
---@field tetrahedronsList   MapGen.Tetrahedron[]
local Layer = {
	peaksList     = {},
	biomesByName  = {},
	biomesList    = {},
	biomesDiagram = {},
	cavernsByName = {},
	cavernsList   = {},
	trianglesList = {},
	tetrahedronsList = {},
}

---@param name  string
---@param minY  number
---@param maxY  number
---@return      MapGen.Layer
function Layer:new(name, minY, maxY)
	---@type MapGen.Layer
	local instance = setmetatable({
		name = name,
		minY = minY,
		maxY = maxY,
	}, {__index = self})

	return instance
end

---@param peak  MapGen.Peak
function Layer:addPeak(peak)
	table.insert(self.peaksList, peak)
end

---@param height      number
---@param biomesList  MapGen.Layer.Biome[]
---@return            string[], MapGen.Layer.Biome[]
local function getBiomesNamesByHeight(height, biomesList)
	local biomesNames = {}
	local biomes = {}

	for _, biome in ipairs(biomesList) do
		if height >= biome.minY and height <= biome.maxY then
			table.insert(biomesNames, biome.name)
			table.insert(biomes, biome)
		end
	end

	table.sort(biomesNames)

	return biomesNames, biomes
end

---Initialization of the biome diagram using the Voronoi method.
function Layer:initBiomesDiagram()
	local diagram = self.biomesDiagram
	local pastBiomesNames
	local pastDiagramSlice

	-- A counter for logging unique slices in the biome diagram.
	local uniqueDiagramSlices = 0

	for height = self.minY, self.maxY do
		diagram[height] = {}

		local newBiomesNames, biomes = getBiomesNamesByHeight(height, self.biomesList)

		if pastBiomesNames ~= nil and dump(pastBiomesNames) == dump(newBiomesNames) then
			diagram[height] = pastDiagramSlice

			goto continue
		end

		pastBiomesNames = newBiomesNames
		for temp = 0, 100 do
			diagram[height][temp] = {}

			for humidity = 0, 100 do
				local minDistance = math.huge
				local closestBiome = nil

				---@param biome MapGen.Layer.Biome
				for _, biome in ipairs(biomes) do
					local distance = (temp - biome.tempPoint)^2 + (humidity - biome.humidityPoint)^2

					if distance < minDistance then
						minDistance = distance
						closestBiome = biome
					end
				end

				-- If there is no nearby biome for this height...
				if closestBiome == nil then
					-- ... then the first registered biome in the layer will be the default one.
					diagram[height][temp][humidity] = self.biomesList[1]
				else
					diagram[height][temp][humidity] = closestBiome
				end
			end
		end

		pastDiagramSlice = diagram[height]
		uniqueDiagramSlices = uniqueDiagramSlices + 1

		::continue::
	end

	Logger.infoLog('MapGen.Layer.initBiomesDiagram(): Initialized to %s unique slices for the layer `%s` biome diagram.', uniqueDiagramSlices, self.name)
end

return Layer
